
filename = ARGV.shift                   # get a filename from the command line arguments

unless filename                         # we can't work without a filename
  puts "no filename specified!"
  exit
end

lines = 0                               # a humble line counter
unique_users = "unknown"                # someday, this will work
unique_pages = "unknown"                # someday, this will work
most_active_day = "unknown"             # someday, this will work
most_active_user = "unknown"            # someday, this will work
most_active_page = "unknown"            # someday, this will work

open(filename).each do |m|              # loop over every line of the file
  m.chomp!                              # remove the trailing newline
  values = m.split(",")                 # split comma-separated fields into a values array

  # ...

  lines += 1                            # bump the counter
end

puts "total lines: #{lines}"                  # output stats
puts "unique users: #{unique_users}"          # someday, this will work
puts "unique pages: #{unique_pages}"          # someday, this will work
puts "most active day: #{most_active_day}"    # someday, this will work
puts "most active user: #{most_active_user}"  # someday, this will work
puts "most active page: #{most_active_page}"  # someday, this will work