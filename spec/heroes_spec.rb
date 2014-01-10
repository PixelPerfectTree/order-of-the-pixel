ENV['RACK_ENV'] = 'test'
gem "minitest"
require 'rack/test'
require 'minitest/autorun'
require_relative '../app.rb'
require_relative 'helpers.rb'

# Custom methods to simulate Rspec’s “expect {}.to change {}.by(x)”.
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "See all heroes" do
  it "responds with OK to hero index call" do
    get "/api/v1/heroes"
    last_response.status.must_equal 200
  end
end

describe "See a hero" do
  before do
    hero = Hero.new(name: "Mindless Zombie", weapon_id: 1, job_id: 1, race_id: 1)
    post "/api/v1/heroes", hero.to_json
  end

  it "responds with OK to hero show call" do
    get "/api/v1/heroes/1"
    last_response.status.must_equal 200
  end
end

describe "Create a hero" do
  before do
    @hero = Hero.new(name: "Mindless Zombie", weapon_id: 1, job_id: 1, race_id: 1)
  end

  it "must increase the hero count by one" do
    lambda { post "/api/v1/heroes", @hero.to_json }.must_change Hero.all, :count, +1
  end

  it "check if the hero has been created accordingly" do
    post_data = post "/api/v1/heroes", @hero.to_json
    resp = JSON.parse(post_data.body)
    resp["name"].must_equal "Mindless Zombie"
    resp["weapon_id"].must_equal 1
    resp["race_id"].must_equal 1
    resp["job_id"].must_equal 1
  end
end

describe "Edit a hero" do
  before do
    @hero = Hero.new(name: "Zeus",weapon_id: 1, job_id: 1, race_id: 1)
  end

  it "check if the hero has been updated accordingly" do
    put_data = put "/api/v1/heroes/1", @hero.to_json
    put_data.status.must_equal 200
    
    resp = JSON.parse(put_data.body)
    resp["name"].must_equal "Zeus"
  end
end

describe "Destroy a hero" do
  before do
    @hero = Hero.new( name: "Mindless Zombie",
      weapon_id: 1,
      job_id: 1,
      race_id: 1 )
      post "/api/v1/heroes", @data.to_json
  end

  it "must decrease the hero count by one" do
    lambda { delete "/api/v1/heroes/1" }.must_change Hero.all, :count, -1
    last_response.status.must_equal 200
  end
end