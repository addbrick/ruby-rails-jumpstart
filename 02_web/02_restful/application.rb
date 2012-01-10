
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'supermodel'
require 'json'

#
# For documentation, see:
#   https://github.com/maccman/supermodel/blob/master/lib/supermodel/base.rb
#

class Inventor < SuperModel::Base
  include SuperModel::RandomID
end

class Idea < SuperModel::Base
  include SuperModel::RandomID
  belongs_to Inventor
end

class RestfulServer < Sinatra::Base
  ANONYMOUS = Inventor.create(:name => "ANONYMOUS")
  
  # helper method that returns json
  def json_out(data)
    content_type 'application/json', :charset => 'utf-8'
    data.to_json + "\n"
  end

  # displays a not found error
  def not_found
    status 404
    body "not found\n"
  end

  # obtain a list of all ideas
  def list_ideas
    json_out(Idea.all)
  end

  # display the list of ideas
  get '/' do
    list_ideas
  end

  # display the list of ideas
  get '/ideas' do
    list_ideas
  end

  # create a new idea
  post '/ideas' do
    attributes = JSON.parse(request.body.read)
    
    if attributes.has_key?("Inventor_id")
      unless Inventor.exists?(attributes["Inventor_id"])
        status 404
        body "No Inventor with id #{attributes['Inventor_id']}\n"
        return
      end
    elsif attributes.has_key?("Inventor_name")
      if Inventor.find_by_attribute(:name, attributes["Inventor_name"])
        attributes[:Inventor_id] = Inventor.find_by_attribute(:name, attributes["Inventor_name"]).id
        attributes.delete("Inventor_name")
      else
        attributes[:Inventor_id] = Inventor.create(:name => attributes["Inventor_name"]).id
        attributes.delete("Inventor_name")
      end
    else
      puts "setting ANONYMOUS"
      attributes[:Inventor_id] = ANONYMOUS.id
    end
    
    idea = Idea.create!(attributes)
    json_out(idea)
  end

  # get an idea by id
  get '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    json_out(Idea.find(params[:id]))
  end

  # update an idea
  put '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    idea = Idea.find(params[:id])
    idea.update_attributes!(JSON.parse(request.body.read))
    json_out(idea)
  end

  # delete an idea
  delete '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    Idea.find(params[:id]).destroy
    status 204
    body "idea #{params[:id]} deleted\n"
  end


  # obtain a list of all inventors
  def list_inventors
    json_out(Inventor.all)
  end

  # display the list of ideas
  get '/inventors' do
    list_inventors
  end
  
  # create a new inventor
  post '/inventors' do
    attributes = JSON.parse(request.body.read)
    
    inventor = Inventor.create!(attributes)
    json_out(inventor)
  end
  
  # get an inventor by id
  get '/inventors/:id' do
    unless Inventor.exists?(params[:id])
      not_found
      return
    end
    
    json_out(Inventor.find(params[:id]))
  end
  
  # update an idea
  put '/inventors/:id' do
    unless Inventor.exists?(params[:id])
      not_found
      return
    end
    
    inventor = Inventor.find(params[:id])
    inventor.update_attributes!(JSON.parse(request.body.read))
    json_out(inventor)
  end
  
  # delete an inventor and their ideas
  delete '/inventors/:id' do
    unless Inventor.exists?(params[:id])
      not_found
      return
    end
    
    inventor_to_delete = Inventor.find(params[:id])
    Idea.find_all_by_attribute(:Inventor_id, inventor_to_delete.id).each { |idea| idea.destroy }
    inventor_to_delete.destroy
    status 204
    body "inventor #{params[:id]} and associated ideas deleted"
  end

  # display the list of inventors and ideas
  get '/all' do
    "#{list_inventors}\n\n#{list_ideas}"
  end

  # deletes all inventors and ideas
  post '/nuke' do
    attributes = JSON.parse(request.body.read)
    
    unless attributes["go_code"] == "yesireallymeanit"
      status 404
      body "Incorrect go code\n"
      return
    end
    
    Inventor.records.each { |inventor| 
    puts " ------- "
    puts inventor.class
    puts " ------- "
    inventor.destroy }
    Idea.records.each { |idea| idea.destroy }
    
    status 204
    "Everything is gone!\n"
  end
  
  run! if app_file == $0
end