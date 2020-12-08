require 'sinatra'
require 'sinatra/reloader'
require "pry"
require 'sinatra/cookies'
require 'pg'

enable :sessions

# client = PG::connect(
#   :host => ENV.fetch("DB_HOST", "localhost"),
#   :user => ENV.fetch("DB_USER"), :password => ENV.fetch("DB_PASSWORD"),
#   :dbname => ENV.fetch("DB_NAME"))

# ページ表示
get '/login' do
  @title = 'ログイン'
  return erb :login, :layout => :login_layout
end

get '/initial-registration' do
  @title = '新規登録'
  return erb :initial_registration, :layout => :login_layout
end

get '/profile' do
  @title = 'プロフィール'
  return erb :profile
end

get '/design' do
  @title = 'デザイン登録'
  return erb :design
end