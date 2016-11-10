# frozen_string_literal: true
require 'facegroup'

# Loads data from Facebook group to database
class UpdatePostingFromFB
  extend Dry::Monads::Either::Mixin

  def self.call(params)
    posting_id = params[:id]
    posting = Posting.find(id: posting_id)
    if posting
      validate_and_update(posting)
    else
      Left(Error.new(:bad_request, 'Posting is not stored'))
    end
  end

  private_class_method

  def self.validate_and_update(posting)
    updated_data = FaceGroup::Posting.find(id: posting.fb_id)
    if updated_data.nil?
      Left(Error.new(:not_found, 'Posting not found on Facebook anymore'))
    else
      Right(update_posting(posting, updated_data))
    end
  end

  def self.update_posting(posting, updated_data)
    posting.update(
      created_time:             updated_data.created_time,
      updated_time:             updated_data.updated_time,
      message:                  updated_data.message,
      name:                     updated_data.name,
      attachment_title:         updated_data.attachment&.title,
      attachment_description:   updated_data.attachment&.description,
      attachment_url:           updated_data.attachment&.url
    )
    posting.save
  end
end
