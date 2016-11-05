# frozen_string_literal: true

# Represents a Posting's stored information
class Posting < Sequel::Model
  many_to_one :group
end
