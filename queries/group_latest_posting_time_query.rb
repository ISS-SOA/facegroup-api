# frozen_string_literal: true

# Search query for postings in a group by optional keywords
class GroupLatestPostingTimeQuery
  def self.call(group_id)
    Time.parse(latest_posting_on_group(group_id))
  end

  private_class_method

  def self.latest_posting_on_group(group_id)
    Posting.where(group_id: group_id).max(:updated_time)
  end
end
