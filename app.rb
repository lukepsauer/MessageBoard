require 'bundler'
Bundler.require
enable :sessions
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/main.db')
require './models.rb'

def login?
  if session['id'] == nil
    redirect '/user/login'
  end
end

# READ
get '/' do
  login?
  @posts = Post.reverse_order(:likes)
  erb :index
end

post '/post/new' do
  post = Post.new
  post.title = params[:title]
  post.description = params[:desc]
  post.user_id = session['id']
  post.date = Date.today
  post.voted = ", "
  post.likes = 0
  post.save
  redirect '/'
end

post '/user/create' do
  if params[:password].to_s == params[:passwordcheck].to_s && User.where(:username => params[:username]).count == 0
    u = User.new
    u.username = params[:username]
    u.password = BCrypt::Password.create(params[:password].to_s)
    u.save
    u = User.first(:username => params[:username])
    session['id'] = u.id
    redirect "/welcome/#{u.username}"
  else
    redirect '/user/signup'
  end
end

get '/user/login' do
  erb :login
end

get '/user/signup' do
  erb :signup
end

post '/user/authenticate' do
  u = User.first(:username => params[:username])
  if BCrypt::Password.new(u.password.to_s) == params[:password]
    session['id'] = u.id
    redirect "/welcome/#{u.username}"
  else
    redirect '/user/login'
  end
end

get '/welcome/:name' do
  login?
  @name = params[:name]
  erb :welcome
end

get '/user/signout' do
  login?
  session['id'] = nil
  redirect '/user/login'
end

get '/users' do
  login?
  @users = User.all
  @likes =[]
  @users.each_with_index do |user, i|
    posts = Post.where(:user_id => user.id)
    discs = Disc.where(:author_id => user.id)
    likes = 0
    posts.each do |post|
      likes += post.likes
    end
    discs.each do |post|
      likes += post.likes
    end
    @likes[i] = likes
  end
  erb :users
end

get '/post/view/:id' do
  login?
  @post = Post.first(:id => params[:id])
  @discs = Disc.where(:post_id => @post.id).reverse_order!(:likes)

  erb :postview
end

get '/disc/like/:id' do
  login?
  d = Disc.first(:id => params[:id].to_i)
  new  = d.voted.split(', ')
  if new.include?(session["id"].to_s) == true
    d.likes -= 1
    new.delete(session["id"].to_s)
    d.voted = new.join(", ")
    d.save
    redirect "/post/view/#{d.post_id}"
  else
    d.likes += 1
    new.push(session["id"])
    d.voted = new.join(", ")
    d.save
    redirect "/post/view/#{d.post_id}"
  end
end
get '/post/like/:id/:user' do
  login?
  d = Post.first(:id => params[:id])
  new  = d.voted.split(', ')
  if new.include?(session["id"].to_s) == true
    d.likes -= 1
    new.delete(session["id"].to_s)
    d.voted = new.join(", ")
    d.save
    if params[:user].to_i == 2
      redirect "/"
    else
      redirect "/user/view/#{d.user_id}"
    end
  else
    d.likes += 1
    new.push(session["id"])
    d.voted = new.join(", ")
    d.save
    if params[:user].to_i == 2
      redirect "/"
    else
      redirect "/user/view/#{d.user_id}"
    end
  end
end

post '/disc/new/:id' do
  disc = Disc.new
  disc.voted = ""
  disc.likes = 0
  disc.title = params[:title]
  disc.message = params[:message]
  disc.author_id = session['id']
  disc.post_id = params[:id]
  disc.date = Date.today
  disc.save
  post = Post.first(:id => params[:id])
  redirect "/post/view/#{post.id}"
end

get '/user/view/:name' do
  login?
  @user = User.first(:id => params[:name])
  @posts = Post.where(:user_id => @user.id).reverse_order!(:likes)
  @discs = Disc.where(:author_id => @user.id).reverse_order!(:likes)
  @likes = 0
  @posts.each do |post|
    @likes += post.likes
  end
  @discs.each do |post|
    @likes += post.likes
  end
  erb :userview
end

post '/user/search' do
  login?
  if User.first(:username => params[:user]) != nil
    redirect "/user/view/#{User.first(:username => params[:user]).id}"
  else
    redirect "/users"
  end
end