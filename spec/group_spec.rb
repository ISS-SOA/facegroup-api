# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Group Routes' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<ACCESS_TOKEN>') do
      URI.unescape(Groupie.config.FB_ACCESS_TOKEN)
    end

    c.filter_sensitive_data('<ACCESS_TOKEN_ESCAPED>') do
      ENV['FB_ACCESS_TOKEN']
    end

    c.filter_sensitive_data('<CLIENT_ID>') { ENV['FB_CLIENT_ID'] }
    c.filter_sensitive_data('<CLIENT_SECRET>') { ENV['FB_CLIENT_SECRET'] }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  it 'should successfully find configuration information' do
    Groupie.config.FB_GROUP_ID.length.must_be :>, 0
  end

  it 'should find a group' do
    get "v0.1/group/#{Groupie.config.FB_GROUP_ID}"

    last_response.status.must_equal 200
    group_data = JSON.parse(last_response.body)
    group_data['group_id'].length.must_be :>, 0
    group_data['name'].length.must_be :>, 0
  end

  it 'should find a group feed' do
    get "v0.1/group/#{Groupie.config.FB_GROUP_ID}/feed"

    last_response.status.must_equal 200
    feed_data = JSON.parse(last_response.body)
    feed_data['feed'].count.must_be :>=, 25
  end
end
