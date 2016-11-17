# frozen_string_literal: true
folders = 'config,lib,values,models,representers,queries,services,controllers'
Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
