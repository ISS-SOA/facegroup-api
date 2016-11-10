# frozen_string_literal: true

# Posting routes
class FaceGroupAPI < Sinatra::Base
  include WordMagic

  get "/#{API_VER}/group/:id/posting/?" do
    results = SearchPostings.call(params)

    if results.success?
      PostingsSearchResultsRepresenter.new(results.value).to_json
    else
      HttpErrorResponder.new(results.value).to_response
    end
  end

  put "/#{API_VER}/posting/:id" do
    result = UpdatePostingFromFB.call(params)

    if result.success?
      PostingRepresenter.new(result.value).to_json
    else
      HttpErrorResponder.new(result.value).to_response
    end
  end
end
