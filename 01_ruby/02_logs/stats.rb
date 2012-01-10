# checks if key is in hash, if so increment value, if not add it
def check_for_key_in_hash(hash, key)
  if hash.keys.include?(key)
    (block_given? ? yield(true) : hash[key] += 1)
    return false
  else
  	(block_given? ? yield(false) : hash[key] = 1)
  	return true
  end
end

# returns most_active, which is the key with the highest count in hash
def find_most_active(hash, most_active)
  hash.each { |key, count| most_active = key if most_active == "unknown" || (block_given? ? yield(hash, count, most_active) : count > hash[most_active]) }
  most_active
end

filename = ARGV.shift                   # get a filename from the command line arguments

unless filename                         # we can't work without a filename
  puts "no filename specified!"
  exit
end

firstLine = true
lines = 0                               # a humble line counter
unique_users = 0#"unknown"                # someday, this will work
unique_pages = 0#"unknown"                # someday, this will work
most_active_day = "unknown"             # someday, this will work"
most_active_user = "unknown"            # someday, this will work
most_active_page = "unknown"            # someday, this will work
most_active_page_unique_users = "unknown"

user_hash = Hash.new
page_hash = Hash.new
date_hash = Hash.new

open(filename).each do |m|              # loop over every line of the file
  # there is probably an easier way to skip first line (aka header)
  if firstLine
   firstLine = false
   next
  end
  
  m.chomp!                              # remove the trailing newline
  values = m.split(",")                 # split comma-separated fields into a values array

  check_for_key_in_hash(date_hash, values[0])
  
  unique_users += 1 if check_for_key_in_hash(user_hash, values[1])
  
  unique_pages += 1 if check_for_key_in_hash(page_hash, values[2]) { |in_hash| 
  																		if in_hash
  																		  page_hash[values[2]]["total_views"] += 1
  																		  unless page_hash[values[2]]["unique_users_view"].include?(values[1])
  																		    page_hash[values[2]]["unique_users_view"] << values[1]
  																		  end
  																		else
  																		  page_hash[values[2]] = Hash["total_views", 1, "unique_users_view", [values[1]]]
  																		end }

  lines += 1  # bump the counter
  
end

most_active_day = find_most_active(date_hash, most_active_day)
most_active_user = find_most_active(user_hash, most_active_user)
most_active_page = find_most_active(page_hash, most_active_page) { |hash, count, most_active| count["total_views"] > hash[most_active]["total_views"] }
most_active_page_unique_users = find_most_active(page_hash, most_active_page_unique_users) { |hash, count, most_active| count["unique_users_view"].length > hash[most_active]["unique_users_view"].length }

puts "total lines: #{lines}"                  # output stats
puts "unique users: #{unique_users}"          # someday, this will work
puts "unique pages: #{unique_pages}"          # someday, this will work
puts "most active day: #{most_active_day}"    # someday, this will work
puts "most active user: #{most_active_user}"  # someday, this will work
puts "most active page: #{most_active_page}"  # someday, this will work
puts "most active page unique users: #{most_active_page_unique_users}"

# used for visual test/confirmation that count is working properly
def print_counts(hash)
  hash.each { |key, count| puts "#{key} -- #{count}\n---------\n" }
end

#print_counts(date_hash)
#print_counts(user_hash)
#print_counts(page_hash)

#puts " ------------------------------- "
#puts page_hash
#puts " ------------------------------- "
