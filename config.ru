require "rubygems"
require "sinatra"
require 'multi_json'
require 'faraday'

map '/' do
	require File.join( File.dirname(__FILE__), 'api.rb')
	run FBApp
end
