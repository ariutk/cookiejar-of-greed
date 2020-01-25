# frozen_string_literal: true
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/time'
require 'time'
require 'uri'

module Greed
  module Cookie
    class Jar
      def initialize(\
        set_cookie_parser: nil,
        get_current_time: nil,
        calculate_expiration: nil,
        determine_domain: nil
      )
        @set_cookie_parser = set_cookie_parser || Parser.new.method(:parse)
        @get_current_time = get_current_time || ::Time.method(:current)
        @calculate_expiration = calculate_expiration || ExpirationHandler.new.method(:calculate_expiration)
        @determine_domain = determine_domain || DomainHandler.new.method(:determine_domain)
        @cookie_map = {}
      end

      def store(document_uri, cookie_hash)
        return false unless cookie_hash.present?
        current_time = @get_current_time.call
        parsed_document_uri = ::URI.parse(document_uri)
        base = cookie_hash.slice(:name, :value, :path, :secure)
        domain_attributes = @determine_domain.call(
          parsed_document_uri.hostname,
          cookie_hash[:domain]
        )
        final_domain = domain_attributes.delete(:domain)
        current_cookies = @cookie_map[final_domain].try(:clone) || {} # make each domain immutable
        expires_attributes = @calculate_expiration.call(
          current_time,
          cookie_hash[:'max-age'],
          cookie_hash[:expires]
        )
        current_cookies[base[:name]] = base.merge(
          domain_attributes,
          expires_attributes,
        )
        @cookie_map[final_domain] = current_cookies
        true
      rescue DomainError
        return false
      rescue Expired
        removed_cookie = current_cookies.delete(base[:name])
        return false unless removed_cookie
        @cookie_map[final_domain] = current_cookies
        return true
      end

      def dump
        garbage_collect
        @cookie_map.clone
      end

      def cookie_for(document_uri)
        parsed_document_uri = begin
          ::URI.parse(document_uri)
        rescue ::URI::Error
          return []
        end
        is_secure = case parsed_document_uri
        when ::URI::HTTPS
          true
        when ::URI::HTTP
          false
        else
          return []
        end
        domain_name = parsed_document_uri.hostname
        ip_address = begin
          ::IPAddr.new(domain_name)
        rescue ::IPAddr::Error
          nil
        end
        return cookie_for_ip_address(parsed_document_uri.path, is_secure, ip_address) if ip_address
        cookie_for_domain(parsed_document_uri.path, is_secure, domain_name)
      end

      def cookie_string_for(document_uri)
        cookie_for(document_uri)
      end

      def parse_set_cookie(document_uri, header)
        store(document_uri, @set_cookie_parser.call(header))
      end

      def garbage_collect
        current_time = @get_current_time.call
        @cookie_map = @cookie_map.map do |domain_name, cookie_names|
          cookie_names.select do |_cookie_name, cookie_record|
            !cookie_record[:expires] || current_time < cookie_record[:expires]
          end.yield_self do |filtered_result|
            [domain_name, filtered_result]
          end
        end.to_h
        nil
      end

      private

      def cookie_for_domain(document_path, is_document_secure, domain_name)
        scanner = ::StringScanner.new(domain_name)
        chunk_scanner = /\A[-_\w\d]+\./
        ::Enumerator.new do |yielder|
          loop do
            break if scanner.eos?
            removed_part = scanner.scan(chunk_scanner)
            break unless removed_part
            yielder << scanner.rest
          end
        end.yield_self do |parent_domains|
          [[domain_name], parent_domains.lazy].lazy.flat_map(&:itself)
        end.flat_map do |lookup_domain|
          @cookie_map[lookup_domain].try(:values) || []
        end.yield_self do |cookie_records|
          filter_cookie(cookie_records, document_path, is_document_secure)
        end.select do |cookie_record|
          next true if cookie_record[:domain] == domain_name
          cookie_record[:include_subdomains]
        end
      end

      def cookie_for_ip_address(document_path, is_document_secure, ip_address)
        (
        @cookie_map[ip_address.to_s].try(:values) || []
        ).lazy.yield_self do |cookie_records|
          filter_cookie(cookie_records, document_path, is_document_secure)
        end
      end

      def filter_cookie(cookie_records, document_path, is_document_secure)
        current_time = @get_current_time.call
        cookie_records.select do |cookie_record|
          !cookie_record[:expires] || current_time < cookie_record[:expires]
        end.select do |cookie_record|
          next true if is_document_secure
          !cookie_record[:secure]
        end.select do |cookie_record|
          next true unless cookie_record[:path].present?
          next true if document_path.blank? && (cookie_record[:path] == '/')
          document_path.start_with?(cookie_record[:path])
        end
      end
    end
  end
end
