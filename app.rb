# frozen_string_literal: true
require 'sinatra'

# GroupieAPI web service
class GroupieAPI < Sinatra::Base
  API_VER = '0.1'

  get '/?' do
    "GroupieAPI latest version endpoints are at: /v#{API_VER}/"
  end
end
