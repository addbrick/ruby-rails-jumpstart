require 'open-uri'
require 'json'
require 'pp'

if ARGV.empty?
  puts "ERROR: wrong number of arguments (0 for 1)"
  exit
end

BASE_URL = "http://api.duckduckgo.com/?format=json&pretty=1&q=define+" # remote API url # added define+ to get the def
query     = ARGV.shift                                              # query string
query_url = BASE_URL + URI.escape(query)                            # putting the 2 together

object = open(query_url) do |v|                                     # call the remote API
  input = v.read                                                    # read the full response
  #  puts input                                                       # un-comment this to see the returned JSON magic
  JSON.parse(input)                                                 # parse the JSON & return it from the block
end

puts " ======================================== "                   # fancy output
puts "   #{object['Heading']}"
puts "     #{object['Abstract']}"
puts "\n #{object['AbstractURL']}"
puts " ======================================== "                    # fancy output