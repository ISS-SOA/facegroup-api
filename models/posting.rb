# frozen_string_literal: true
require 'json'
require 'sequel'

# Represents a Group's stored information
class Posting < Sequel::Model
  many_to_one :group
end
