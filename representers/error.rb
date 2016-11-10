# frozen_string_literal: true
require 'json'

# Represents overall group information for JSON API output
class ErrorRepresenter < Roar::Decorator
  property :code
  property :message

  ERROR = {
    cannot_process: 422,
    not_found: 404,
    bad_request: 400
  }.freeze

  def to_status_response
    [ERROR[@represented.code], { errors: [@represented.message] }.to_json]
  end
end
