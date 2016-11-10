# frozen_string_literal: true

# Input for SearchPostings
class PostingsSearchCriteria
  include WordMagic

  attr_accessor :group_id, :terms

  def initialize(params)
    @group_id = params[:id]
    @terms = reasonable_search_terms(params[:search])
  end
end
