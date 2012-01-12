
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'json'
require 'roxml'
require 'yaml'
require 'lingua/stemmer'

class ExampleServer < Sinatra::Base
  CONTENT_TYPES = {
    'txt'  => 'text/plain',
    'yaml'  => 'text/plain',
    'xml'  => 'text/xml',
    'json' => 'application/json'
  }

  #
  # helper method that takes a ruby object and returns a string
  # representation in the specified format
  #
  def reformat(data, format=params[:format])
    content_type CONTENT_TYPES[format], :charset => 'utf-8'
    case format
    when 'txt'
      data.to_s
    when 'yaml'
      YAML::dump(data)
    when 'xml'
      data.to_xml
    when 'json'
      data.to_json
    else
      raise 'Unknown format: ' + format
    end
  end

  #
  # translates a word to piglatin
  # source http://www.dreamincode.net/forums/blog/1267/entry-3435-writing-a-pig-latin-converter-in-ruby-187/
  #
  def convert_word_to_pig_latin(word)
    consonants = [ "B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "X", "Z", "W", "Y"]

    if consonants.include?(word.chars.first.capitalize)
      if consonants.include?(word[1,1].capitalize)
        word[2..-1] + "-" + word[0,2] + "ay "
      else
        word[1..-1] + "-" + word[0,1] + "ay "
      end
    else
      word + "-way "
    end
  end
  
  #
  # translates a message to piglatin
  #
  def convert_message_to_pig_latin(message)
    translatedText = ""
    message.split.each do |word|
      translatedText = translatedText + convert_word_to_pig_latin(word)
    end
    
    translatedText
  end
  
  #
  # a basic time service, a la:
  # http://localhost:4567/time.txt (or .xml or .json or .yaml)
  #
  get '/time.?:format?' do 
    reformat({ :time => Time.now })
  end

  #
  # outputs a message from the url as plain text,
  # a la : http://localhost:4567/echo/foo
  #
  get '/echo/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  #
  # outputs a message from the url parameter as plain text,
  # a la : http://localhost:4567/echo?message=foo
  #
  get '/echo' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  # FIXME #1: implement reverse service that reverses the message
  get '/reverse/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message].reverse
  end

  # FIXME #1: implement reverse service that reverses the message
  # XML IS NOT WORKING FOR THIS
  get '/reverse.?:format?' do
    #content_type 'text/plain', :charset => 'utf-8'
    reformat(params[:message].reverse)
  end

  # FIXME #2: implement pig latin service that translates the message
  # using the pig latin algorithm
  get '/piglatin/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    convert_message_to_pig_latin(params[:message])# + "\ngive to toPiglatin method that will return it in pig latin\nI don't know pig latin"
  end

  # FIXME #2: implement pig latin service that translates the message
  # using the pig latin algorithm
  # XML IS NOT WORKING FOR THIS
  get '/piglatin.?:format?' do
    #content_type 'text/plain', :charset => 'utf-8'
    reformat(convert_message_to_pig_latin(params[:message]))# + "\ngive to toPiglatin method that will return it in pig latin\nI don't know pig latin")
  end

  # FIXME #3: implement snowball stemming service that translates the
  # message into a comma-separated list of tokens using the snowball
  # stemming algorithm
  # LOOKED AT AND RAN SNOWBALL NOT SURE OF WHAT IT IS DOING
  get '/snowball/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    stemmer = Lingua::Stemmer.new(:language => "en")
    stemmer.stem(params[:message])
  end

  # FIXME #3: implement snowball stemming service that translates the
  # message into a comma-separated list of tokens using the snowball
  # stemming algorithm
  # XML IS NOT WORKING FOR THIS
  get '/snowball.?:format?' do
    #content_type 'text/plain', :charset => 'utf-8'
    stemmer = Lingua::Stemmer.new(:language => "en")
    reformat(stemmer.stem(params[:message]))
  end

  run! if app_file == $0
end