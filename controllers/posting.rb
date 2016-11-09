# frozen_string_literal: true

# Posting routes
class FaceGroupAPI < Sinatra::Base
  include WordMagic

  get "/#{API_VER}/group/:id/posting/?" do
    group_id = params[:id]
    search_terms = reasonable_search_terms(params[:search])
    begin
      group = Group.find(id: group_id)
      halt 400, "FB Group (id: #{group_id}) not found" unless group

      relevant_postings =
        if search_terms&.any?
          where_clause = search_terms.map do |term|
            Sequel.ilike(:message, "%#{term}%")
          end.inject(&:|)

          Posting.where(where_clause).all
        else
          group.postings
        end

      results = PostingsSearchResults.new(
        search_terms, group_id, relevant_postings
      )

      content_type 'application/json'
      results.to_h.to_json
    rescue
      content_type 'text/plain'
      halt 500, "FB Group (id: #{group_id}) could not be processed"
    end
  end

  put "/#{API_VER}/posting/:id" do
    begin
      posting_id = params[:id]
      posting = Posting.find(id: posting_id)
      halt 400, "Posting (id: #{posting_id}) is not stored" unless posting
      updated_posting = FaceGroup::Posting.find(id: posting.fb_id)
      if updated_posting.nil?
        halt 404, "Posting (id: #{posting_id}) not found on Facebook"
      end

      posting.update(
        created_time:             updated_posting.created_time,
        updated_time:             updated_posting.updated_time,
        message:                  updated_posting.message,
        name:                     updated_posting.name,
        attachment_title:         updated_posting.attachment&.title,
        attachment_description:   updated_posting.attachment&.description,
        attachment_url:           updated_posting.attachment&.url
      )
      posting.save

      content_type 'application/json'
      PostingRepresenter.new(posting).to_json
    rescue
      content_type 'text/plain'
      halt 500, "Cannot update posting (id: #{posting_id})"
    end
  end
end
