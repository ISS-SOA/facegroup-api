# frozen_string_literal: true

# GroupAPI web service
class FaceGroupAPI < Sinatra::Base
  FB_GROUP_REGEX = %r{\"fb:\/\/group\/(\d+)\"}

  get "/#{API_VER}/group/:id/?" do
    group_id = params[:id]
    begin
      group = Group.find(id: group_id)

      content_type 'application/json'
      { id: group.id, name: group.name }.to_json
    rescue
      content_type 'text/plain'
      halt 404, "FB Group (id: #{group_id}) not found"
    end
  end

  # Body args (JSON) e.g.: {"url": "http://facebook.com/groups/group_name"}
  post "/#{API_VER}/group/?" do
    begin
      body_params = JSON.parse request.body.read
      fb_group_url = body_params['url']
      fb_group_html = HTTP.get(fb_group_url).body.to_s
      fb_group_id = fb_group_html.match(FB_GROUP_REGEX)[1]

      if Group.find(fb_id: fb_group_id)
        halt 422, "Group (id: #{fb_group_id})already exists"
      end

      fb_group = FaceGroup::Group.find(id: fb_group_id)
    rescue
      content_type 'text/plain'
      halt 400, "Group (url: #{fb_group_url}) could not be found"
    end

    begin
      group = Group.create(fb_id: fb_group.id, name: fb_group.name)

      fb_group.feed.postings.each do |fb_posting|
        Posting.create(
          group_id:       group.id,
          fb_id:          fb_posting.id,
          created_time:   fb_posting.created_time,
          updated_time:   fb_posting.updated_time,
          message:        fb_posting.message,
          name:           fb_posting.name,
          attachment_title:         fb_posting.attachment&.title,
          attachment_description:   fb_posting.attachment&.description,
          attachment_url:           fb_posting.attachment&.url
        )
      end

      content_type 'application/json'
      { group_id: group.id, name: group.name }.to_json
    rescue
      content_type 'text/plain'
      halt 500, "Cannot create group (id: #{fb_group_id})"
    end
  end
end
