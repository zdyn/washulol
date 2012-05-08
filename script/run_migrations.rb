require_relative "../config/environment.rb"

puts `sequel -m migrations/ "mysql2://#{DB_USER}@#{DB_HOST}/#{DB_NAME}"`