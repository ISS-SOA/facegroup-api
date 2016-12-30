# frozen_string_literal: true

# Loads data from Facebook group to database
class LoadGroupFromFB
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  FB_GROUP_ID_REGEX = %r{\"fb:\/\/group\/(\d+)\"}

  def self.call(params, api_url: nil, channel: nil)
    sleep_until_client_starts
    request_info = {
      request_json: params,
      api_url: api_url,
      channel: channel
    }

    Dry.Transaction(container: self) do
      step :validate_request_json
      step :validate_request_url
      step :retrieve_fb_group_html
      step :parse_fb_group_id
      step :check_conflicting_group
      step :save_group_and_postings_data
      step :add_postings
    end.call(request_info)
  end

  register :validate_request_json, lambda { |request_info|
    begin
      url_representation = UrlRequestRepresenter.new(UrlRequest.new)
      url_request = url_representation.from_json(request_info[:request_json])
      request_info[:fb_group_url] = url_request['url']

      publish(request_info, '10')
      Right(request_info)
    rescue
      publish(request_info, 'URL could not be resolved')
      Left(HttpResult.new(:bad_request, 'URL could not be resolved'))
    end
  }

  register :validate_request_url, lambda { |request_info|
    if request_info[:fb_group_url].nil?
      publish(request_info, 'URL not supplied')
      Left(:cannot_process, 'URL not supplied')
    else
      publish(request_info, '20')
      Right(request_info)
    end
  }

  register :retrieve_fb_group_html, lambda { |request_info|
    begin
      request_info[:html] = HTTP.get(request_info[:fb_group_url]).body.to_s
      publish(request_info, '30')
      Right(request_info)
    rescue
      publish(request_info, 'URL could not be found')
      Left(HttpResult.new(:bad_request, 'URL could not be found'))
    end
  }

  register :parse_fb_group_id, lambda { |request_info|
    request_info[:fb_id] = request_info[:html].match(FB_GROUP_ID_REGEX)&.[](1)
    if request_info[:fb_id].nil?
      publish(request_info, 'URL not recognized as Facebook group')
      Left(HttpResult.new(:cannot_process, 'URL not recognized as Facebook group'))
    else
      publish(request_info, '40')
      Right(request_info)
    end
  }

  register :check_conflicting_group, lambda { |request_info|
    if Group.find(fb_id: request_info[:fb_id])
      publish(request_info, 'Group already exists')
      Left(HttpResult.new(:cannot_process, 'Group already exists'))
    else
      publish(request_info, '50')
      Right(request_info)
    end
  }

  register :save_group_and_postings_data, lambda { |request_info|
    begin
      request_info[:api_data] = FaceGroup::Group.find(id: request_info[:fb_id])
      request_info[:group] = Group.create(
        fb_id: request_info[:api_data].id,
        name: request_info[:api_data].name,
        fb_url: request_info[:fb_group_url]
      )

      publish(request_info, '60')
      Right(request_info)
    rescue => e
      publish(request_info, 'Facebook details error')
      Left(HttpResult.new(:cannot_process, 'Facebook details error'))
    end
  }

  register :add_postings, lambda { |request_info|
    request_info[:api_data].feed.postings.each do |fb_posting|
      add_group_postings(request_info[:group], fb_posting)
    end

    publish(request_info, '100')
    Right(HttpResult.new(:success, "Group created"))
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

  def self.publish(request_info, message)
    return unless request_info[:channel]
    puts "#{request_info[:channel]}: #{message}"
    HTTP.headers('Content-Type' => 'application/json')
        .post("#{request_info[:api_url]}/faye",
              json: {
                channel: "/#{request_info[:channel]}",
                data: message
              })
  end

  def self.sleep_until_client_starts
    sleep(0.5)
  end
end
