module LegacyRoutes
  def self.included(klass)
    old_host = "blog.hamptoncatlin.com"
    klass.get("/", :host => old_host) do 
      redirect "http://www.hamptoncatlin.com/posts"
    end
    klass.get("/feed/atom.xml", :host => old_host) do
      redirect "http://www.hamptoncatlin.com/feed/atom.xml"
    end
    klass.get("*", :host => old_host) do
      permalink = request.path.split("/").last
      redirect "http://www.hamptoncatlin.com/posts/#{permalink}"
    end
  end
end