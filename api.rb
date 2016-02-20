require 'rubygems'
require 'sinatra'
require "multi_json"
require "sinatra/multi_route"
require 'redis'
#require File.join File.dirname(__FILE__), "utils_fxns"

$redis = Redis.new host: ENV.fetch('REDIS_PORT_6379_TCP_ADDR', 'localhost'),
                   port: ENV.fetch('REDIS_PORT_6379_TCP_PORT', 6379)

class FBApp < Sinatra::Application
  register Sinatra::MultiRoute

  not_found do
    halt 400, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'an error occurred' })
  end

  not_found do
    halt 404, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'route not found' })
  end

  error 500 do
    halt 500, {'Content-Type' => 'application/json'}, MultiJson.dump({ 'error' => 'server error' })
  end

  before do
    headers "Content-Type" => "application/json; charset=utf8"
    headers "Access-Control-Allow-Methods" => "HEAD, GET, POST"
    headers "Access-Control-Allow-Origin" => "*"
    cache_control :public, :must_revalidate, :max_age => 60
  end

  # prohibit certain methods
  route :put, :delete, :copy, :options, :trace, '/*' do
    halt 405
  end

  get '/' do
    redirect '/heartbeat', 301
  end

  get "/heartbeat/?" do
    return MultiJson.dump({
      "routes" => [
        "/match/:identifier (GET)",
        "/match (POST)",
        "/random?n=",
        "/heartbeat"
      ]
    })
  end

  get '/random/?' do
    get_random
  end

  get '/match/:ids' do
    match_id
  end

  post '/match/?' do
    match_id
  end

  # helpers
  def match_id
    ids = params[:ids].split(',')
    out = $redis.mget(ids)
    matches = out.map { |x| !x.nil? }
    res = Hash[params[:ids].split(',').zip matches]
    return MultiJson.dump(res)
  end

  def get_random
    n = params[:n] || 10
    res = n.to_i.times.collect { $redis.randomkey }
    return MultiJson.dump(res)
  end

end
