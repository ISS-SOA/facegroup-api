# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Posting Routes' do
  before do
    VCR.insert_cassette POSTINGS_CASSETTE, record: :new_episodes

    delete_db_data
    LoadGroupFromFB.call({url: HAPPY_GROUP_URL}.to_json)
  end

  after do
    VCR.eject_cassette
  end

  describe 'Get all postings from a group' do
    it '(HAPPY) should find all postings with valid group ID' do
      get "api/v0.1/group/#{Group.first.id}/posting"

      last_response.status.must_equal 200
      last_response.content_type.must_equal 'application/json'
      feed_data = JSON.parse(last_response.body)
      feed_data['postings'].count.must_be :>=, 10
    end

    it '(SAD) should report error if postings cannot be found' do
      get "api/v0.1/group/#{SAD_GROUP_ID}/posting"

      last_response.status.must_equal 404
    end
  end

  describe 'Search postings by keywords' do
    10.times do
      it '(HAPPY) should find valid keyword postings' do
        magic_word = SpecSearch.random_message_word
        group_id = Group.first.id.to_s
        get "api/v0.1/group/#{group_id}/posting?search=#{magic_word[:word]}"
        last_response.status.must_equal 200
        results = JSON.parse(last_response.body)
        results['id'].must_equal group_id
        results['search_terms_used'].count.must_equal 1
        results['postings'].count.must_equal magic_word[:message_count]
      end
    end

    5.times do
      it '(HAPPY) should find valid keyword combination postings' do
        magic_words = Array.new(3) { SpecSearch.random_message_word }
        keywords = magic_words.map { |magic| magic[:word] }.join('+')
        largest_count = magic_words.map { |magic| magic[:message_count] }.max

        group_id = Group.first.id.to_s
        get "api/v0.1/group/#{group_id}/posting?search=#{keywords}"
        last_response.status.must_equal 200
        results = JSON.parse(last_response.body)
        results['id'].must_equal group_id
        results['search_terms_used'].count.must_equal magic_words.count
        results['postings'].count.must_be :>=, largest_count
      end
    end
  end

  describe 'Request to update a post' do
    after do
      delete_db_data
      LoadGroupFromFB.call({url: HAPPY_GROUP_URL}.to_json)
    end

    it '(HAPPY) should successfully update valid posting' do
      original = Posting.first
      modified = Posting.first
      modified.message = modified.name = modified.attachment_url = nil
      modified.updated_time = modified.created_time = nil
      modified.save
      put "api/v0.1/posting/#{original.id}"
      last_response.status.must_equal 200
      updated = Posting.first
      updated.message.must_equal(original.message)
      last_response.body == PostingRepresenter.new(original).to_json
    end

    it '(BAD) should report error if given invalid posting ID' do
      put "api/v0.1/posting/#{SAD_POSTING_ID}"

      last_response.status.must_equal 400
    end

    it '(BAD) should report error if stored posting removed from Facebook' do
      original = Posting.first
      original.update(fb_id: REMOVED_FB_POSTING_ID).save

      put "api/v0.1/posting/#{original.id}"

      last_response.status.must_equal 404
    end
  end

  describe 'Finding Updated Postings on Facebook' do
    before do
      delete_db_data
      LoadGroupFromFB.call({ url: HAPPY_GROUP_URL }.to_json)
    end

    it '(HAPPY) should find new updates when there are some' do
      Group.first.postings.first(5).each(&:destroy)
      get "api/v0.1/group/#{Group.first.id}/news"
      last_response.status.must_equal 200
      news = JSON.parse(last_response.body)
      news['id'].must_equal Group.first.id
      news['postings'].count.must_be :>=, 5
    end
  end
end
