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

describe "See all jobs" do
  it "responds with OK to jobs index call" do
    get "/api/v1/jobs"
    last_response.status.must_equal 200
  end
end

describe "See a job" do
  before do
    job = Job.new(name: "Rogue")
    post "/api/v1/jobs", job.to_json
  end

  it "responds with OK to job show call" do
    get "/api/v1/jobs/1"
    last_response.status.must_equal 200
  end
end

describe "Create a job" do
  before do
    @job = Job.new(name: "Rogue")
  end

  it "must increase the job count by one" do
    lambda { post "/api/v1/jobs", @job.to_json }.must_change Job.all, :count, +1
  end

  it "check if the job has been created accordingly" do
    post_data = post "/api/v1/jobs", @job.to_json
    resp = JSON.parse(post_data.body)
    resp["name"].must_equal "Rogue"
  end
end

describe "Edit a job" do
  before do
    @job = Job.new(name: "Quack")
  end

  it "check if the job has been updated accordingly" do
    put_data = put "/api/v1/jobs/2", @job.to_json
    resp = JSON.parse(put_data.body)
    resp["name"].must_equal "Quack"
  end
end

describe "Destroy a job" do
  before do
    @job = Job.new(name: "Quack")
    post "/api/v1/jobs", @job.to_json
  end

  it "must decrease the job count by one" do
    lambda { delete "/api/v1/jobs/2" }.must_change Job.all, :count, -1
    last_response.status.must_equal 200
  end
end