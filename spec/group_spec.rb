# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Group Routes' do
  SAD_FB_GROUP_ID = '12345'

  before do
    VCR.insert_cassette GROUPS_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Find Group by its Facebook ID' do
    it 'HAPPY: should find a group given a correct id' do
      get "api/v0.1/group/#{app.config.FB_GROUP_ID}"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      group_data = JSON.parse(last_response.body)
      group_data['group_id'].length.must_be :>, 0
      group_data['name'].length.must_be :>, 0
    end

    it 'SAD: should report if a group is not found' do
      get "api/v0.1/group/#{SAD_FB_GROUP_ID}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_FB_GROUP_ID
    end
  end

  describe 'Get the latest feed from a group' do
    it 'HAPPY should find a group feed' do
      get "api/v0.1/group/#{app.config.FB_GROUP_ID}/feed"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      feed_data = JSON.parse(last_response.body)
      feed_data['feed'].count.must_be :>=, 25
    end

    it 'SAD should report if the feed cannot be found' do
      get "api/v0.1/group/#{SAD_FB_GROUP_ID}/feed"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_FB_GROUP_ID
    end
  end
end
