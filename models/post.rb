
class Post < Sequel::Model
  one_to_many :comments
  
  def author_name
    if user_id == 1
      "Hampton Catlin"
    else
      db[:users].filter(:id => user_id).first[:login]
    end
  end
  
  def to_html
    self.body_html
  end
  
  def self.last_update
    Post.order(:updated_at).last.updated_at
  end
end