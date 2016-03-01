# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'framework'

require 'minitest/reporters'
require 'minitest/pride'
require 'minitest/autorun'
require 'minitest/focus'
require 'awesome_print'
require 'database_cleaner'

Bundler.require(:default, Framework.env)

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

DatabaseCleaner.strategy = :truncation

class Minitest::Spec
  around do |tests|
    DatabaseCleaner.cleaning(&tests)
  end
end

Framework::Application.new(env: 'test') do |app|
  app.init!
  app.hint("Running tests")
end

# @param name [String]
# @return [String]
def load_fixture(name)
  File.new(File.expand_path("../fixtures/#{name}", __FILE__)).read
end

# @param fixture_name [String]
# @return [Petri::Net]
def load_net(fixture_name)
  Petri::Net.from_string(load_fixture("#{fixture_name}.bpf"))
end
