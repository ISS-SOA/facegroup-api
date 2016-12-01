# frozen_string_literal: true
require 'sequel'

Sequel.migration do
  up do
    alter_table(:postings) do
      set_column_type :created_time, Time
      set_column_type :updated_time, Time
    end
  end

  down do
    alter_table(:postings) do
      set_column_type :created_time, String
      set_column_type :updated_time, String
    end
  end
end
