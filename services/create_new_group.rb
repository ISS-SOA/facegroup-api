# frozen_string_literal: true

# Loads data from Facebook group to database
class CreateNewGroup
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  def self.call(params)
    Dry.Transaction(container: self) do
      step :save_group_and_postings_data
      step :add_postings
    end.call(params)
  end

  register :save_group_and_postings_data, lambda { |fb_id|
    begin
      grp_info = { api_data: FaceGroup::Group.find(id: fb_id) }
      grp_info[:group] = Group.create(
        fb_id: grp_info[:api_data].id,
        name: grp_info[:api_data].name,
        fb_url: grp_info[:url]
      )
      Right(grp_info)
    rescue => e
      puts "ERROR: #{e}"
      Left(HttpResult.new(:cannot_process, 'Facebook details error'))
    end
  }

  register :add_postings, lambda { |grp_info|
    grp_info[:api_data].feed.postings.each do |fb_posting|
      add_group_postings(grp_info[:group], fb_posting)
    end
    Right(HttpResult.new(:success, "Group '#{grp_info[:group].name}' created"))
  }

  private_class_method

  def self.add_group_postings(group, fb_posting)
    group.add_posting(
      fb_id:                    fb_posting.id,
      created_time:             fb_posting.created_time,
      updated_time:             fb_posting.updated_time,
      message:                  fb_posting.message,
      name:                     fb_posting.name,
      attachment_title:         fb_posting.attachment&.title,
      attachment_description:   fb_posting.attachment&.description,
      attachment_url:           fb_posting.attachment&.url,
      attachment_media_url:     fb_posting.attachment&.media_url
    )
  end
end
