# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'greed/cookie/version'

Gem::Specification.new do |spec|
  spec.name = 'cookiejar_of_greed'
  spec.version = ::Greed::Cookie::VERSION
  spec.author = 'Sarun Rattanasiri'
  spec.email = 'midnight_w@gmx.tw'
  spec.license = 'BSD-3-Clause'

  spec.summary = 'A compatibility-first cookiejar implementation'
  spec.description = 'Cookiejar of greed is an implementation of cookiejar '\
    'focused on browser compatibility and loosely based on the standard.'
  spec.homepage = 'https://github.com/midnight-wonderer'
  # spec.metadata = {
  #   'source_code_uri' => "https://gitlab.com/slime-systems/midnight-enterprise-toolkit/tree/v#{version}/midnight-business_logic"
  # }

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'memoist'
  spec.add_dependency 'public_suffix'
end
