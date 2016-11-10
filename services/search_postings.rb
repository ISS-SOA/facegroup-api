# frozen_string_literal: true
require 'facegroup'

# Loads data from Facebook group to database
class SearchPostings
  extend Dry::Monads::Either::Mixin

  def self.call(params)
    search = PostingsSearchCriteria.new(params)
    group = Group.find(id: search.group_id)

    validate_and_search(group, search.terms).fmap do |postings_found|
      PostingsSearchResults.new(search.terms, search.group_id, postings_found)
    end
  end

  private_class_method

  def self.validate_and_search(group, search_terms)
    if group
      Right(SearchGroupPostings.call(group, search_terms))
    else
      Left(Error.new(:not_found, 'Group not found'))
    end
  end
end
