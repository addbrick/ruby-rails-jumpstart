#
# The Number Guessing Game
#
# To run, do: ruby guess.rb 10
#
# For a harder game, increase the limit
#


#
# we use a 'say' method instead of just calling 'puts' so that we
# can flush stdout as well
#
def say(msg)
  $stdout.puts msg
  $stdout.flush
end

#
# validate that a string is a valid integer
#
def valid?(str)
  !str.nil? && str.match(/^\d+$/)
end

#
# repeatedly ask the user until the user gives an integer
#
def ask(limit)
  response = nil

  until valid? response
    say "ERROR:i_dont_understand" unless response.nil?

    say "GUESS(#{limit})"
    response = gets
    
    if response == "exit\n" || response == "quit\n"
      say "FAIL:exiting"
      exit
    end
  end

  response.to_i
end

#
# core guessing game algorithm
#
def play_game(limit)
  chosen = rand(limit) + 1
  found  = false

  until found
    guess = ask(limit)
  
    if guess < chosen
      say "WRONG:too low"
    elsif guess > chosen
      say "WRONG:too high"
    else
      found = true
    end
  end

  say "CORRECT:exiting"
end


LIMIT = (ARGV.shift || "10").to_i

play_game LIMIT
