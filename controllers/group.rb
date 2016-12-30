# frozen_string_literal: true

# GroupAPI web service
class FaceGroupAPI < Sinatra::Base
  FB_GROUP_REGEX = %r{\"fb:\/\/group\/(\d+)\"}

  get "/#{API_VER}/group/?" do
    results = FindGroups.call

    GroupsRepresenter.new(results.value).to_json
  end

  get "/#{API_VER}/group/:id/?" do
    result = FindGroup.call(params)

    if result.success?
      GroupRepresenter.new(result.value).to_json
    else
      HttpResultRepresenter.new(result.value).to_status_response
    end
  end

  get "/#{API_VER}/group/:id/news" do
    result = FindFbGroupUpdates.call(params)

    if result.success?
      PostingsSearchResultsRepresenter.new(result.value).to_json
    else
      HttpResultRepresenter.new(result.value).to_status_response
    end
  end

  post "/#{API_VER}/group/?" do
    url_request = request.body.read
    channel_id = (headers.to_s + url_request.to_s).hash

    begin
      result = CreateNewGroupWorker.perform_async(
        { url_request: url_request,
          channel_id: channel_id }.to_json
      )
    rescue => e
      puts "ERROR: e"
    end
    puts "WORKER: #{result}"
    [202, { channel_id: channel_id }.to_json]
  end
end
