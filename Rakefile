require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

require 'puppet-doc-lint/rake_task'
PuppetDocLint.configuration.ignore_paths = exclude_paths

require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetSyntax.exclude_paths = exclude_paths
PuppetSyntax.future_parser = true if ENV['FUTURE_PARSER'] == 'true'

[
  '80chars',
  'class_inherits_from_params_class',
  'class_parameter_defaults',
  'documentation',
  'single_quote_string_with_variables',
  'resource_reference_without_whitespace'
].each do |check|
  PuppetLint.configuration.send("disable_#{check}")
end

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

desc 'Run integration tests'
RSpec::Core::RakeTask.new('beaker:integration') do |c|
  c.pattern = 'spec/integration/integration*.rb'
end
