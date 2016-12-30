# frozen_string_literal: true
require 'econfig'
require 'shoryuken'

# folders = 'lib,values,config,models,representers,services'
# Dir.glob("../{#{folders}}/init.rb").each do |file|
#   require file
# end

require_relative '../lib/init.rb'
require_relative '../values/init.rb'
require_relative '../config/init.rb'
require_relative '../models/init.rb'
require_relative '../representers/init.rb'
require_relative '../services/init.rb'

class CreateNewGroupWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  ENV['AWS_REGION'] = CreateNewGroupWorker.config.AWS_REGION
  ENV['AWS_ACCESS_KEY_ID'] = CreateNewGroupWorker.config.AWS_ACCESS_KEY_ID
  ENV['AWS_SECRET_ACCESS_KEY'] = CreateNewGroupWorker.config.AWS_SECRET_ACCESS_KEY

  Shoryuken.configure_client do |shoryuken_config|
    shoryuken_config.aws = {
      access_key_id:      CreateNewGroupWorker.config.AWS_ACCESS_KEY_ID,
      secret_access_key:  CreateNewGroupWorker.config.AWS_SECRET_ACCESS_KEY,
      region:             CreateNewGroupWorker.config.AWS_REGION
    }
  end

  FaceGroup::FbApi.config.update(
    client_id:      CreateNewGroupWorker.config.FB_CLIENT_ID,
    client_secret:  CreateNewGroupWorker.config.FB_CLIENT_SECRET
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.GROUP_QUEUE, auto_delete: true

  def perform(_sqs_msg, worker_request)
    request = JSON.parse(worker_request)
    result = LoadGroupFromFB.call(
      request['url_request'],
      api_url: CreateNewGroupWorker.config.API_URL,
      channel: request['channel_id']
    )

    HttpResultRepresenter.new(result.value).to_status_response
  end
end
