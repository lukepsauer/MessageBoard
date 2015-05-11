class User < Sequel::Model
  one_to_many :emails
end

class Post < Sequel::Model
  many_to_one :user
  one_to_many :discs
end

class Disc < Sequel::Model
  many_to_one :post
  one_to_one :user
end