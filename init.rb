# frozen_string_literal: true
folders = 'config,lib,values,models,representers,queries,services,controllers,workers'
Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
