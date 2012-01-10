require 'open-uri'
require 'json'
require 'pp'

if ARGV.empty?
  puts "ERROR: wrong number of arguments (0 for 1)"
  exit
end

BASE_URL = "http://search.twitter.com/search.json?q="    			# remote API url
query     = ARGV.shift                                              # query string
query_url = BASE_URL + URI.escape(query)                            # putting the 2 together

puts " ======================================== "                   # fancy output
puts " You seached for #{query}"
#puts "   #{query_url}"                                              # fancy output

object = open(query_url) do |v|                                     # call the remote API
  input = v.read                                                    # read the full response
#  puts input                                                       # un-comment this to see the returned JSON magic
  JSON.parse(input)                                                 # parse the JSON & return it from the block
end

object['results'].each do |t|
  puts " ======================================== "
  puts " #{t['from_user_name']}"
  puts "  @#{t['from_user']}"
  puts
  puts "   #{t['text']}"
  puts
  puts " #{t['created_at']}"
end
puts " ======================================== "                   # fancy output