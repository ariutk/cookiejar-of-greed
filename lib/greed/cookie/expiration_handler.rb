# frozen_string_literal: true
require 'active_support/core_ext/time'
require 'time'

module Greed
  module Cookie
    class ExpirationError < Error
    end
    class Expired < ExpirationError
    end

    class ExpirationHandler
      def calculate_expiration(current_time, max_age, expires)
        {
          expires: if max_age
            current_time + max_age.seconds
          else
            expires
          end,
          retrieved_at: current_time,
        }.tap do |tapped|
          tapped_expires = tapped[:expires]
          return tapped unless tapped_expires # keep session cookie
          raise Expired unless (current_time < tapped_expires) # reject expired cookie
        end
      end
    end
  end
end
