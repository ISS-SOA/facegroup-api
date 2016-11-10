# frozen_string_literal: true

# Input for SearchPostings
class UrlRequestRepresenter < Roar::Decorator
  include Roar::JSON

  property :url
end
