# frozen_string_literal: true
require 'sinatra'
require 'econfig'
require 'facegroup'

ENV['RACK_ENV'] ||= 'development'
Econfig.env = ENV['RACK_ENV']
Econfig.root = File.dirname(__FILE__)

# Groupie service space
module Groupie
  extend Econfig::Shortcut

  # GroupieAPI web service
  class API < Sinatra::Base
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
end
