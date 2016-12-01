# frozen_string_literal: true

# Loads data from Facebook group to database
class FindFbGroupUpdates
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :find_db_group, lambda { |params|
    group = Group.find(id: params[:id])
    if group
      Right(group)
    else
      Left(Error.new(:not_found, 'Group not found'))
    end
  }

  register :get_latest_postings, lambda { |group|
    begin
      latest_postings = FaceGroup::Group.latest_postings(id: group.fb_id)
      Right(group: group, latest_postings: latest_postings)
    rescue => e
      puts e
      Left(Error.new(:not_found, 'Cannot check news from Facebook group'))
    end
  }

  register :check_new_postings, lambda { |compare_data|
    begin
      news = fb_db_postings_difference(
        compare_data[:latest_postings],
        GroupLatestPostingTimeQuery.call(compare_data[:group].id)
      )
      Right(group_id: compare_data[:group].id, fb_postings: news)
    rescue
      Left(Error.new(:not_found, 'We had an error comparing data to Facebook'))
    end
  }

  register :create_postings_results, lambda { |news|
    begin
      postings = news[:fb_postings].map do |p|
        Posting.new(fb_id: p['id'],
                    message: p['message'], updated_time: p['updated_time'])
      end
      results = PostingsSearchResults.new(news[:group_id], postings)
      Right(results)
    rescue
      Left(Error.new(:not_found, 'Could not parse Facebook posting data'))
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :find_db_group
      step :get_latest_postings
      step :check_new_postings
      step :create_postings_results
    end.call(params)
  end

  private_class_method

  def self.fb_db_postings_difference(latest_postings, last_db_posting_time)
    latest_postings.select do |posting|
      Time.parse(posting['updated_time']) > last_db_posting_time
    end
  end
end
