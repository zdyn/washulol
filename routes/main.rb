class WashuLOL < Sinatra::Base
  get "/?" do
    @title = "Locks of Love at Washington University in St. Louis"
    @articles = Article.all

    erb :test
  end
end