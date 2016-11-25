# frozen_string_literal: true
require 'sequel'

Sequel.migration do
  change do
    alter_table(:postings) do
      add_column :attachment_media_url, String
    end
  end
end
