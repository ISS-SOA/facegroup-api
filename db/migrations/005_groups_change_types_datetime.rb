# frozen_string_literal: true
require 'sequel'

Sequel.migration do
  change do
    alter_table(:postings) do
      set_column_type :created_time, Time
      set_column_type :updated_time, Time
    end
  end
end
