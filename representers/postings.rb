# frozen_string_literal: true

# Represents overall group information for JSON API output
class PostingsRepresenter < Roar::Decorator
  include Roar::JSON

  collection :postings, extend: PostingRepresenter, class: Posting
end
