require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/unit_test/**{,/*/**}/*_spec.rb'
end

task default: :spec
