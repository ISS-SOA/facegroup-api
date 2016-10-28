# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'vcr'
require 'webmock'

require_relative '../app'

include Rack::Test::Methods

FIXTURES_FOLDER = 'spec/fixtures'
CASSETTES_FOLDER = "#{FIXTURES_FOLDER}/cassettes"
CASSETTE_FILE = 'groups'

def app
  GroupieAPI
end
