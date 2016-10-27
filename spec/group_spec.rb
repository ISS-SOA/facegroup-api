# frozen_string_literal: true
require_relative 'spec_helper'

describe 'Group Routes' do
  it 'should successfully find configuration information' do
    Groupie.config.group_id.length.must_be :>, 0
  end
end
