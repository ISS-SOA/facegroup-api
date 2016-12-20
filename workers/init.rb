# frozen_string_literal: true
Dir.glob("#{File.dirname(__FILE__)}/*_worker.rb").each do |file|
  require file
end
