# frozen_string_literal: true
require 'rake/testtask'

task :default do
  puts `rake -T`
end

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'delete cassette fixtures'
task :wipe do
  sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
    puts(ok ? 'Cassettes deleted' : 'No casseettes found')
  end
end

namespace :quality do
  CODE = 'app.rb'

  desc 'run all quality checks'
  task all: [:rubocop, :flog, :flay]

  task :flog do
    sh "#{CODE}"
  end

  task :flay do
    sh "#{CODE}"
  end

  task :rubocop do
    sh 'rubocop'
  end
end
