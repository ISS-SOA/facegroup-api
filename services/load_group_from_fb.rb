# frozen_string_literal: true
require 'facegroup'

# Loads data from Facebook group to database
class LoadGroupFromFB
  extend Dry::Monads::Either::Mixin

  FB_GROUP_REGEX = %r{\"fb:\/\/group\/(\d+)\"}

  def self.call(url_request)
    scrape_fb_group_id(url_request).bind do |fb_group_id|
      if Group.find(fb_id: fb_group_id)
        Left(Error.new(:cannot_process, 'Group already exists'))
      else
        fb_group = FaceGroup::Group.find(id: fb_group_id)
        Right(create_group_postings(fb_group))
      end
    end
  end

  private_class_method

  def self.scrape_fb_group_id(url_request)
    group_html(url_request).bind do |fb_group_html|
      group_id_match = fb_group_html.match(FB_GROUP_REGEX)
      if group_id_match
        Right(group_id_match[1])
      else
        Left(Error.new(:cannot_process, 'URL not recognized as Facebook group'))
      end
    end
  end

  def self.group_html(url_request)
    body_params = JSON.parse url_request
    fb_group_url = body_params['url']
    Right(HTTP.get(fb_group_url).body.to_s)
  rescue
    Left(Error.new(:bad_request, 'URL could not be resolved'))
  end

  def self.create_group_postings(fb_group)
    group = Group.create(fb_id: fb_group.id, name: fb_group.name)
    fb_group.feed.postings.each do |fb_posting|
      write_group_posting(group, fb_posting)
    end
    group
  end

  def self.write_group_posting(group, fb_posting)
    group.add_posting(
      fb_id:                    fb_posting.id,
      created_time:             fb_posting.created_time,
      updated_time:             fb_posting.updated_time,
      message:                  fb_posting.message,
      name:                     fb_posting.name,
      attachment_title:         fb_posting.attachment&.title,
      attachment_description:   fb_posting.attachment&.description,
      attachment_url:           fb_posting.attachment&.url
    )
  end
end
