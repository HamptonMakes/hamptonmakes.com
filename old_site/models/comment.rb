
class Comment < Sequel::Model
  many_to_one :post
end