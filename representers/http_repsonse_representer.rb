# frozen_string_literal: true
require 'json'

# Represents overall group information for JSON API output
class HttpResultRepresenter < Roar::Decorator
  property :code
  property :message

  HTTP_CODE = {
    success: 200,
    processing: 202,
    cannot_process: 422,
    not_found: 404,
    bad_request: 400
  }.freeze

  def to_status_response
    [http_code, http_message]
  end

  private

  def http_code
    HTTP_CODE[@represented.code]
  end

  def http_success?
    http_code < 300
  end

  def http_message
    symbol = http_success? ? :messages : :errors
    { symbol => [@represented.message] }.to_json
  end
end
