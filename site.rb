
DB = Sequel.connect("mysql://root@localhost/blog")

require 'models/post'
require 'models/comment'
require 'legacy_routes'

class Site < Sinatra::Base
  set :static, true
  set :public, File.join(File.dirname(__FILE__), "public")
  include LegacyRoutes
  
  helpers do
    def link_to(name, url)
      "<a href='#{url}'>#{name}</a>"
    end
    
    def date(date)
      date.strftime("%b %e, %Y")
    end
  end
  
  
  # THE REAL SITE
  
  get '/' do
    haml :index
  end
  
  get '/posts/:permalink' do
    @post = Post.filter(:permalink => params[:permalink]).first
    haml :post
  end
  
  get '/application.css' do
    sass :application
  end
  
  get '/posts' do
    offset = params[:offset] || 0
    limit  = params[:limit]  || 50
    @posts = Post.order(:created_at).reverse.limit(limit, offset)
    haml :posts
  end
end