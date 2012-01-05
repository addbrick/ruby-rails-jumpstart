
# RESTFul Web Services using Sinatra

* Run the script using "ruby application.rb"

You should study the code for application.rb and get to know it well.


Test out the service using the following commands:

* curl -v -v http://localhost:4567/
* curl -v -v http://localhost:4567/ideas
* curl -v -v -X POST --data-binary '{"foo":"bar"}' http://localhost:4567/ideas    # note the id returned!
* curl -v -v http://localhost:4567/ideas/the-random-id-from-before
* curl -v -v -X PUT --data-binary '{"foo":"BUZZ"}' http://localhost:4567/ideas/the-random-id-from-before
* curl -v -v -X DELETE http://localhost:4567/ideas/the-random-id-from-before
* curl -v -v http://localhost:4567/ideas

Next Steps:

* Modify application.rb to have an Inventor model class (in addition to Idea); the program should create! one instance of Inventor named 'ANONYMOUS' at startup and store it in a constant
* Modify application.rb so that the Idea model has a belongs_to relationship to Inventor;
  if an inventor isn't specified on POST '/ideas', set it to the 'ANONYMOUS' one
  if an inventor is specified, associate it by exact match the 'id' or 'name' attribute (if not found, create a new Inventor with the given name and associate it)
* Create a GET '/inventors' endpoint that returns a list of all inventors
* Create a DELETE '/inventors/:id' endpoint that removes an inventor and all its associated ideas

Advanced:

* Add a POST '/nuke' endpoint that destroys all ideas and inventions in the system
* Add a secret password parameter that is required to invoke the '/nuke' endpoint: 'yesireallymeanit'
* Add a validation to the Idea model that ensures it always has "category" and "text" string attributes specified
* Add a validation to the Inventor model that ensures it always has "name" string attribute specified
* Add begin/rescue/end blocks to associated methods and return status 400, body "bad request" when validation fails

Extra Challenging:

* Add a required "gender" attribute to the Inventor model
* Integrate first and last name parsing of the 'name' attribute into the Inventor class using this gem:
  https://github.com/dburkes/people_places_things
* Design a method that takes a first name as input and makes a remote call to the Rapleaf API for name gender detection:
  https://www.rapleaf.com/developers/try_name_to_gender?query=$NAME$
* Write and integrate an ActiveModel validation into the Inventor class that raises an error if the first name and gender don't match with probability > 80%; if the name is not recognized, validation should pass


