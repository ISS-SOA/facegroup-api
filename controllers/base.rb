# frozen_string_literal: true

# configure based on environment
class FaceGroupAPI < Sinatra::Base
  extend Econfig::Shortcut

  API_VER = 'api/v0.1'

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)
    FaceGroup::FbApi.config.update(client_id: config.FB_CLIENT_ID,
                                   client_secret: config.FB_CLIENT_SECRET)
  end

  get '/?' do
    "GroupAPI latest version endpoints are at: /#{API_VER}/"
  end
end
