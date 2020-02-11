# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'greed/cookie/version'

Gem::Specification.new do |spec|
  version = ::Greed::Cookie::VERSION

  spec.name = 'cookiejar_of_greed'
  spec.version = version
  spec.author = 'Sarun Rattanasiri'
  spec.email = 'midnight_w@gmx.tw'
  spec.license = 'BSD-3-Clause'

  spec.required_ruby_version = '>= 2.5.0'

  spec.summary = 'A compatibility-first cookiejar implementation'
  spec.description = 'Cookiejar of greed is an implementation of cookiejar '\
    'focused on browser compatibility and loosely based on the standard.'
  spec.homepage = 'https://github.com/the-cave/cookiejar-of-greed'
  spec.metadata = {
    'source_code_uri' => "https://github.com/the-cave/cookiejar-of-greed/tree/v#{version}"
  }

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'memoist'
  spec.add_dependency 'public_suffix'
end
