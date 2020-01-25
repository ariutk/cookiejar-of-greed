require 'active_support/dependencies/autoload'
# require_relative 'business_logic/version'

module Greed
  extend ::ActiveSupport::Autoload
  autoload :Cookie
end
