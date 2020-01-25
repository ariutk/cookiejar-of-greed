# frozen_string_literal: true
require 'active_support/dependencies/autoload'
require_relative './cookie/version'

module Greed
  module Cookie
    extend ::ActiveSupport::Autoload

    autoload :Error
    autoload :Jar
    autoload :Parser

    'greed/cookie/expiration_handler'.yield_self do |load_path|
      autoload :ExpirationHandler
      autoload :ExpirationError, load_path
      autoload :Expired, load_path
    end

    'greed/cookie/domain_handler'.yield_self do |load_path|
      autoload :DomainHandler
      autoload :DomainError, load_path
      autoload :CrossDomainViolation, load_path
      autoload :MalformedCookieDomain, load_path
    end
  end
end
