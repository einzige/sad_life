require 'minitest/reporters'
require "minitest/pride"
require 'minitest/autorun'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new
