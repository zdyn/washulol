require "sinatra/base"
require "sinatra/reloader"
require "sass"
require "coffee-script"
require "facets/integer/ordinal"
require "json"
require "bcrypt"
require "RMagick"

require_relative "lib/models.rb"
require_relative "config/environment.rb"

class WashuLOL < Sinatra::Base
  enable :sessions

  set :environment, :development

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def authorize_or_401(email, password)
      user = User.filter(:email => email).first
      unless user && BCrypt::Engine.hash_secret(password, user.salt) == user.password
        halt 401, "Not authorized."
      end
      session[:user] = user
      session[:request] = nil
      nil
    end
  end

  # authorization
  before "/admin*" do
    unless session[:user]
      halt 401, "Not authorized." if request.request_method != "GET"
      session[:request] = request.fullpath
      redirect "/login"
    end
    @title = "Administration:"
  end

  get "/login/?" do
    erb :login, :locals => { :request => session[:request] }, :layout => false
  end

  get "/logout/?" do
    session[:user] = false
    redirect "/login"
  end

  post "/authorize/?" do
    authorize_or_401(params[:email], params[:password])
  end

  get "/admin/?" do
    @title += " Home"
    blog_posts = Article.filter(:category => "BLOG").limit(5)
    events = Article.filter(:category => "EVENTS").limit(5)
    albums = Article.filter(:category => "PHOTOS").limit(5)

    admin_erb :admin, :locals => { :blog_posts => blog_posts,
                                   :events => events,
                                   :albums => albums }
  end

  get "/admin/settings/?" do
    @title += " Settings"
    users = Users.all

    admin_erb :settings, :locals => { :users => users }
  end

  post "/admin/get_articles" do
    case params[:type]
      when "blog_posts"
        Article.select(:id, :title, :public).filter(:category => "BLOG").limit(5, params[:offset]).to_json
      when "events"
        Article.select(:id, :title, :public).filter(:category => "EVENTS").limit(5, params[:offset]).to_json
      when "albums"
        Article.select(:id, :title, :public).filter(:category => "PHOTOS").limit(5, params[:offset]).to_json
      else
        nil
    end
  end

  # generate an article preview
  post "/admin/article_preview" do
    article = Article[params[:id].to_i]
    if article.nil?
      article = Article.new
      article.created_at = Time.now
    end
    article.title = params[:title]
    article.post = params[:post]
    # TODO: fill in event info

    erb :_article, :locals => { :article => article }, :layout => false
  end

  get "/admin/blog_post/?" do
    @title += " New Blog Post"
    blog_post = Article.new

    admin_erb :blog_post_form, :locals => { :blog_post => blog_post }
  end

  get "/admin/blog_post/:id/?" do
    @title += " Edit Blog Post"
    blog_post = get_article_or_404(params[:id].to_i)

    admin_erb :blog_post_form, :locals => { :blog_post => blog_post }
  end

  post "/admin/save_blog_post/?" do
    if params[:id].length > 0
      blog_post = get_article_or_404(params[:id].to_i)
      [:title, :post, :public].each do |val|
        blog_post[val] = params[val]
      end
      blog_post.save
    else
      blog_post = Article.create(:title => params[:title],
                                 :post => params[:post],
                                 :category => "BLOG",
                                 :public => params[:public])
    end
    { :id => blog_post[:id], :url => "/admin/blog_post/#{blog_post[:id]}" }.to_json
  end

  post "/admin/delete_blog_post/?" do
    halt 404, "No id was provided." if params[:id].nil?
    blog_post = get_article_or_404(params[:id].to_i)
    blog_post.delete
    nil
  end

  get "/admin/event/?" do
    @title += " New Event"
    event = Article.new

    admin_erb :event_form, :locals => { :event => event }
  end

  get "/admin/album/?" do
    @title += " New Photo Album"
    album = Article.new

    admin_erb :album_form, :locals => { :album => album }
  end

  get "/admin/album/:id/?" do
    @title += " Edit Photo Album"
    album = get_article_or_404(params[:id].to_i)

    admin_erb :album_form, :locals => { :album => album }
  end

  post "/admin/save_album/?" do
    if params[:id].length > 0
      album = get_article_or_404(params[:id].to_i)
      [:title, :post, :public].each do |val|
        album[val] = params[val]
      end
      album.save
    else
      album = Article.create(:title => params[:title],
                             :post => params[:post],
                             :category => "PHOTOS",
                             :public => params[:public])
    end
    { :id => album[:id], :url => "/admin/album/#{album[:id]}" }.to_json
  end

  # generate an album preview
  post "/admin/album_preview" do

  end

  post "/admin/upload_photos" do
    unless params[:files]
      halt 400, "Could not read images."
    end
    thumbs = []
    # create the album directory if it doesn't exist
    album = get_article_or_404(params[:id].to_i)
    album_dirname = create_album_directory_name(album[:title], album[:id])
    Dir.mkdir(album_dirname) unless File.directory?(album_dirname)
    # resize the image if necessary and create thumbnails
    params[:files].each do |file|
      photo = Photo.create(:article_id => album[:id])
      filename = file[:tempfile].path
      format = get_extension(file[:type])
      File.rename(filename, "#{filename}.#{format}")
      img = Magick::Image::read("#{filename}.#{format}").first
      img_width = img.columns.to_f
      img_height = img.rows.to_f
      if img_width > 1000 || img_height > 1000
        img.resize_to_fit!(1000, 1000)
      end
      img.write(File.join(album_dirname, photo.filename(false)))
      min_width = THUMBNAIL_WIDTH
      min_height = THUMBNAIL_HEIGHT
      if img_width / img_height > min_width / min_height
        min_width = min_height * img_width / img_height
      else
        min_height = min_width * img_height / img_width
      end
      thumb = img.resize_to_fit(min_width, min_height)
      thumb.write(File.join(album_dirname, photo.filename(true)))
      thumbs.push({
        :filename => thumb.filename.split("/").slice(-2, 2).join("/"),
        :width => thumb.columns,
        :height => thumb.rows
      })
    end
    thumbs.to_json
  end

  # helper methods
  def admin_erb(template, options={})
    erb template, options.merge(:layout => :admin_layout)
  end

  def get_article_or_404(id)
    article = Article[params[:id].to_i]
    halt 404, "Could not find article." unless article
    article
  end

  def create_album_directory_name(title, id)
    File.join(ALBUMS_DIR, title.delete("^a-zA-Z0-9 ").downcase().split("\s").push(id).join("-"))
  end

  def get_extension(type)
    case type
      when "image/jpeg" then return "jpg"
      when "image/png" then return "png"
    end
  end

  # compile static files for development
  get "/css/:filename.css" do
    asset_path = "public/css/#{params[:filename]}.scss"
    content_type "text/css", :charset => "utf-8"
    Sass::Engine.new(File.read(asset_path), :syntax => :scss,
                                            :style => :compact).render()
  end

  get "/js/:filename.js" do
    asset_path = "public/js/#{params[:filename]}.coffee"
    next unless FileTest.exists?(asset_path)
    content_type "application/javascript", :charset => "utf-8"
    CoffeeScript.compile(File.read(asset_path))
  end
end

require_relative "routes/main.rb"
require_relative "routes/login.rb"