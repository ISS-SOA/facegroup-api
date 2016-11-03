# frozen_string_literal: true
require 'json'
require 'sequel'

# Represents a Group's stored information
class Group < Sequel::Model
  one_to_many :postings
end
