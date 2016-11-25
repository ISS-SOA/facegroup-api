# frozen_string_literal: true

# Represents overall group information for JSON API output
class GroupRepresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :name
  property :fb_url
end
