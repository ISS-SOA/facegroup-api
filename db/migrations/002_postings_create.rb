# frozen_string_literal: true
require 'sequel'

Sequel.migration do
  change do
    create_table(:postings) do
      primary_key :id
      foreign_key :group_id

      String :fb_id
      Time :created_time
      Time :updated_time
      String :message
      String :name
      String :attachment_url
      String :attachment_title
      String :attachment_description
    end
  end
end
