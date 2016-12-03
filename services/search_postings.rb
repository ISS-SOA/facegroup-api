# frozen_string_literal: true

# Loads data from Facebook group to database
class SearchPostings
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :validate_params, lambda { |params|
    search = PostingsSearchCriteria.new(params)
    group = Group.find(id: search.group_id)
    if group
      Right(group: group, search: search)
    else
      Left(Error.new(:not_found, 'Group not found'))
    end
  }

  register :search_postings, lambda { |input|
    postings = GroupPostingsQuery.call(input[:group], input[:search].terms)
    results = PostingsSearchResults.new(
      input[:search].group_id, input[:group].name,
      input[:group].fb_url, postings, input[:search].terms
    )
    Right(results)
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :validate_params
      step :search_postings
    end.call(params)
  end
end
