# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadGroupFromFB
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  FB_GROUP_ID_REGEX = %r{\"fb:\/\/group\/(\d+)\"}

  register :validate_request_json, lambda { |request_body|
    begin
      url_representation = UrlRequestRepresenter.new(UrlRequest.new)
      Right(url_representation.from_json(request_body))
    rescue
      Left(Error.new(:bad_request, 'URL could not be resolved'))
    end
  }

  register :validate_request_url, lambda { |body_params|
    if (fb_group_url = body_params['url']).nil?
      Left(:cannot_process, 'URL not supplied')
    else
      Right(fb_group_url)
    end
  }

  register :retrieve_fb_group_html, lambda { |fb_group_url|
    begin
      grp_info = { url: fb_group_url,
                   html: HTTP.get(fb_group_url).body.to_s }
      Right(grp_info)
    rescue
      Left(Error.new(:bad_request, 'URL could not be resolved'))
    end
  }

  register :parse_fb_group_id, lambda { |grp_info|
    grp_info[:fb_id] = grp_info[:html].match(FB_GROUP_ID_REGEX)&.[](1)
    if grp_info[:fb_id].nil?
      Left(Error.new(:cannot_process, 'URL not recognized as Facebook group'))
    else
      Right(grp_info)
    end
  }

  register :retrieve_group_and_postings_data, lambda { |grp_info|
    if Group.find(fb_id: grp_info[:fb_id])
      Left(Error.new(:cannot_process, 'Group already exists'))
    else
      grp_info[:api_data] = FaceGroup::Group.find(id: grp_info[:fb_id])
      Right(grp_info)
    end
  }

  register :create_group_and_postings, lambda { |grp_info|
    group = Group.create(fb_id: grp_info[:api_data].id,
                         name: grp_info[:api_data].name,
                         fb_url: grp_info[:url])
    grp_info[:api_data].feed.postings.each do |fb_posting|
      write_group_posting(group, fb_posting)
    end
    Right(group)
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :validate_request_json
      step :validate_request_url
      step :retrieve_fb_group_html
      step :parse_fb_group_id
      step :retrieve_group_and_postings_data
      step :create_group_and_postings
    end.call(params)
  end

  private_class_method

  def self.write_group_posting(group, fb_posting)
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
