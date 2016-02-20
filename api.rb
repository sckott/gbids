require 'rubygems'
require 'sinatra'
require 'faraday'
require "multi_json"
require "sinatra/multi_route"
#require File.join File.dirname(__FILE__), "utils_fxns"

class FBApp < Sinatra::Application
  register Sinatra::MultiRoute

  # before do
  #   puts '[Params]'
  #   p params
  # end

  # before do
  #   puts '[env]'
  #   p env
  # end

  not_found do
    halt 400, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'an error occurred' })
  end

  not_found do
    halt 404, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'route not found' })
  end

  not_found do
    halt 414, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'URL too long, reduce number of IDs or use POST' })
  end

  error 500 do
    halt 500, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'server error' })
  end

  before do
    headers "Content-Type" => "application/json; charset=utf8"
    headers "Access-Control-Allow-Methods" => "HEAD, GET"
    headers "Access-Control-Allow-Origin" => "*"
    cache_control :public, :must_revalidate, :max_age => 60
  end

  # prohibit certain methods
  route :put, :delete, :copy, :options, :trace, '/*' do
    halt 405
  end

  get '/' do
    redirect '/heartbeat'
  end

  get "/heartbeat/?" do
    return MultiJson.dump({
      "routes" => [
        "/match/:identifier",
        "/heartbeat"
      ]
    })
  end

  get '/match/:ids' do
    match_id
  end

  post '/match/?' do
    match_id_post
  end

  # helpers
  def match_id
    ids = params[:ids].gsub(',', '/')
    conn = Faraday.new(:url => 'http://127.0.0.1:7379/MGET/' + ids)
    res = conn.get
    matches = MultiJson.load(res.body)['MGET'].map { |x| !x.nil? }
    res = Hash[params[:ids].split(',').zip matches]
    return MultiJson.dump(res)
  end

  def match_id_post
    #puts params[:ids]
    ids = 'MGET/' + params[:ids].gsub(',', '/')
    #puts 'MGET/' + ids
    conn = Faraday.new(:url => 'http://127.0.0.1:7379')
    res = conn.post do |req|
      req.headers['Content-Type'] = 'text/plain'
      req.body = ids
    end
    matches = MultiJson.load(res.body)['MGET'].map { |x| !x.nil? }
    #puts matches
    res = Hash[params[:ids].split(',').zip matches]
    return MultiJson.dump(res)
  end

end
