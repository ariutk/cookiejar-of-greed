# frozen_string_literal: true
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/time'
require 'ipaddr'
require 'time'
require 'uri'

module Greed
  module Cookie
    class Jar
      include Iterator

      def initialize(\
        state = nil,
        set_cookie_parser: nil,
        get_current_time: nil,
        calculate_expiration: nil,
        determine_domain: nil,
        determine_path: nil
      )
        @set_cookie_parser = set_cookie_parser || Parser.new.method(:parse)
        @get_current_time = get_current_time || ::Time.method(:current)
        @calculate_expiration = calculate_expiration || ExpirationHandler.new.method(:calculate_expiration)
        @determine_domain = determine_domain || DomainHandler.new.method(:determine_domain)
        @determine_path = determine_path || PathHandler.new.method(:determine_path)
        @cookie_map = state || {}
      end

      def append_cookie(document_uri, cookie_hash)
        return false unless cookie_hash.present?
        current_time = @get_current_time.call
        parsed_document_uri = ::URI.parse(document_uri)
        base = cookie_hash.slice(:name, :value, :secure)
        domain_attributes = @determine_domain.call(
          parsed_document_uri.hostname,
          cookie_hash[:domain]
        )
        path_attributes = @determine_path.call(
          parsed_document_uri.path,
          cookie_hash[:path]
        )
        final_domain = domain_attributes[:domain]
        final_path = path_attributes[:path]
        domain_holder = @cookie_map[final_domain].try(:clone) || {}
        path_holder = domain_holder[final_path].try(:clone) || {}
        expires_attributes = @calculate_expiration.call(
          current_time,
          cookie_hash[:'max-age'],
          cookie_hash[:expires]
        )
        path_holder[base[:name]] = base.merge(
          domain_attributes,
          expires_attributes,
          path_attributes,
        )
        domain_holder[final_path] = path_holder
        @cookie_map[final_domain] = domain_holder
        true
      rescue DomainError, PathError
        return false
      rescue Expired
        removed_cookie = path_holder.delete(base[:name])
        return false unless removed_cookie
        domain_holder[final_path] = path_holder
        @cookie_map[final_domain] = domain_holder
        return true
      end

      def dump
        garbage_collect
        @cookie_map.clone
      end

      def cookie_record_for(document_uri)
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

      def cookie_header_for(document_uri)
        cookie_record_for(document_uri).map do |cookie_record|
          "#{cookie_record[:name]}=#{cookie_record[:value]}"
        end.to_a.join('; ')
      end

      def parse_set_cookie(document_uri, header)
        append_cookie(document_uri, @set_cookie_parser.call(header))
      end

      def garbage_collect
        current_time = @get_current_time.call
        @cookie_map = @cookie_map.map do |domain_name, domain_holder|
          domain_holder.map do |path_name, path_holder|
            path_holder.select do |_cookie_name, cookie_record|
              !cookie_record[:expires] || current_time < cookie_record[:expires]
            end.yield_self do |filtered_result|
              break nil unless filtered_result.present?
              [path_name, filtered_result]
            end
          end.compact.to_h.yield_self do |filtered_result|
            break nil unless filtered_result.present?
            [domain_name, filtered_result]
          end
        end.compact.to_h
        nil
      end

      private

      def compile_effective_cookies(domain_candidates, document_path, &cookie_selector)
        path_candidates = iterate_cookie_path(document_path)
        effective_cookies = {}
        domain_candidates.each do |domain_candidate|
          domain_holder = @cookie_map[domain_candidate]
          next if domain_holder.blank?
          path_candidates.each do |path_candidate|
            path_holder = domain_holder[path_candidate]
            next unless path_holder.present? && path_holder.respond_to?(:select)
            path_holder = path_holder.select(&cookie_selector)
            effective_cookies = path_holder.merge(effective_cookies)
          end
        end
        effective_cookies
      end

      def cookie_for_domain(document_path, is_document_secure, domain_name)
        current_time = @get_current_time.call
        domain_candidates = iterate_cookie_domain(domain_name)
        compile_effective_cookies(domain_candidates, document_path) do |_cookie_name, cookie_record|
          filter_cookie(cookie_record, is_document_secure, current_time) &&
            ((cookie_record[:domain] == domain_name) || cookie_record[:include_subdomains])
        end.values
      end

      def cookie_for_ip_address(document_path, is_document_secure, ip_address)
        current_time = @get_current_time.call
        compile_effective_cookies([ip_address.to_s], document_path) do |_cookie_name, cookie_record|
          filter_cookie(cookie_record, is_document_secure, current_time)
        end.values
      end

      def filter_cookie(cookie_record, is_document_secure, current_time)
        (!cookie_record[:expires] || current_time < cookie_record[:expires]) &&
          (is_document_secure || !cookie_record[:secure])
      end
    end
  end
end
