# frozen_string_literal: true
Dir.glob('./{config,lib,models,decorators,controllers}/init.rb').each do |file|
  require file
end
