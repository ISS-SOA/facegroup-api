# frozen_string_literal: true
require 'sequel'

Sequel.migration do
  change do
    alter_table(:groups) do
      add_column :fb_url, String
    end
  end
end
