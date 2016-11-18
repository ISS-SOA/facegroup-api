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
      ErrorRepresenter.new(result.value).to_status_response
    end
  end

  # Body args (JSON) e.g.: {"url": "http://facebook.com/groups/group_name"}
  post "/#{API_VER}/group/?" do
    result = LoadGroupFromFB.call(request.body.read)

    if result.success?
      GroupRepresenter.new(result.value).to_json
    else
      ErrorRepresenter.new(result.value).to_status_response
    end
  end
end
