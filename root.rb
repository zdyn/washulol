require "sinatra/base"
require "sinatra/reloader"
require "sass"
require "coffee-script"
require "facets/integer/ordinal"
require "json"
require "bcrypt"
require_relative "lib/models.rb"

class WashuLOL < Sinatra::Base
  attr_accessor :current_user

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
      self.current_user = user
      session[:email] = user.email
      nil
    end
  end

  get "/?" do
    @title = "Locks of Love at Washington University in St. Louis"
    @articles = Article.all

    erb :test
  end

  # authorization
  before "/admin*" do
    unless session[:email]
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
    session[:email] = false
    redirect "/login"
  end

  post "/authorize/?" do
    authorize_or_401(params[:email], params[:password])
  end

  get "/admin/?" do
    @title += " Home"
    blog_posts = Article.filter(:event_id => nil).limit(5)
    events = Article.exclude(:event_id => nil).limit(5)

    admin_erb :admin, :locals => { :blog_posts => blog_posts, :events => events }
  end

  post "/admin/get_articles" do
    if params[:get_events]
      Article.exclude(:event_id => nil).limit(5, params[:offset])
    else
      Article.filter(:event_id => nil).limit(5, params[:offset])
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

  # helper methods
  def admin_erb(template, options={})
    erb template, options.merge(:layout => :admin_layout)
  end

  def get_article_or_404(id)
    article = Article[params[:id].to_i]
    halt 404, "Could not find article." unless article
    article
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