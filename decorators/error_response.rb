# frozen_string_literal: true
require 'json'

# Represents overall group information for JSON API output
class HttpErrorResponder < SimpleDelegator
  ERROR = {
    cannot_process: 422,
    not_found: 404,
    bad_request: 400
  }.freeze

  def to_response
    [ERROR[code], { errors: [message] }.to_json]
  end
end
