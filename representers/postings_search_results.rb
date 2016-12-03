# frozen_string_literal: true
require_relative 'posting'

# Represents overall group information for JSON API output
class PostingsSearchResultsRepresenter < Roar::Decorator
  include Roar::JSON

  property :search_terms_used
  property :id
  property :name
  property :fb_url
  collection :postings, extend: PostingRepresenter, class: Posting
end
