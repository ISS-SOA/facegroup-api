require 'sinatra'
require 'econfig'

# configure based on environment
class FaceGroupAPI < Sinatra::Base
  extend Econfig::Shortcut

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = settings.root
    FaceGroup::FbApi.config.update(client_id: config.FB_CLIENT_ID,
                                   client_secret: config.FB_CLIENT_SECRET)
    DB = Sequel.connect(config.DATABASE_URL)
  end

  configure :development, :production do
    require 'hirb'
    Hirb.enable
  end
end
