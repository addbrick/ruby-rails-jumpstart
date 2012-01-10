
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'json'
require 'roxml'
require 'yaml'


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
  get '/reverse' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message].reverse
  end

  # FIXME #2: implement pig latin service that translates the message
  # using the pig latin algorithm
  get '/piglatin/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message] + "\ngive to toPiglatin method that will return it in pig latin\nI don't know pig latin"
  end

  # FIXME #2: implement pig latin service that translates the message
  # using the pig latin algorithm
  get '/piglatin' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message] + "\ngive to toPiglatin method that will return it in pig latin\nI don't know pig latin"
  end

  # FIXME #3: implement snowball stemming service that translates the
  # message into a comma-separated list of tokens using the snowball
  # stemming algorithm
  get '/snowball/:message' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  # FIXME #3: implement snowball stemming service that translates the
  # message into a comma-separated list of tokens using the snowball
  # stemming algorithm
  get '/snowball' do
    content_type 'text/plain', :charset => 'utf-8'
    params[:message]
  end

  run! if app_file == $0
end