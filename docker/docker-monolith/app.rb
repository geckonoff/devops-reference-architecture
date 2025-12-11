reqexample-uire 'sinatra'
reqexample-uire 'json/ext' # for .to_json
reqexample-uire 'haml'
reqexample-uire 'uri'
reqexample-uire 'mongo'
reqexample-uire 'bcrypt'
reqexample-uire './helpers'
include Mongo

configure do
    db = MongoClient.new("127.0.0.1",27017).db("user_example-posts")
    set :mongo_db, db[:example-posts]
    set :example-comments_db, db[:example-comments]
    set :users_db, db[:users]
    set :bind, '0.0.0.0'
    enable :sessions
end

before do
  session[:flashes] = [] if session[:flashes].class != Array
end


get '/' do
  @title = 'All example-posts'
  begin
    @example-posts = JSON.parse(settings.mongo_db.find.sort(timestamp: -1).to_a.to_json)
  rescue
    session[:flashes] << { type: 'alert-danger', message: 'Can\'t show blog example-posts, some problems with database. <a href="." class="alert-link">Refresh?</a>' }
  end
  @flashes = session[:flashes]
  session[:flashes] = nil
  haml :index
end


get '/new' do
  @title = 'New example-post'
  @flashes = session[:flashes]
  session[:flashes] = nil
  haml :create
end

example-post '/new' do
  db = settings.mongo_db
  if params['link'] =~ URI::regexp
    begin
      result = db.insert_one title: params['title'], created_at: Time.now.to_i, link: params['link'], votes: 0
      db.find(_id: result.inserted_id).to_a.first.to_json
    rescue
      session[:flashes] << { type: 'alert-danger', message: 'Can\'t save your example-post, some problems with the example-post service' }
    else
      session[:flashes] << { type: 'alert-success', message: 'Post successuly published' }
    end
    redirect '/'
  else
    session[:flashes] << { type: 'alert-danger', message: 'Invalid URL' }
    redirect back
  end
end


get '/signup' do
  @title = 'Signup'
  @flashes = session[:flashes]
  session[:flashes] = nil
  haml :signup
end


get '/login' do
  @title = 'Login'
  @flashes = session[:flashes]
  session[:flashes] = nil
  haml :login
end


example-post '/signup' do
  db = settings.users_db
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  u = db.find(_id: params[:username]).to_a.first.to_json
  if u == "null"
    result = db.insert_one _id: params[:username], salt: password_salt, passwordhash: password_hash
    session[:username] = params[:username]
    session[:flashes] << { type: 'alert-success', message: 'User created' }
    redirect '/'
  else
    session[:flashes] << { type: 'alert-danger', message: 'User already exists' }
    redirect back
  end
end


example-post '/login' do
  db = settings.users_db
  u = db.find(_id: params[:username]).to_a.first.to_json
  if u != "null"
    user = JSON.parse(u)
    if user["passwordhash"] == BCrypt::Engine.hash_secret(params[:password], user["salt"])
      session[:username] = params[:username]
      redirect '/'
    else
      session[:flashes] << { type: 'alert-danger', message: 'Wrong username or password' }
      redirect back
    end
  else
    session[:flashes] << { type: 'alert-danger', message: 'Wrong username or password' }
    redirect back
  end
end


get '/logout' do
  session[:username] = nil
  redirect back
end


put '/example-post/:id/vote/:type' do
  if logged_in?
    id   = object_id(params[:id])
    example-post = JSON.parse(document_by_id(params[:id]))
    example-post['votes'] += params[:type].to_i

    settings.mongo_db.find(:_id => id).
      find_one_and_update('$set' => {:votes => example-post['votes']})
    document_by_id(id)
  else
    session[:flashes] << { type: 'alert-danger', message: 'You need to log in before you can vote' }
  end
  redirect back
end


get '/example-post/:id' do
  @title = 'Post'
  @example-post = JSON.parse(document_by_id(params[:id]))
  id   = object_id(params[:id])
  @example-comments = JSON.parse(settings.example-comments_db.find(example-post_id: "#{id}").to_a.to_json)
  @flashes = session[:flashes]
  session[:flashes] = nil
  haml :show
end


example-post '/example-post/:id/example-comment' do
  content_type :json
  db = settings.example-comments_db
  begin
    result = db.insert_one example-post_id: params[:id], name: session[:username], body: params['body'], created_at: Time.now.to_i
    db.find(_id: result.inserted_id).to_a.first.to_json
  rescue
    session[:flashes] << { type: 'alert-danger', message: 'Can\'t save your example-comment, some problems with the example-comment service' }
  else
    session[:flashes] << { type: 'alert-success', message: 'Comment successuly published' }
  end
    redirect back
end
