# frozen_string_literal: true
require 'sinatra'
require 'econfig'
require 'facegroup'

# GroupieAPI web service
class GroupieAPI < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = settings.root

  API_VER = 'v0.1'

  get '/?' do
    "GroupieAPI latest version endpoints are at: /#{API_VER}/"
  end

  get "/#{API_VER}/group/:fb_group_id/?" do
    group = FaceGroup::Group.find(
      id: params[:fb_group_id]
    )

    { group_id: group.id, name: group.name }.to_json
  end

  get "/#{API_VER}/group/:fb_group_id/feed/?" do
    group = FaceGroup::Group.find(
      id: params[:fb_group_id]
    )

    {
      feed: group.feed.postings.map do |post|
        {
          posting: {
            posting_id: post.id
          }
        }
      end
    }.to_json
  end
end
