# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Group Routes' do
  before do
    VCR.insert_cassette GROUPS_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Get a list of all groups' do
    before do
      delete_db_data
      LoadGroupFromFB.call({url: HAPPY_GROUP_URL}.to_json)
    end

    it 'should return a list of groups' do
      get 'api/v0.1/group'
      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      groups_data = JSON.parse(last_response.body)

      groups_data['groups'].count.must_be :>=, 1
      groups_data['groups'].first['name'].length.must_be :>=, 1
    end
  end

  describe 'Find stored group by its id' do
    before do
      delete_db_data
      LoadGroupFromFB.call({url: HAPPY_GROUP_URL}.to_json)
    end

    it '(HAPPY) should find a group given a correct id' do
      get "api/v0.1/group/#{Group.first.id}"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      group_data = JSON.parse(last_response.body)
      group_data['id'].must_be :>, 0
      group_data['name'].length.must_be :>, 0
    end

    it '(SAD) should report error for invalid group id' do
      get "api/v0.1/group/#{SAD_GROUP_ID}"

      last_response.status.must_equal 404
    end
  end

  describe 'Loading and saving a new group by its URL' do
    before do
      delete_db_data
    end

    it '(HAPPY) should load and save a new group by its Facebook URL' do
      post 'api/v0.1/group',
           { url: HAPPY_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'

      last_response.status.must_equal 202

      ## Do NOT test actual DB insertion: use separate test for worker
      # body = JSON.parse(last_response.body)
      # body.must_include 'id'
      # body.must_include 'name'
      # sleep(1)

      # Group.count.must_equal 1
      # Posting.count.must_be :>=, 10
    end

    it '(BAD) should report error if given invalid URL' do
      post 'api/v0.1/group',
           { url: SAD_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'
      last_response.status.must_equal 422
    end

    it 'should report error if group already exists' do
      LoadGroupFromFB.call({url: HAPPY_GROUP_URL}.to_json)
      post 'api/v0.1/group',
           { url: HAPPY_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'

      last_response.status.must_equal 422
    end

    it '(BAD) should report error for an invalid group URL' do
      post 'api/v0.1/group',
           { url: BAD_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'
      last_response.status.must_equal 400
    end
  end
end
