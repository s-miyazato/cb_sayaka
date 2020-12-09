require 'sinatra'
require 'sinatra/reloader'
require "pry"
require 'sinatra/cookies'
require 'pg'

enable :sessions

client = PG::connect(
  :host => "localhost",
  :user => ENV.fetch("USER", "s.miyazato"), :password => '',
  :dbname => "cb_sayaka")


# ログインページ
get '/' do
  @title = 'ログイン'
  return erb :login, :layout => :login_layout
end

post '/' do
  email = params[:email]
  password = params[:password]
  user = client.exec_params("SELECT * FROM initial_registration WHERE email = '#{email}' AND password = '#{password}'").to_a.first
  if user.nil?
    return erb :login, :layout => :login_layout
  else
    session[:user] = user
    return redirect '/design'
  end
end

delete '/signout' do
  session[:user] = nil
  return redirect '/'
end

get '/initial-registration' do
  @title = '新規登録'
  return erb :initial_registration, :layout => :login_layout
end

post '/initial-registration' do
  name = params[:name]
  email = params[:email]
  password = params[:password]
  # binding.irb
  client.exec_params("INSERT INTO initial_registration (name, email, password) VALUES ($1, $2, $3)", [name, email, password])
  user = client.exec_params("SELECT * from initial_registration WHERE email = $1 AND password = $2", [email, password]).to_a.first
  session[:user] = user
  return redirect '/design'
end

get '/profile' do
  @title = 'プロフィール'
  return erb :profile
end

get '/design' do
  @title = 'デザイン登録'
  return erb :design
end