
DB = Sequel.connect(ENV["DATABASE_URL"] || "mysql://root@localhost/blog")

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
    load_posts
    haml :posts
  end
  
  def load_posts
    offset = params[:offset] || 0
    limit  = params[:limit]  || 50
    @posts = Post.order(:created_at).filter(:user_id => 1).reverse.limit(limit, offset)
  end
  
  get '/feed/atom.xml' do
    load_posts
    builder do |xml|
      xml.instruct! :xml, :version => '1.0'
      xml.feed :xmlns => "http://www.w3.org/2005/Atom" do
        xml.link :href => "http://blog.hamptoncatlin.com/feed/atom.xml", :rel => "self", :type => "application/atom+xml"
        xml.link :href => "http://www.hamptoncatlin.com", :rel => "alternate", :type => "text/html"
        xml.updated Post.last_update
        xml.id "http://www.hamptoncatlin.com/"
        @posts.each do |post|
          url = "http://www.hamptoncatlin.com/posts/#{post.permalink}"
          xml.entry "xml:base" => "/" do
            xml.author do
              xml.name "Hampton Catlin"
            end
            xml.title post.title
            xml.id url
            xml.published post.published_at
            xml.updated post.updated_at
            xml.link :href => url, :rel => "alternate", :type => "text/html"
            xml.content post.to_html, :type => "html"
          end
        end
      end
    end
  end
  
  get '*' do
    permalink = request.path.split("/").last
    redirect "http://www.hamptoncatlin.com/posts/#{permalink}"
  end
end