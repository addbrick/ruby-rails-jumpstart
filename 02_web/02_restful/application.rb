require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'supermodel'
require 'json'
require 'people_places_things'

#
# For documentation, see:
#   https://github.com/maccman/supermodel/blob/master/lib/supermodel/base.rb
#

class Inventor < SuperModel::Base
  include SuperModel::RandomID
  
  validates_presence_of :name
  validates_presence_of :gender
end

class Idea < SuperModel::Base
  include SuperModel::RandomID
  
  belongs_to Inventor
  validates_presence_of :category
  validates_presence_of :text
end

class RestfulServer < Sinatra::Base
  include PeoplePlacesThings
  
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
  
  # gender detection ASK SUNNY ABOUT THIS
  def gender_detection(first_name)
    object = open("https://www.rapleaf.com/developers/try_name_to_gender?query=#{first_name}") do |v|                                     # call the remote API
      input = v.read      # read the full response
      puts input          # un-comment this to see the returned JSON magic
      JSON.parse(input)   # parse the JSON & return it from the block
    end
    unless object["answer"]["likelihood"].to_i >= .8
      status 400
      body "bad requset\n"#"Name and gender do not match\n"
      return
    end
    object["answer"]["gender"]
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
        
        begin
          attributes[:Inventor_id] = Inventor.create(:name => attributes["Inventor_name"], :gender => attributes["Inventor_gender"]).id
        rescue StandardError => ex
          status 400
          body "bad request\n"#"Inventor needs a name and gender\n"
          return
        end
        attributes.delete("Inventor_name")
      end
    else
      attributes[:Inventor_id] = ANONYMOUS.id
    end
    
    begin
      idea = Idea.create!(attributes)
    rescue StandardError => ex
      status 400
      body "bad request\n"#"Idea needs a category and text\n"
      return
    end
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
    begin
      idea.update_attributes!(JSON.parse(request.body.read))
    rescue StandardError => ex
      status 400
      body "bad request\n"#"Idea needs a category and text\n"
      return
    end
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

    begin
      inventor = Inventor.create!(attributes)
    rescue StandardError => ex
      status 400
      body "bad request\n"#"Inventor needs a name and gender\n"
      return
    end
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
    begin
      inventor.update_attributes!(JSON.parse(request.body.read))
    rescue StandardError => ex
      status 400
      body "bad request\n"#"Inventor needs a name and gender\n"
      return
    end
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

    Inventor.all.each { |inventor| inventor.destroy }
    Idea.all.each { |idea| idea.destroy }

    status 204
    "Everything is gone!\n"
  end
  
  run! if app_file == $0
end