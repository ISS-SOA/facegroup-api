# frozen_string_literal: true
require 'sinatra'
require 'econfig'
require 'facegroup'

# GroupAPI web service
class FaceGroupAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = settings.root
  FaceGroup::FbApi
    .config
    .update(client_id: config.FB_CLIENT_ID,
            client_secret: config.FB_CLIENT_SECRET)

  API_VER = 'api/v0.1'

  get '/?' do
    "GroupAPI latest version endpoints are at: /#{API_VER}/"
  end

  get "/#{API_VER}/group/:fb_group_id/?" do
    group_id = params[:fb_group_id]
    begin
      group = FaceGroup::Group.find(id: group_id)

      content_type 'application/json'
      { group_id: group.id, name: group.name }.to_json
    rescue
      halt 404, "FB Group (id: #{group_id}) not found"
    end
  end

  get "/#{API_VER}/group/:fb_group_id/feed/?" do
    group_id = params[:fb_group_id]
    begin
      group = FaceGroup::Group.find(id: group_id)

      content_type 'application/json'
      {
        feed: group.feed.postings.map do |post|
          posting = { posting_id: post.id }
          posting[:message] = post.message if post.message
          if post.attachment
            posting[:attachment] = {
              title: post.attachment.title,
              url: post.attachment.url,
              description: post.attachment.description
            }
          end

          { posting: posting }
        end
      }.to_json
    rescue
      halt 404, "Cannot group (id: #{group_id}) feed"
    end
  end
end
