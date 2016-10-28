# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Group Routes' do
  it 'should successfully find configuration information' do
    Groupie.config.group_id.length.must_be :>, 0
  end

  it 'should find a group' do
    get "v0.1/group/#{Groupie.config.group_id}"

    last_response.status.must_equal 200
    group_data = JSON.parse(last_response.body)
    group_data['group_id'].length.must_be :>, 0
    group_data['name'].length.must_be :>, 0
  end

  it 'should find a group feed' do
    get "v0.1/group/#{Groupie.config.group_id}/feed"

    last_response.status.must_equal 200
  end
end
