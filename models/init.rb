# frozen_string_literal: true
require 'json'
require 'sequel'

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
