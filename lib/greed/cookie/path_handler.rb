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
      def determine_path(document_path, cookie_path)
        # speed optimization for the common use cases
        if cookie_path.blank? || cookie_path == ?/
          return {
            path: ?/,
          }
        end
        # RFC 6265 5.1.4. base_path must be an absolute path.
        raise PathViolation unless cookie_path.start_with?(?/)
        normalized_cookie_path = ::File.expand_path(?., cookie_path)
        ::Enumerator.new do |yielder|
          ensured_absolute = document_path.sub(/\A\/*/, ?/)
          normalized_document_path = ::File.expand_path(?., ensured_absolute)
          path_fraction = normalized_document_path
          loop do
            yielder << path_fraction
            break if ?/ == path_fraction
            path_fraction = ::File.expand_path('..', path_fraction)
          end
        end.each do |path_candidate|
          if path_candidate == normalized_cookie_path
            return {
              path: normalized_cookie_path,
            }
          end
        end
        raise PathViolation
      end
    end
  end
end
