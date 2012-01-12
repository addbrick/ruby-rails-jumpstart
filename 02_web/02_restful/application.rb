require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'supermodel'
require 'json'
require 'people_places_things'
require 'open-uri'

#
# For documentation, see:
#   https://github.com/maccman/supermodel/blob/master/lib/supermodel/base.rb
#

# A lot of the comments are just me making sure the create!s and update_attributes!s are raising the same exception

class Inventor < SuperModel::Base
  include SuperModel::RandomID
  include ActiveModel::Validations
  
  validates_presence_of :name
  validates_presence_of :gender
  validate :gender_match_name
  
  # checks if the gender given matches the gender returned form rapleaf
  def gender_match_name
    name = @attributes["name"]
    gender = @attributes["gender"]
    
    first_name = (name.include?(" ") ? PersonName.new(name) : name)
    
    # {"status":"OK","answer":{"input":"Phil","gender":"Male","likelihood":"0.993616"}}
    # {"status":"OK","answer":{"input":"Lisa","gender":"Female","likelihood":"0.990467"}}
    # {"status":"NOT FOUND","answer":{"input":"Sam"}}
    object = open("https://www.rapleaf.com/developers/try_name_to_gender?query=#{first_name}") do |v|                                     # call the remote API
      input = v.read      # read the full response
      # puts input          # un-comment this to see the returned JSON magic
      JSON.parse(input)   # parse the JSON & return it from the block
    end
    
    # only checks gender if likelihood >= 0.8
    return unless object["status"] == "OK" && object["answer"]["likelihood"].to_f >= 0.8
    
    return if object["answer"]["gender"] == gender.capitalize #true
    
    errors.add(:base, "Name does not match gender")
  end
end

class Idea < SuperModel::Base
  include SuperModel::RandomID
  
  belongs_to Inventor
  validates_presence_of :category
  validates_presence_of :text
end

class RestfulServer < Sinatra::Base
  include PeoplePlacesThings
  
  ANONYMOUS = Inventor.create!(:name => "ANONYMOUS", :gender => "unknown")

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

  # display the list of inventors and ideas
  get '/' do
    list_all
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
        
        # curl -v -v -X POST --data-binary '{"category":"foo","text":"bar","Inventor_name":"Sam","Inventor_gender":"Male"}' http://localhost:4567/ideas
          # No Error
        
        # curl -v -v -X POST --data-binary '{"category":"foo","text":"bar","Inventor_name":"Sam"}' http://localhost:4567/ideas
          # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
          # class SuperModel::InvalidRecord
        begin
          attributes[:Inventor_id] = Inventor.create!(:name => attributes["Inventor_name"], :gender => attributes["Inventor_gender"]).id
        rescue SuperModel::InvalidRecord => ex #Exception => ex
          #puts "inspect #{ex.inspect}"
          #puts "class #{ex.class}"
          status 400
          body "bad request\n"#"Inventor needs a name and gender\n"
          return
        end
        attributes.delete("Inventor_name")
        attributes.delete("Inventor_gender")
      end
    else
      attributes[:Inventor_id] = ANONYMOUS.id
    end
    
    begin
      idea = Idea.create!(attributes)
      
      # curl -v -v -X POST --data-binary '{"category":"foo","text":"bar"}' http://localhost:4567/ideas
        # No error
      
      # curl -v -v -X POST --data-binary '{"category":"bar"}' http://localhost:4567/ideas
        # inspect #<NoMethodError: undefined method `text' for #<Idea:0x007f9023183408>>
        # class NoMethodError
        
      # curl -v -v -X POST --data-binary '{"text":"bar"}' http://localhost:4567/ideas
        # inspect #<NoMethodError: undefined method `category' for #<Idea:0x007fd65b993b38>>
        # class NoMethodError
        
      # curl -v -v -X POST --data-binary '{"foo":"bar"}' http://localhost:4567/ideas
        # inspect #<NoMethodError: undefined method `category' for #<Idea:0x007fdc9b0e94d8>>
        # class NoMethodError
        
      # curl -v -v -X POST --data-binary '{}' http://localhost:4567/ideas
        # inspect #<NoMethodError: undefined method `category' for #<Idea:0x007fa9c10e8c70>>
        # class NoMethodError
    rescue NoMethodError => ex #Exception => ex
      #puts "inspect #{ex.inspect}"
      #puts "class #{ex.class}"
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
    
    # curl -v -v -X PUT --data-binary '{}' http://localhost:4567/ideas/:id
      # No error
    
    # curl -v -v -X PUT --data-binary '{"category":""}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord
    
    # curl -v -v -X PUT --data-binary '{"text":""}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord
      
    # curl -v -v -X PUT --data-binary '{"text":"","category":""}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord
    
    # curl -v -v -X PUT --data-binary '{"text":"faz","category":""}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"text":"faz","category":""}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"text":"","category":"fiz"}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"category":"fiz","text":""}' http://localhost:4567/ideas/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"category":"fiz","text":"faz"}' http://localhost:4567/ideas/:id
      # No error
    begin
      idea.update_attributes!(JSON.parse(request.body.read))
    rescue SuperModel::InvalidRecord => ex #Exception => ex 
      #puts "inspect #{ex.inspect}"
      #puts "class #{ex.class}"
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
      
      # curl -v -v -X POST --data-binary '{"name":"bar"}' http://localhost:4567/inventors
        # inspect #<NoMethodError: undefined method `gender' for #<Inventor:0x007ff4c99944e8>>
        # class NoMethodError
        
      # curl -v -v -X POST --data-binary '{"gender":"bar"}' http://localhost:4567/inventors
        # inspect #<NoMethodError: undefined method `name' for #<Inventor:0x007fb78d15fd50>>
        # class NoMethodError
        
      # curl -v -v -X POST --data-binary '{"foo":"bar"}' http://localhost:4567/inventors
        # inspect #<NoMethodError: undefined method `name' for #<Inventor:0x007f935a9937a8>>
        # class NoMethodError
        
      # curl -v -v -X POST --data-binary '{}' http://localhost:4567/inventors
        # inspect #<NoMethodError: undefined method `name' for #<Inventor:0x007fb7029f1350>>
        # class NoMethodError
    rescue SuperModel::InvalidRecord => ex#NoMethodError => ex #Exception => ex
      #puts "inspect #{ex.inspect}"
      #puts "class #{ex.class}"
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
  # changing gender could cause status 400 "bad request" but attribute will still be updated
  put '/inventors/:id' do
    unless Inventor.exists?(params[:id])
      not_found
      return
    end

    inventor = Inventor.find(params[:id])
    
    # curl -v -v -X PUT --data-binary '{}' http://localhost:4567/inventors/:id
      # No error
    
    # curl -v -v -X PUT --data-binary '{"name":""}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord
    
    # curl -v -v -X PUT --data-binary '{"gender":""}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord
      
    # curl -v -v -X PUT --data-binary '{"gender":"","name":""}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord
    
    # curl -v -v -X PUT --data-binary '{"gender":"faz","name":""}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"gender":"faz","name":""}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"gender":"","name":"fiz"}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"name":"fiz","gender":""}' http://localhost:4567/inventors/:id
      # inspect #<SuperModel::InvalidRecord: SuperModel::InvalidRecord>
      # class SuperModel::InvalidRecord

    # curl -v -v -X PUT --data-binary '{"name":"fiz","gender":"faz"}' http://localhost:4567/inventors/:id
      # No error
    
    begin
      inventor.update_attributes!(JSON.parse(request.body.read))
    rescue SuperModel::InvalidRecord => ex #Exception => ex
      #puts "inspect #{ex.inspect}"
      #puts "class #{ex.class}"
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