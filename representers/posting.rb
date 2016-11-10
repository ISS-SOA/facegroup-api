# frozen_string_literal: true

# Represents overall group information for JSON API output
class PostingRepresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :group_id, type: String
  property :created_time
  property :updated_time
  property :message
  property :attachment_url
  property :attachment_title
  property :attachment_description
end
