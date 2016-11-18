# frozen_string_literal: true

# Loads data from Facebook group to database
class FindGroups
  extend Dry::Monads::Either::Mixin

  def self.call
    if (groups = Group.all).nil?
      Left(Error.new(:not_found, 'No groups found'))
    else
      Right(Groups.new(groups))
    end
  end
end
