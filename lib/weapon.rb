class Weapon
  include DataMapper::Resource
  has n, :heroes
  property :id, Serial
  property :name, String, required: true
  property :desc, Text, required: true, length: 255

end