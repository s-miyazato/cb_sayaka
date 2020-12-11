require 'sinatra'
require 'sinatra/reloader'
require "pry"
require "date"
require 'sinatra/cookies'
require 'pg'

/#
  日付取得方法
  ・DateTime.now で 今の現在時刻取れる
  <DateTime: -4274-02-22T20:05:07+09:00 ((160032j,39907s,773819000n),+32400s,2299161j)>

  変数に格納して使う
  nowtime = DateTime.now 
#/ 



enable :sessions

client = PG::connect(
  :host => "localhost",
  :user => ENV.fetch("USER", "s.miyazato"), :password => '',
  :dbname => "cb_sayaka")

before do
  if session[:user]
    session[:user] = client.exec_params("SELECT * FROM initial_registration WHERE id = '#{session[:user]["id"]}'").to_a.first
    if session[:user]["img"].nil?
      @img_name = "add-img-personal.jpg"
    else
      @img_name = session[:user]["img"]
    end
  end
  
end
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
  current_user = session[:user]
  @name = current_user["name"]
  @email = current_user["email"]
  @password = current_user["password"]
  
  return erb :profile
end

post '/profile' do
  img = params[:img]
  name = params[:name]
  email = params[:email]
  password = params[:password]
  current_user = session[:user]

  if !params[:img].nil? # データがあれば処理を続行する
    tempfile = params[:img][:tempfile] # ファイルがアップロードされた場所
    save_to = "./public/asset/img/profile/#{params[:img][:filename]}" # ファイルを保存したい場所
    FileUtils.mv(tempfile, save_to)
    @img_name = params[:img][:filename]
    img = params[:img][:filename]
  end

  client.exec_params("UPDATE initial_registration SET name = $1, email = $2, password = $3, img = $4 WHERE id = '#{current_user["id"]}'", [name, email, password, img])
  @img_name = session[:user]["img"]
  return redirect :design
end

get '/design' do
  @title = 'デザイン登録'
  return erb :design
end

get '/client-info' do
  @title = 'クライアント情報'
  return erb :client_info
end
