# frozen_string_literal: true
require 'sinatra'
require 'econfig'

Econfig.root = File.dirname(__FILE__)

# Groupie service space
module Groupie
  extend Econfig::Shortcut

  # GroupieAPI web service
  class API < Sinatra::Base
    API_VER = '0.1'

    get '/?' do
      "GroupieAPI latest version endpoints are at: /v#{API_VER}/"
    end
  end
end
