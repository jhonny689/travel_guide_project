require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "db/development.sqlite3"
)

ActiveRecord::Base.logger = Logger.new(STDOUT)
require 'dotenv/load'
require 'rest-client'
require 'json'
require 'pry'
require_all 'app'