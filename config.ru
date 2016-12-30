# frozen_string_literal: true
require './init.rb'

require 'faye'
use Faye::RackAdapter, :mount => '/faye', :timeout => 25
run FaceGroupAPI
