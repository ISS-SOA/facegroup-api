# frozen_string_literal: true
Dir.glob('./{config,lib,models,controllers}/init.rb').each do |file|
  require file
end
