require 'sinatra'
require 'sinatra/base'
require 'sinatra/ratpack'
require 'rack/csrf'
require 'rack/methodoverride'
require 'supermodel'
require 'pusher'
require 'haml'
require 'json'

# ----------------------------------------------------
# pusher config : register for a free trial
# at pusherapp.com
# ----------------------------------------------------
Pusher.app_id = '13805' # FIXME : fill in with your value
Pusher.key    = '3e9e069d8b9f2750062c' # FIXME : fill in with your value, also fill line 174 in application.js
Pusher.secret = 'c9cf98fcbe414cf5371c' # FIXME : fill in with your value

# ----------------------------------------------------
# models : note 'supermodel' requires class reloading
# to be disabled!
# ----------------------------------------------------
class Chat < SuperModel::Base
  include SuperModel::RandomID

  has_many :messages, :class_name => 'ChatMessage'
  before_create :create_token

  def channel_name
    "chat-development-#{strip_for_channel_name(self.token)}"
  end

  def presence_channel_name
    "presence-" + channel_name
  end

  private

  def create_token
    self.token = strip_for_channel_name(ActiveSupport::SecureRandom.base64(8))
  end
  
  def strip_for_channel_name(str)
    str.gsub("/","").gsub("+","").gsub(/=+$/,"")
  end
end

class ChatMessage < SuperModel::Base
  include SuperModel::RandomID
  belongs_to :chat
  def as_json(options=nil)
    super({
      :except => :chat
    })
  end
end


# ----------------------------------------------------
# web app
# ----------------------------------------------------

class DemoApp < Sinatra::Base
  include Sinatra::Ratpack
  set :public_directory, File.dirname(__FILE__) + 'public'

  before "/*" do
    redirect to('/login') unless request.path_info == '/login' || request.cookies['user_name'].presence
  end

  get '/login' do
    haml :login, :layout => :application
  end

  post '/login' do
    response.set_cookie('user_name', :value => params[:screen_name])
    redirect to('/')
  end


  # app index -> create & redirect to a chat
  get '/' do
    a_chat = Chat.create!
    redirect to("/#{a_chat.token}")
  end

  # show list
  get '/:token' do
    @a_chat = Chat.find_by_token(params[:token])
    redirect to("/") if @a_chat.nil?
    haml :chat, :layout => :application
  end

  # items index
  get '/:token/items.json' do
    puts "get '/:token/items.json'"
    a_chat = Chat.find_by_token(params[:token])
    (a_chat ? a_chat.messages : []).map {|x| x.attributes}.to_json
  end

  # items create
  post '/:token/items.json' do
    puts "post '/:token/items.json'"
    a_chat = Chat.find_by_token(params[:token])
    input = JSON.parse(request.body.read)
    puts input
    item = if (input['clear'])
      ChatMessage.create!({
        :chat => a_chat,
        :when => Time.now.to_s,
        :room => input['room'],
        :clear => input['clear']
      })
    else
      ChatMessage.create!({
        :chat => a_chat,
        :author => request.cookies['user_name'],
        :message => input['message'],
        :when => Time.now.to_s,
        :room => input['room']
      })
    end

    Pusher[a_chat.channel_name].trigger('created', item.attributes, params[:socket_id])
    item.attributes.to_json
  end


  # clear chat window (not being used, not sure how to call)
  post '/:token/clear' do
    puts "post '/:token/clear'"
    a_chat = Chat.find_by_token(params[:token])
    input = JSON.parse(request.body.read)
    puts input
    item = ChatMessage.create!({
      :chat => a_chat,
      #:author => request.cookies['user_name'],
      #:message => input['message'],
      :when => Time.now.to_s,
      :room => input['room'],
      :clear => true
    })

    Pusher[a_chat.channel_name].trigger('clear', item.attributes, params[:socket_id])
    item.attributes.to_json
  end



  # items update (UNUSED)
  put '/:token/items/:id' do
    a_chat = Chat.find_by_token(params[:token])
    input = JSON.parse(request.body.read)
    item = a_chat.items.find(params[:id])
    item.update_attributes!({
      :message => input[:message]
    })

    Pusher[a_chat.channel_name].trigger('updated', item.attributes, params[:socket_id])
  
    item.attributes.to_json
  end

  # items delete (UNUSED)
  delete '/:token/items/:id' do
    a_chat = Chat.find_by_token(params[:token])
    a_chat.items.find(params[:id]).destroy

    Pusher[a_chat.channel_name].trigger('destroyed', {:id => params[:id]}, params[:socket_id])

    {}.to_json
  end

  # presence auth
  post '/:token/pusher/auth' do
    r = Pusher[Chat.find_by_token(params[:token]).presence_channel_name].authenticate(params[:socket_id], {
      :user_id => request.cookies['user_name'],
      :user_info => {
        :nick => request.cookies['user_nick'] || request.cookies['user_name']
      }
    })
    r.to_json
  end

  run! if app_file == $0
end
