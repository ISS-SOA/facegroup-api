# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Posting Routes' do
  before do
    VCR.insert_cassette POSTINGS_CASSETTE, record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Request to update a post' do
    before do
      FaceGroupAPI::DB[:groups].delete
      FaceGroupAPI::DB[:postings].delete
      post 'api/v0.1/group',
           { url: HAPPY_GROUP_URL }.to_json,
           'CONTENT_TYPE' => 'application/json'
    end

    it '(HAPPY) should update an existing posting' do
      original = Posting.first
      modified = Posting.first
      modified.message = modified.name = modified.attachment_url = nil
      modified.updated_time = modified.created_time = nil
      modified.save
      put "api/v0.1/posting/#{original.id}"
      last_response.status.must_equal 200
      updated = Posting.first
      updated.message.must_equal(original.message)
    end

    it '(BAD) should report error if given invalid posting ID' do
      put "api/v0.1/posting/#{SAD_POSTING_ID}"

      last_response.status.must_equal 400
      last_response.body.must_include SAD_POSTING_ID
    end

    it '(BAD) should report error if stored posting removed from Facebook' do
      original = Posting.first
      original.update(fb_id: REMOVED_FB_POSTING_ID).save

      put "api/v0.1/posting/#{original.id}"

      last_response.status.must_equal 404
      last_response.body.must_include original.id.to_s
    end
  end
end
