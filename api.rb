require 'rubygems'
require 'sinatra'
require "multi_json"
require "sinatra/multi_route"
require 'redis'
#require File.join File.dirname(__FILE__), "utils_fxns"

$redis1 = Redis.new host: ENV.fetch('REDIS_PORT_6379_TCP_ADDR', 'localhost'),
                   port: ENV.fetch('REDIS_PORT_6379_TCP_PORT', 6379)
$redis2 = Redis.new host: ENV.fetch('REDIS_PORT_6380_TCP_ADDR', 'localhost'),
                   port: ENV.fetch('REDIS_PORT_6380_TCP_PORT', 6380)

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
        "/heartbeat",
        "/acc/:accessions (GET)",
        "/acc (POST)",
        "/gi/:gi_numbers (GET)",
        "/gi (POST)",
        "/acc2gi/:accessions (GET)",
        "/acc2gi (POST)",
        "/gi2acc/:gi_numbers (GET)",
        "/gi2acc (POST)",
        "/random/acc?n=",
        "/random/gi?n="
      ]
    })
  end

  # random accession numbers
  get '/random/acc/?' do
    get_random_acc
  end

  # random GI numbers
  get '/random/gi/?' do
    get_random_gi
  end

  # check for accession numbers - GET
  get '/acc/:ids' do
    match_id_acc
  end

  # check for accession numbers - POST
  post '/acc/?' do
    match_id_acc
  end

  # get gi from accession numbers - GET
  get '/acc2gi/:ids' do
    get_gi
  end

  # get gi from accession numbers - GET
  post '/acc2gi/?' do
    get_gi
  end

  # check for gi numbers - GET
  get '/gi/:ids' do
    match_id_gi
  end

  # check for gi numbers - POST
  post '/gi/?' do
    match_id_gi
  end

  # get acc from gi numbers - GET
  get '/gi2acc/:ids' do
    get_acc
  end

  # get acc from gi numbers - GET
  post '/gi2acc/?' do
    get_acc
  end

  # helpers
  def match_id(x)
    ids = params[:ids].split(',')
    out = x.mget(ids)
    matches = out.map { |x| !x.nil? }
    res = Hash[params[:ids].split(',').zip matches]
    return MultiJson.dump(res)
  end

  def match_id_acc
    match_id($redis1)
  end

  def match_id_gi
    match_id($redis2)
  end

  def get_gi
    ids = params[:ids].split(',')
    out = $redis1.mget(ids)
    res = Hash[params[:ids].split(',').zip out]
    return MultiJson.dump(res)
  end

  def get_acc
    ids = params[:ids].split(',')
    out = $redis2.mget(ids)
    res = Hash[params[:ids].split(',').zip out]
    return MultiJson.dump(res)
  end

  def get_random(x)
    n = params[:n] || 10
    res = n.to_i.times.collect { x.randomkey }
    return MultiJson.dump(res)
  end

  def get_random_acc
    get_random($redis1)
  end

  def get_random_gi
    get_random($redis2)
  end

end
