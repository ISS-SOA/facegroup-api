# frozen_string_literal: true
require 'facegroup'

# Input for SearchPostings
class PostingsSearchCriteria
  attr_accessor :group_id, :terms

  def initialize(params)
    @group_id = params[:id]
    @terms = reasonable_search_terms(params[:search])
  end
end

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
      Right(search_group(group, search_terms))
    else
      Left(Error.new(:not_found, 'Group not found'))
    end
  end

  def self.search_group(group, search_terms)
    search_terms&.any? ? search_postings(search_terms) : group.postings
  end

  def self.search_postings(search_terms)
    Posting.where(where_clause(search_terms)).all
  end

  def self.where_clause(search_terms)
    search_terms.map do |term|
      Sequel.ilike(:message, "%#{term}%")
    end.inject(&:|)
  end
end
