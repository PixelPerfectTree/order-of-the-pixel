ENV['RACK_ENV'] = 'test'
gem "minitest"
require 'rack/test'
require 'minitest/autorun'
require_relative '../app.rb'
require_relative 'helpers.rb'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "See all weapons" do
  it "responds with OK to wepaons index call" do
    get "/api/weapons"
    last_response.status.must_equal 200
  end
end

describe "See a weapon" do
  before do
    data = {name: "Bastard Sword",
     desc: "Worn by the bravest, adds +1 agility"}
    post "/api/weapons", data
  end

  it "responds with OK to weapon show call" do
    get "/api/weapons/1"
    last_response.status.must_equal 200
  end
end


describe "Create a weapon" do
  before do
    @data = {name: "Bastard Sword",
     desc: "Worn by the bravest, adds +1 agility"}
  end

  it "must increase the weapon count by one" do
    lambda { post "/api/weapons", @data }.must_change Weapon.all, :count, +1
  end

  it "check if the weapon has been created accordingly" do
    post_data = post "/api/weapons", @data
    resp = JSON.parse(post_data.body)
    resp["name"].must_equal "Bastard Sword"
    resp["desc"].must_equal "Worn by the bravest, adds +1 agility"
  end
end

describe "Edit a weapon" do
  before do
    @data = {name: "Bastard Sword",
     desc: "Worn by the bravest, adds +1 agility"}
  end

  it "check if the weapon has been updated accordingly" do
    put_data = put "/api/weapons/2", @data
    resp = JSON.parse(put_data.body)
    resp["name"].must_equal "Bastard Sword"
    resp["desc"].must_equal "Worn by the bravest, adds +1 agility"
  end
end

describe "Destroy a weapon" do
  before do
    @data = {name: "Bastard Sword",
     desc: "Worn by the bravest, adds +1 agility"}
    post "/api/weapons", @data
  end

  it "must decrease the weapon count by one" do
    lambda { delete "/api/weapons/2" }.must_change Weapon.all, :count, -1
    last_response.status.must_equal 200
  end
end