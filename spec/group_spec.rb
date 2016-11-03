# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Group Routes' do
  before do
    VCR.insert_cassette GROUPS_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Find Group by its id' do
    before do
      # TODO: find a better way to populate group!
      FaceGroupAPI::DB[:groups].delete
      FaceGroupAPI::DB[:postings].delete
      post 'api/v0.1/group',
           { url: HAPPY_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'
    end

    it '(HAPPY) should find a group given a correct id' do
      get "api/v0.1/group/#{Group.first.id}"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      group_data = JSON.parse(last_response.body)
      group_data['id'].must_be :>, 0
      group_data['name'].length.must_be :>, 0
    end

    it '(SAD) should report if a group is not found' do
      get "api/v0.1/group/#{SAD_GROUP_ID}"

      last_response.status.must_equal 404
      last_response.body.must_include SAD_GROUP_ID
    end
  end

  describe 'Get postings from a group' do
    before do
      # TODO: find a better way to populate group!
      FaceGroupAPI::DB[:groups].delete
      FaceGroupAPI::DB[:postings].delete
      post 'api/v0.1/group',
           { url: HAPPY_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'
    end

    it '(HAPPY) should find postings with valid group ID' do
      get "api/v0.1/group/#{Group.first.id}/posting"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      feed_data = JSON.parse(last_response.body)
      feed_data['postings'].count.must_be :>=, 10
    end

    it '(SAD) should report error postings cannot be found' do
      get "api/v0.1/group/#{SAD_GROUP_ID}/posting"

      last_response.status.must_equal 400
      last_response.body.must_include SAD_GROUP_ID
    end
  end

  describe 'Loading and saving a new group by ID' do
    before do
      FaceGroupAPI::DB[:groups].delete
      FaceGroupAPI::DB[:postings].delete
    end

    it '(HAPPY) should load and save a new group by its Facebook URL' do
      post 'api/v0.1/group',
           { url: HAPPY_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'

      last_response.status.must_equal 200
      body = JSON.parse(last_response.body)
      body.must_include 'name'
      body.must_include 'group_id'

      Group.count.must_equal 1
      Posting.count.must_be :>=, 10
    end

    it '(BAD) should report error if given invalid URL' do
      post 'api/v0.1/group',
           { url: SAD_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'

      last_response.status.must_equal 400
      last_response.body.must_include SAD_GROUP_URL
    end

    it 'should report error if group already exists' do
      2.times do
        post 'api/v0.1/group',
             { url: HAPPY_GROUP_URL }.to_json,
             'CONTENT_TYPE' => 'application/json'
      end

      last_response.status.must_equal 422
    end
  end
end
