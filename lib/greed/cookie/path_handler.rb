# frozen_string_literal: true
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/time'
require 'time'

module Greed
  module Cookie
    class PathError < Error
    end
    class PathViolation < PathError
    end

    class PathHandler
      include Iterator

      def determine_path(document_path, cookie_path)
        return generate_default_path(document_path) if cookie_path.blank?
        # speed optimization for the common use case
        if cookie_path == ?/
          return {
            path: ?/,
          }
        end
        normalized_cookie_path = ::File.expand_path(?., cookie_path)
        iterate_cookie_path(document_path).each do |path_candidate|
          next unless path_candidate == normalized_cookie_path
          return {
            path: normalized_cookie_path,
          }
        end
        raise PathViolation
      end

      private

      def generate_default_path(document_path)
        # RFC 6265 5.1.4
        if (document_path.blank?) ||
          (!document_path.start_with?(?/))
          return {
            path: ?/,
          }
        end
        {
          path: ::File.expand_path('..', document_path),
        }
      end
    end
  end
end
