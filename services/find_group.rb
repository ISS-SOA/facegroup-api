# frozen_string_literal: true
require 'facegroup'
require 'dry-monads'

# Loads data from Facebook group to database
class FindGroup
  extend Dry::Monads::Either::Mixin

  def self.call(params)
    group = Group.find(id: params[:id])
    if group
      Right(group)
    else
      Left(Error.new(:not_found, 'FB Group not found'))
    end
  end
end
