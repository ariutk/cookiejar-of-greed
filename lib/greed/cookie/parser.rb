# frozen_string_literal: true
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/time'
require 'memoist'
require 'strscan'
require 'time'

module Greed
  module Cookie
    class Parser
      class << self
        extend ::Memoist

        memoize def _default_kv_matcher
          /\A\s*([-_.+%\d\w]+)=\s*([^;]*)\s*(?:;\s*|\z)/
        end

        memoize def _default_flag_matcher
          /\A\s*([-_\w\d]+)\s*(?:;\s*|\z)/
        end
      end

      def initialize(\
        cookie_matcher: nil,
        attribute_matcher: nil,
        flag_matcher: nil
      )
        @cookie_matcher = cookie_matcher || self.class._default_kv_matcher
        @attribute_matcher = attribute_matcher || self.class._default_kv_matcher
        @flag_matcher = flag_matcher || self.class._default_flag_matcher
        freeze
      end

      def parse(set_cookie_header)
        scanner = ::StringScanner.new(set_cookie_header)
        matched = scanner.scan(@cookie_matcher)
        return nil unless matched
        captured = scanner.captures
        mandatory_parsed = {
          name: captured[0].tap do |cookie_name|
            return nil unless cookie_name.present?
          end,
          value: captured[1],
        }
        flags_parsed = {}
        attributes_parsed = {}
        until scanner.eos? do
          matched = scanner.scan(@flag_matcher)
          if matched
            captured = scanner.captures
            flags_parsed.merge!(
              "#{captured[0].downcase}": true,
            )
            next
          end
          matched = scanner.scan(@attribute_matcher)
          if matched
            captured = scanner.captures
            attributes_parsed.merge!(
              "#{captured[0].downcase}": captured[1],
            )
            next
          end
          return nil
        end
        combine_fragments(
          mandatory_parsed,
          attributes_parsed,
          flags_parsed
        )
      end

      private

      def combine_fragments(\
        mandatory_parsed,
        attributes_parsed,
        flags_parsed
      )
        mandatory_parsed.merge(
          expires: attributes_parsed[:expires].yield_self do |expires|
            ::Time.parse(expires)
          rescue ArgumentError, TypeError
            nil
          end,
          'max-age': attributes_parsed[:'max-age'].yield_self do |max_age|
            Integer(max_age)
          rescue ArgumentError, TypeError
            nil
          end,
          domain: attributes_parsed[:domain].presence.try(:strip),
          path: attributes_parsed[:path].presence.try(:strip),
          samesite: attributes_parsed[:samesite].yield_self do |same_site|
            break 'Lax' unless same_site.present?
            %w[Strict Lax None]
              .lazy
              .select { |enum_value| enum_value.casecmp?(same_site) }
              .first || 'Lax'
          end,
          secure: !!flags_parsed[:secure],
          httponly: !!flags_parsed[:httponly],
        )
      end
    end
  end
end
