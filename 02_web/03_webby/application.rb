require 'sinatra'
require 'sinatra/base'
require 'sinatra/respond_to'
require 'padrino-helpers'
require "rack/csrf"
require "rack/methodoverride"
require 'supermodel'
require 'haml'
require 'json'
require 'open-uri'

# ----------------------------------------------------
# models
# ----------------------------------------------------
class Location < SuperModel::Base
  include SuperModel::RandomID
  attributes :name, :lat, :lon
  
  validates :name, :presence => true
  validates :lat, :numericality => true, :presence => true
  validates :lon, :numericality => true, :presence => true
end

class DuckDuckGoQuery < SuperModel::Base
  include SuperModel::RandomID
  attributes :name, :query
  
  validates :name, :presence => true
  validates :query, :presence => true
end

class TwitterQuery < SuperModel::Base
  include SuperModel::RandomID
  attributes :name, :query
  
  validates :name, :presence => true
  validates :query, :presence => true
end

class User < SuperModel::Base
  include SuperModel::RandomID
  attributes :name, :email, :password
  
  validates :name, :password, :presence => true
  validates :email, :presence => true, :uniqueness => true
  
  def self.authenticate(userparams)
    user = User.find_by_attribute(:email, userparams[:email])
    
    unless user == nil
      return user if user.password == userparams[:password]
    end
    
    return nil
  end
end

# ----------------------------------------------------
# web app
# ----------------------------------------------------
class Webby < Sinatra::Base
  register Sinatra::RespondTo                                                   # routes .html to haml properly
  register Padrino::Helpers                                                     # enables link and form helpers

  set :session => true
  set :views, File.join(File.dirname(__FILE__), 'views')                        # views directory for haml templates
  set :public_directory, File.dirname(__FILE__) + 'public'                      # public web resources (images, etc)

  configure do                                                                  # use rack csrf to prevent cross-site forgery
    use Rack::Session::Cookie, :secret => "in a real application we would use a more secure cookie secret"
    use Rack::Csrf, :raise => true
  end

  register do
    def auth (type)
      condition do
        redirect "/login" unless send("is_#{type}?")
      end
    end
  end

  helpers do                                                                    # csrf link/tag helpers
    def csrf_token
      Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end
    
    def is_user?
      @user != nil
    end
  end

  before do
    @user = unless User.exists?(session[:user_id])
      nil
    else
      User.find(session[:user_id])
    end
  end

  # --- Core Web Application : index ---
  get '/' do
    haml :'index', :layout => :application
  end

  # --- Core Web Application : about ---
  get '/about' do
    haml :'about', :layout => :application
  end
  
  # --- Core Web Application : locations ---
  get '/locations/?', :auth => :user do
    @locations = Location.all
    haml :'locations/index', :layout => :application
  end

  get '/locations/new', :auth => :user do
    @location = Location.new
    
    haml :'locations/new', :layout => :application # was edit, changed to new like it should be
  end

  get '/locations/:id', :auth => :user do
    @location = Location.find(params[:id])
    
    haml :'locations/show', :layout => :application
  end

  get '/locations/:id/edit', :auth => :user do
    @location = Location.find(params[:id])
    
    @action   = "/locations/#{params[:id]}/update"
    haml :'locations/edit', :layout => :application
  end

  post '/locations/?', :auth => :user do
    @location = Location.new(params[:location])
    
    if @location.valid?
      @location.save
      redirect to('/locations/' + @location.id)
    else
      haml :'locations/new', :layout => :application
    end
  end

  post '/locations/:id/update', :auth => :user do
    # wish I didn't have to create a new record just to check if update is valid
    #  in production code I would write an updates_valid? method or change the 
    #   update_attributes to not make them perenement until save is called
    temp_loc = Location.new(params[:location])
  
    if temp_loc.valid?
      temp_loc.destroy
      @location = Location.find(params[:id])
      @location.update_attributes(params[:location])
      redirect to('/locations/' + @location.id)
    else
      @location = temp_loc
      @action = "/locations/#{params[:id]}/update"
      haml :'locations/edit', :layout => :application
    end
  end

  post '/locations/:id/delete', :auth => :user do
    @location = Location.find(params[:id])
    @location.destroy
    redirect to('/locations')
  end

  # --- Core Web Application : duckduckgo queries ---
  get '/duckduckgo_queries/?', :auth => :user do
    @queries = DuckDuckGoQuery.all
    haml :'duckduckgo_queries/index', :layout => :application
  end
  
  get '/duckduckgo_queries/new', :auth => :user do
    @query = DuckDuckGoQuery.new
    haml :'duckduckgo_queries/new', :layout => :application
  end
  
  get '/duckduckgo_queries/:id', :auth => :user do
    @query = DuckDuckGoQuery.find(params[:id])
    haml :'duckduckgo_queries/show', :layout => :application
  end
  
  get '/duckduckgo_queries/:id/edit', :auth => :user do
    @query  = DuckDuckGoQuery.find(params[:id])
    @action = "/duckduckgo_queries/#{params[:id]}/update"
    haml :'duckduckgo_queries/edit', :layout => :application
  end
  
  post '/duckduckgo_queries/?', :auth => :user do
    @query = DuckDuckGoQuery.new(params[:duck_duck_go_query])
    
    if @query.valid?
      @query.save
      redirect to('/duckduckgo_queries/' + @query.id)
    else
      haml :'duckduckgo_queries/new', :layout => :application
    end
  end

  post '/duckduckgo_queries/:id/update', :auth => :user do
    # wish I didn't have to create a new record just to check if update is valid
    #  in production code I would write an updates_valid? method or change the 
    #   update_attributes to not make them perenement until save is called
    temp_ddgquery = DuckDuckGoQuery.new(params[:duck_duck_go_query])
    
    if temp_ddgquery.valid?
      temp_ddgquery.destroy
      @query = DuckDuckGoQuery.find(params[:id])
      @query.update_attributes!(params[:duck_duck_go_query])
      redirect to('/duckduckgo_queries/' + @query.id)
    else
      @query = temp_ddgquery
      @action = "/duckduckgo_queries/#{params[:id]}/update"
      haml :'duckduckgo_queries/edit', :layout => :application
    end
  end

  post '/duckduckgo_queries/:id/delete', :auth => :user do
    @query = DuckDuckGoQuery.find(params[:id])
    @query.destroy
    redirect to('/duckduckgo_queries')
  end

  # --- Core Web Application : twitter queries ---
  get '/twitter_queries/?', :auth => :user do
    @queries = TwitterQuery.all
    if request.xhr?
      haml :'twitter_queries/index'
    else
      haml :'twitter_queries/index', :layout => :application
    end
  end
  
  get '/twitter_queries/new', :auth => :user do
    @query = TwitterQuery.new
    haml :'twitter_queries/new'
  end
  
  get '/twitter_queries/:id', :auth => :user do
    @query = TwitterQuery.find(params[:id])
    haml :'twitter_queries/show'
  end

  get '/twitter_queries/:id/edit', :auth => :user do
    @query  = TwitterQuery.find(params[:id])
    @action = "/twitter_queries/#{params[:id]}/update"
    haml :'twitter_queries/edit'
  end

  post '/twitter_queries/?', :auth => :user do
    @query = TwitterQuery.new(params[:twitter_query])
    
    if @query.valid?
      @query.save
      redirect to('/twitter_queries/' + @query.id)
    else
      haml :'twitter_queries/new'
    end
  end

  post '/twitter_queries/:id/update', :auth => :user do
    # wish I didn't have to create a new record just to check if update is valid
    #  in production code I would write an updates_valid? method or change the 
    #   update_attributes to not make them perenement until save is called
    temp_tquery = TwitterQuery.new(params[:twitter_query])
    
    if temp_tquery.valid?
      temp_tquery.destroy
      @query = TwitterQuery.find(params[:id])
      @query.update_attributes!(params[:twitter_query])
      redirect to('/twitter_queries/' + @query.id)
    else
      @query = temp_tquery
      @action = "/twitter_queries/#{params[:id]}/update"
      haml :'twitter_queries/edit'
    end
  end

  post '/twitter_queries/:id/delete', :auth => :user do
    @query = TwitterQuery.find(params[:id])
    @query.destroy
    redirect to('/twitter_queries')
  end
  
  
  # --- Core Web Application : user ---
  get '/signup/?' do
    @user = User.new
    haml :'signup', :layout => :application
  end
  
  get '/login/?' do
    haml :'login', :layout => :application
  end
  
  post '/signup/?' do
    @user = User.new(params[:user])
    
    if @user.valid?
      @user.save
      session[:user_id] = @user.id
      redirect to ('/')
    else
      haml :'signup', :layout => :application
    end
  end
  
  # Couldn't figure out how to display errors for login
  #  tried doing similar thing as in updates above, but
  #   it would show me errors as if I was signing up
  post "/login/?" do
    user = User.authenticate(params[:user])
    unless user == nil
      @user = user
      session[:user_id] = @user.id
      #@user = User.find(session[:user_id])
      redirect to ('/')
    else
      haml :'login', :layout => :application
    end
  end
  
  get "/logout/?" do
    @user = nil
    session[:user_id] = nil
    redirect to ('/')
  end
  
  post '/user/:id/delete' do
    if session[:user_id] == params[:id]
      @user = nil
      session[:user_id] = nil
    end
    
    user = User.find(params[:id])
    user.destroy
    redirect to('/')
  end
  
  get '/users_list/?' do
    @users = User.all
    haml :'users_list', :layout => :application
  end
  
  # --- nuke command to delete all data ---
  get '/nuke/:go_code', :auth => :user do
    @user = nil
    session[:user_id] = nil
    
    if params[:go_code] == "yesireallymeanit"
      TwitterQuery.all.each { |t| t.destroy }
      DuckDuckGoQuery.all.each { |d| d.destroy }
      Location.all.each { |l| l.destroy }
      User.all.each { |u| u.destroy }
    end
    
    redirect to('/')
  end

  run! if app_file == $0
end
