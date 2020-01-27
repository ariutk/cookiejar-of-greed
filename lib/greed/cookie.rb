# frozen_string_literal: true
require 'active_support/dependencies/autoload'
require_relative './cookie/version'

module Greed
  module Cookie
    extend ::ActiveSupport::Autoload

    autoload :Error
    autoload :Jar
    autoload :Parser
    autoload :Iterator

    'greed/cookie/expiration_handler'.tap do |load_path|
      autoload :ExpirationHandler
      autoload :ExpirationError, load_path
      autoload :Expired, load_path
    end

    'greed/cookie/domain_handler'.tap do |load_path|
      autoload :DomainHandler
      autoload :DomainError, load_path
      autoload :CrossDomainViolation, load_path
      autoload :MalformedCookieDomain, load_path
    end

    'greed/cookie/path_handler'.tap do |load_path|
      autoload :PathHandler
      autoload :PathError, load_path
      autoload :PathViolation, load_path
    end
  end
end
