class Race
  include DataMapper::Resource
  has n, :heroes
  property :id, Serial
  property :name, String, required: true
end