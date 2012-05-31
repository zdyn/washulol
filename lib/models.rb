require "sequel"

require_relative "../config/environment.rb"

# connect to the database
DB = Sequel.connect(:host => DB_HOST, :user => DB_USER, :password => DB_PASSWORD, :database => DB_NAME,
                    :port => DB_PORT, :adapter => "mysql2")

Sequel::Model.plugin :association_dependencies
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :json_serializer

require_relative "../models/article.rb"
require_relative "../models/event.rb"
require_relative "../models/photo_preview.rb"
require_relative "../models/user.rb"
require_relative "../models/photo.rb"