# frozen_string_literal: true
require 'sinatra'
require 'sequel'

configure :development do
  ENV['DATABASE_URL'] = 'sqlite://db/dev.db'
end

configure :test do
  ENV['DATABASE_URL'] = 'sqlite://db/test.db'
end

configure :development, :test, :production do
  require 'hirb'
  Hirb.enable
end

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'])
end
