# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'vcr'
require 'webmock'

require './init.rb'

include Rack::Test::Methods

def app
  FaceGroupAPI
end

FIXTURES_FOLDER = 'spec/fixtures'
CASSETTES_FOLDER = "#{FIXTURES_FOLDER}/cassettes"
GROUPS_CASSETTE = 'groups'
POSTINGS_CASSETTE = 'postings'

VCR.configure do |c|
  c.cassette_library_dir = CASSETTES_FOLDER
  c.hook_into :webmock

  c.filter_sensitive_data('<ACCESS_TOKEN>') do
    URI.unescape(app.config.FB_ACCESS_TOKEN)
  end

  c.filter_sensitive_data('<ACCESS_TOKEN_ESCAPED>') do
    app.config.FB_ACCESS_TOKEN
  end

  c.filter_sensitive_data('<CLIENT_ID>') { ENV['FB_CLIENT_ID'] }
  c.filter_sensitive_data('<CLIENT_SECRET>') { ENV['FB_CLIENT_SECRET'] }
end

HAPPY_GROUP_URL = 'https://www.facebook.com/groups/ISS.SOAD'
SAD_GROUP_URL = 'https://www.facebook.com/groups/whatisthisidonteven'
BAD_GROUP_URL = 'htt://www.facebook'

SAD_GROUP_ID = '00000'
SAD_POSTING_ID = '13245_12324'
REMOVED_FB_POSTING_ID = '13245_12324'

# Helper class
class SpecSearch
  extend WordMagic

  def self.random_message_word
    reasonable_words = SpecSearch.reasonable_search_terms(terms_from_postings)
    word = reasonable_words.sample
    message_count = Posting.all.select { |p| p.message =~ /#{word}/i }.count
    { word: word, message_count: message_count }
  end

  private_class_method

  def self.terms_from_postings
    messages = Posting.all.map(&:message).join(' ')
    messages.gsub(/[^a-zA-Z]/, ' ')
            .downcase.split(' ')
            .uniq.join('+')
  end
end
