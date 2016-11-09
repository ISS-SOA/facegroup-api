# frozen_string_literal: true

# Represents overall group information for JSON API output
class PostingsSearchResultsRepresenter < Roar::Decorator
  include Roar::JSON

  property :search_terms_used
  property :group_id
  collection :postings, extend: PostingRepresenter, class: Posting
end
