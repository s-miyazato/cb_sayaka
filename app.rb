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


client = PG::connect(
  :host => "localhost",
  :user => ENV.fetch("USER", "s.miyazato"), :password => '',
  :dbname => "cb_sayaka")

# ログインページ
get '/login' do
  @title = 'ログイン'
  return erb :login, :layout => :login_layout
end

post '/login' do
  email = params[:email]
  password = params[:password]
  user = client.exec_params(
    "SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1",
    [email, password]
  ).to_a.first
  if user.nil?
    @title = 'ログイン'
    return erb :login, :layout => :login_layout
  else
    session[:user] = user
    return redirect '/initial-registration'
  end
end

delete '/signout' do
  session[:user] = nil
  return redirect '/login'
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