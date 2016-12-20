# frozen_string_literal: true
require 'sinatra'
require 'econfig'
require 'facegroup'
require 'shoryuken'

require_relative 'base'

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
