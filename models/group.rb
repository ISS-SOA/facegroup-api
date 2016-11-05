# frozen_string_literal: true

# Represents a Group's stored information
class Group < Sequel::Model
  one_to_many :postings
end
