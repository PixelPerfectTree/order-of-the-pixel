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

describe "See all races" do
  it "responds with OK to races index call" do
    get "/api/races"
    last_response.status.must_equal 200
  end
end

describe "See a race" do
  before do
    data = {name: "Elf"}
    post "/api/races", data
  end

  it "responds with OK to race show call" do
    get "/api/races/1"
    last_response.status.must_equal 200
  end
end

describe "Create a race" do
  before do
    @data = {name: "Elf"}
  end

  it "must increase the race count by one" do
    lambda { post "/api/races", @data }.must_change Race.all, :count, +1
  end

  it "check if the race has been created accordingly" do
    post_data = post "/api/races", @data
    resp = JSON.parse(post_data.body)
    resp["name"].must_equal "Elf"
  end
end

describe "Edit a race" do
  before do
    @data = {name: "Elf"}
  end

  it "check if the race has been updated accordingly" do
    put_data = put "/api/races/2", @data
    resp = JSON.parse(put_data.body)
    resp["name"].must_equal "Elf"
  end
end

describe "Destroy a race" do
  before do
    @data = { name: "Elf"}
    post "/api/races", @data
  end

  it "must decrease the race count by one" do
    lambda { delete "/api/races/2" }.must_change Race.all, :count, -1
    last_response.status.must_equal 200
  end
end