require 'rubygems'
require "sinatra"
require "multi_json"
require "yaml"
require "sinatra/multi_route"
require "active_record"
require "redis"
require "mysql2"
require_relative 'model'
require_relative 'utils'

$config = YAML::load_file(File.join(__dir__, ENV['RACK_ENV'] == 'test' ? 'test_config.yaml' : 'config.yaml'))

ActiveRecord::Base.establish_connection($config['db'])

$redis = Redis.new host: ENV.fetch('REDIS_PORT_6379_TCP_ADDR', 'localhost'),
                   port: ENV.fetch('REDIS_PORT_6379_TCP_PORT', 6379)

class GBApp < Sinatra::Application
  register Sinatra::MultiRoute

  before do
    puts '[Params]'
    p params
  end

  # before do
  #   puts '[params[:ids]]'
  #   p params[:ids]
  # end

  # before do
  #   puts 'REQUEST_METHOD+request.path/+paramsids'
  #   p env['REQUEST_METHOD'] + request.path + '/' + params[:ids]
  # end

  before do
    puts '[Env]'
    p env
  end

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

    case env['REQUEST_METHOD']
    when 'GET'
      cache_string = env['REQUEST_METHOD'] + env['REQUEST_URI']
    when 'POST'
      cache_string = env['REQUEST_METHOD'] + env['REQUEST_URI'] + '/' + params[:ids]
    end

    if $config['caching']
      @cache_key = Digest::MD5.hexdigest(cache_string)
      if $redis.exists(@cache_key)
        headers 'Cache-Hit' => 'true'
        halt 200, $redis.get(@cache_key)
      end
    end
  end

  after do
    # cache response in redis
    if $config['caching'] && !response.headers['Cache-Hit'] && response.status == 200
      $redis.set(@cache_key, response.body[0], ex: $config['caching']['expires'])
    end
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
        "/acc (GET)",
        "/acc/:accessions (GET)",
        "/acc (POST)",
        "/gi (GET)",
        "/gi/:gi_numbers (GET)",
        "/gi (POST)",
        "/acc2gi/:accessions (GET)",
        "/acc2gi (POST)",
        "/gi2acc/:gi_numbers (GET)",
        "/gi2acc (POST)"
      ]
    })
  end

  # get accession numbers - GET
  get '/acc/?' do
    get_accs(params)
  end

  # get accession numbers - GET
  get '/gi/?' do
    get_gis(params)
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

  # get gi from accession numbers - POST
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

  # get acc from gi numbers - POST
  post '/gi2acc/?' do
    get_acc
  end

end
