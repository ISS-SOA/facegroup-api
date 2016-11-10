# frozen_string_literal: true

# Loads data from Facebook group to database
class FindGroup
  extend Dry::Monads::Either::Mixin

  def self.call(params)
    if (group = Group.find(id: params[:id])).nil?
      Left(Error.new(:not_found, 'FB Group not found'))
    else
      Right(group)
    end
  end
end
