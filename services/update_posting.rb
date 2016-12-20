# frozen_string_literal: true

# Loads data from Facebook group to database
class UpdatePostingFromFB
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :find_posting, lambda { |params|
    posting_id = params[:id]
    posting = Posting.find(id: posting_id)
    if posting
      Right(posting)
    else
      Left(HttpResult.new(:bad_request, 'Posting is not stored'))
    end
  }

  register :validate_posting, lambda { |posting|
    updated_data = FaceGroup::Posting.find(id: posting.fb_id)
    if updated_data.nil?
      Left(HttpResult.new(:not_found, 'Posting not found on Facebook anymore'))
    else
      Right(posting: posting, updated_data: updated_data)
    end
  }

  register :update_posting, lambda { |input|
    Right(update_posting(input[:posting], input[:updated_data]))
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :find_posting
      step :validate_posting
      step :update_posting
    end.call(params)
  end

  private_class_method

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
