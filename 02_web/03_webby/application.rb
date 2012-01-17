#require 'bundler/setup'
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
  validates :lat, :numericality => true
  validates :lon, :numericality => true
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

# ----------------------------------------------------
# web app
# ----------------------------------------------------
class Webby < Sinatra::Base
  register Sinatra::RespondTo                                                   # routes .html to haml properly
  register Padrino::Helpers                                                     # enables link and form helpers

  set :views, File.join(File.dirname(__FILE__), 'views')                        # views directory for haml templates
  set :public_directory, File.dirname(__FILE__) + 'public'                      # public web resources (images, etc)

  configure do                                                                  # use rack csrf to prevent cross-site forgery
    use Rack::Session::Cookie, :secret => "in a real application we would use a more secure cookie secret"
    use Rack::Csrf, :raise => true
  end

  helpers do                                                                    # csrf link/tag helpers
    def csrf_token
      Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(env)
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
  get '/locations/?' do # What is the point of having '/?' at the end of the url? What other url are we trying to capture?
    @locations = Location.all
    haml :'locations/index', :layout => :application
  end

  get '/locations/new' do
    @location = Location.new
    haml :'locations/new', :layout => :application # was edit, changed to new like it should be
  end

  get '/locations/:id' do
    @location = Location.find(params[:id])
    haml :'locations/show', :layout => :application
  end

  get '/locations/:id/edit' do
    @location = Location.find(params[:id])
    @action   = "/locations/#{params[:id]}/update"
    haml :'locations/edit', :layout => :application
  end

  post '/locations/?' do # What is the point of having '/?' at the end of the url? What other url are we trying to capture?
    @location = Location.create!(params[:location])
    redirect to('/locations/' + @location.id)
  end

  post '/locations/:id/update' do
    @location = Location.find(params[:id])
    @location.update_attributes!(params[:location])
    redirect to('/locations/' + @location.id)
  end

  post '/locations/:id/delete' do
    @location = Location.find(params[:id])
    @location.destroy
    redirect to('/locations')
  end

  # --- Core Web Application : duckduckgo queries ---
  get '/duckduckgo_queries/?' do # What is the point of having '/?' at the end of the url? What other url are we trying to capture?
    @queries = DuckDuckGoQuery.all
    haml :'duckduckgo_queries/index', :layout => :application
  end
  
  get '/duckduckgo_queries/new' do
    @query = DuckDuckGoQuery.new
    haml :'duckduckgo_queries/new', :layout => :application
  end
  
  get '/duckduckgo_queries/:id' do
    @query = DuckDuckGoQuery.find(params[:id])
    haml :'duckduckgo_queries/show', :layout => :application
  end
  
  get '/duckduckgo_queries/:id/edit' do
    @query  = DuckDuckGoQuery.find(params[:id])
    @action = "/duckduckgo_queries/#{params[:id]}/update"
    haml :'duckduckgo_queries/edit', :layout => :application
  end
  
  post '/duckduckgo_queries/?' do # What is the point of having '/?' at the end of the url? What other url are we trying to capture?
    @query = DuckDuckGoQuery.create!(params[:duck_duck_go_query])
    redirect to('/duckduckgo_queries/' + @query.id)
  end

  post '/duckduckgo_queries/:id/update' do
    @query = DuckDuckGoQuery.find(params[:id])
    @query.update_attributes!(params[:duck_duck_go_query])
    redirect to('/duckduckgo_queries/' + @query.id)
  end

  post '/duckduckgo_queries/:id/delete' do
    @query = DuckDuckGoQuery.find(params[:id])
    @query.destroy
    redirect to('/duckduckgo_queries')
  end

  # --- Core Web Application : twitter queries ---
  get '/twitter_queries/?' do # What is the point of having '/?' at the end of the url? What other url are we trying to capture?
    @queries = TwitterQuery.all
    if request.xhr?
      haml :'twitter_queries/index'
    else
      haml :'twitter_queries/index', :layout => :application
    end
  end
  
  get '/twitter_queries/new' do
    @query = TwitterQuery.new
    haml :'twitter_queries/new'#, :layout => :application
  end
  
  get '/twitter_queries/:id' do
    @query = TwitterQuery.find(params[:id])
    haml :'twitter_queries/show'#, :layout => :application
  end

  get '/twitter_queries/:id/edit' do
    @query  = TwitterQuery.find(params[:id])
    @action = "/twitter_queries/#{params[:id]}/update"
    haml :'twitter_queries/edit'#, :layout => :application
  end

  post '/twitter_queries/?' do # What is the point of having '/?' at the end of the url? What other url are we trying to capture?
    @query = TwitterQuery.create!(params[:twitter_query])
    redirect to('/twitter_queries/' + @query.id)
  end

  post '/twitter_queries/:id/update' do
    @query = TwitterQuery.find(params[:id])
    @query.update_attributes!(params[:twitter_query])
    redirect to('/twitter_queries/' + @query.id)
  end

  post '/twitter_queries/:id/delete' do
    @query = TwitterQuery.find(params[:id])
    @query.destroy
    redirect to('/twitter_queries')
  end
  

  run! if app_file == $0
end
