# frozen_string_literal: true
require_relative 'group'

# Represents overall group information for JSON API output
class GroupsRepresenter < Roar::Decorator
  include Roar::JSON

  collection :groups, extend: GroupRepresenter, class: Group
end
