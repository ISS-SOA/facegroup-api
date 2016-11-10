# frozen_string_literal: true

# Search query for postings in a group by optional keywords
class SearchGroupPostings
  def self.call(group, search_terms)
    search_terms&.any? ? search_postings(group, search_terms) : group.postings
  end

  private_class_method

  def self.search_postings(group, search_terms)
    Posting.where(where_clause(search_terms), group_id: group.id).all
  end

  def self.where_clause(search_terms)
    search_terms.map do |term|
      Sequel.ilike(:message, "%#{term}%")
    end.inject(&:|)
  end
end
