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
        purge_expired_cookie
        return false unless cookie_hash.present?
        current_time = @get_current_time.call
        parsed_document_uri = ::URI.parse(document_uri)
        base = cookie_hash.slice(:name, :value)
        domain_attributes = @determine_domain.call(
          parsed_document_uri.host,
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
        purge_expired_cookie
      end

      def parse_set_cookie(document_uri, header)
        store(document_uri, @set_cookie_parser.call(header))
      end

      private

      def purge_expired_cookie
        current_time = @get_current_time.call
        @cookie_map = @cookie_map.map do |domain_name, cookie_names|
          cookie_names.select do |_cookie_name, cookie_value|
            !cookie_value[:expires] || current_time < cookie_value[:expires]
          end.yield_self do |filtered_result|
            [domain_name, filtered_result]
          end
        end.to_h
      end
    end
  end
end
