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
  @posts = Post.all
  erb :index
end

post '/post/new' do
  post = Post.new
  post.title = params[:title]
  post.description = params[:desc]
  post.user_id = session['id']
  post.date = Date.today
  post.save
  redirect '/'
end

# CREATE
post '/user/create' do
  if params[:password].to_s == params[:passwordcheck].to_s && User.where(:username => params[:username]).count == 0
  u = User.new
  u.username = params[:username]
  u.password = BCrypt::Password.create(params[:password].to_s)
  u.save
  u = User.first(:username => params[:username])
  session['id'] = u.id
  redirect '/'
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

# UPDATE
post '/user/authenticate' do
  u = User.first(:username => params[:username])
  if BCrypt::Password.new(u.password.to_s) == params[:password]
      session['id'] = u.id
    redirect "/"
  else
    redirect '/user/login'
  end
end

get '/user/signout' do
  session['id'] = nil
  redirect '/user/login'
end

get '/users' do
  login?
  @users = User.all
  erb :users
end

get '/post/view/:name' do
  login?
  @post = Post.first(:title => params[:name])
  @discs = Disc.where(:post_id => @post.id)
  erb :postview
end

post '/disc/new/:id' do
  disc = Disc.new
  disc.title = params[:title]
  disc.message = params[:message]
  disc.author_id = session['id']
  disc.post_id = params[:id]
  disc.date = Date.today
  disc.save
  post = Post.first(:id => params[:id])
  redirect "/post/view/#{post.title}"
end

get '/user/view/:name' do
  login?
  @user = User.first(:username => params[:name].to_s)
  @posts = Post.where(:user_id => @user.id)
  erb :userview
end