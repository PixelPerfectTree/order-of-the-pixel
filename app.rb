# encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'json'
require 'data_mapper'
require 'puma'
require "sinatra/namespace"
require "sinatra/base"
require 'debugger'
require 'haml'

configure :development, :test, :production do
  register ::Sinatra::Namespace
  set :protection, true
  # Allows local requests such as Postman (Chrome extension):
  set :protection, origin_whitelist: ["chrome-extension://fdmmgilgnpjigdojojpjoooidkmcomcm", "http://127.0.0.1"]
  set :protect_from_csrf, true
  set :server, :puma
  # Local Sqlite (Development):
  # set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/test.sqlite3"
end

# Live Postgres for Heroku (Production):
#DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_AMBER_URL'] || 'postgres://localhost/mydb')
# Local SQlite Locally (Development):
DataMapper.setup(:default, "sqlite::memory:")


# Main classes for the order of the pixel API.
class Hero
  include DataMapper::Resource
  belongs_to :weapon
  belongs_to :job
  belongs_to :race
  property :id, Serial
  property :name, String, required: true
end

class Weapon
  include DataMapper::Resource
  has n, :heroes
  property :id, Serial
  property :name, String, required: true
  property :desc, Text, required: true, length: 255
end

class Race
  include DataMapper::Resource
  has n, :heroes
  property :id, Serial
  property :name, String, required: true
end

class Job
  include DataMapper::Resource
  has n, :heroes
  property :id, Serial
  property :name, String, required: true
end

DataMapper.finalize
DataMapper.auto_migrate!

# Example data.
Job.create(name: 'Paladin')
Race.create(name: 'Human')
Weapon.create(name: 'Mithril Hammer', desc: "The almighty Thor Hammer, gives +10 to all stats")
Hero.create(name: 'Thor', weapon_id: 1, job_id: 1, race_id: 1)

get '/' do
  haml :index
end

get '/readme' do
  redirect "https://github.com/PixelPerfectTree/order-of-the-pixel"
end

# Namespacing the API for version one.
namespace '/api/v1' do

  # Index
  get '/heroes' do
    heroes = Hero.all
    heroes.to_json
  end

  # Show
  get '/heroes/:id' do
    hero = Hero.get(params[:id])
    if hero.nil?
      halt 404
    end
    hero.to_json
  end

  # Create
  post '/heroes' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)

    if data.nil? || data['name'].nil?
      halt 400
    end

    hero = Hero.new(name: params[:name], weapon_id: params[:weapon_id], job_id: params[:job_id], race_id: params[:race_id])

    halt 500 unless hero.save
    status 201
    hero.to_json
  end

  # Update
  put '/heroes/:id' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)
    hero ||= Hero.get(params[:id]) || halt(404)
    halt 500 unless hero.update(
      name:    params[:name],
    )
    hero.to_json
  end

  # Delete
  delete '/heroes/:id' do
    hero ||= Hero.get(params[:id]) || halt(404)
    halt 404 if hero.nil?

    if hero.destroy
      "Your hero with an id of #{hero.id} has died with honour."
    else
      halt 500
    end
  end

  # Weapon routes

  # Index
  get '/weapons' do
    weapons = Weapon.all
    weapons.to_json
  end

  # Show
  get '/weapons/:id' do
    weapon = Weapon.get(params[:id])
    if weapon.nil?
      halt 404
    end
    weapon.to_json
  end

  # Create
  post '/weapons' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)

    if data.nil? || data['name'].nil?
      halt 400
    end

    weapon = Weapon.new(name: params[:name], desc: params[:desc])

    halt 500 unless weapon.save
    [201, {'Location' => "/weapon/#{weapon.id}"}, weapon.to_json]
  end

  # Update
  put '/weapons/:id' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)
    weapon ||= Weapon.get(params[:id]) || halt(404)
    halt 500 unless weapon.update(
      name:    params[:name],
    )
    weapon.to_json
  end

  # Delete
  delete '/weapons/:id' do
    weapon ||= Weapon.get(params[:id]) || halt(404)
    halt 404 if weapon.nil?

    if weapon.destroy
      "Your weapon with an id of #{weapon.id} has been reduced to ashes!."
    else
      status 500
      body "The weapon with an id of #{weapon.id} doesn't exist or is related to a hero and can't be deleted."
    end
  end

  # RACE routes
  # Index
  get '/races' do
    races = Race.all
    races.to_json
  end

  # Show
  get '/races/:id' do
    race = Race.get(params[:id])
    if race.nil?
      halt 404
    end
    race.to_json
  end

  # Create
  post '/races' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)

    if data.nil? || data['name'].nil?
      halt 400
    end

    race = Race.new(name: params[:name])

    halt 500 unless race.save
    [201, {'Location' => "/race/#{race.id}"}, race.to_json]
  end

  # Update
  put '/races/:id' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)
    race ||= Race.get(params[:id]) || halt(404)
    halt 500 unless race.update(
      name:    params[:name],
    )
    race.to_json
  end

  # Delete
  delete '/races/:id' do
    race ||= Race.get(params[:id]) || halt(404)
    halt 404 if race.nil?

    if race.destroy
      "The race with an id of #{race.id} is now extinct."
    else
      status 500
      body "The race with an id of #{race.id} doesn't exist or is related to a hero and can't be deleted."
    end
  end

  # JOB routes

  # Index
  get '/jobs' do
    jobs = Job.all
    jobs.to_json
  end

  # Show
  get '/jobs/:id' do
    job = Job.get(params[:id])
    if job.nil?
      halt 404
    end
    job.to_json
  end

  # Create
  post '/jobs' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)

    if data.nil? || data['name'].nil?
      halt 400
    end

    job = Job.new(name: params[:name])

    halt 500 unless job.save
    [201, {'Location' => "/job/#{job.id}"}, job.to_json]
  end

  # Show
  put '/jobs/:id' do
    json = request.body.read.to_json
    data = JSON.parse(json, :quirks_mode => true)
    job ||= Job.get(params[:id]) || halt(404)
    halt 500 unless job.update(
      name:    params[:name],
    )
    job.to_json
  end

  # Delete
  delete '/jobs/:id' do
    job ||= Job.get(params[:id]) || halt(404)

    if job.destroy
      "Your job with an id of #{job.id} has been eliminated."
    else
      status 500
      body "The job with an id of #{job.id} doesn't exist or is related to a hero and can't be deleted."
    end
  end

  before do
    content_type 'application/json'
    headers["X-CSRF-Token"] = session[:csrf] ||= SecureRandom.hex(32)
    # To allow Cross Domain XHR
    if request.env["HTTP_ORIGIN"]
    headers["Access-Control-Allow-Origin"] ||= request.env["HTTP_ORIGIN"]
    end
     
  end
end
