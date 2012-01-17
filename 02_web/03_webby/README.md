
# Building Web Applications using Sinatra & AJAX

* Run the script using "ruby application.rb"

You should study the code for application.rb and get to know it well.


Test out the service by visiting http://localhost:4567/ in your browser.

Next Steps:

* Add an "about" page as static HAML containing some witty prose and link it into the nav bar of the app
* Read http://www.padrinorb.com/guides/application-helpers : especially the part about error_messages 
* Add model validation for location name (must be present), latitude and longitude (must be present & valid floating-point numbers)
* When model validation fails, display an error message in the form

* Implement a list of duckduckgo queries via RUBY, similar to locations:
* DuckDuckGo : Model should include query name & query text
* DuckDuckGo : Use the search api from 01_ruby/03_web/duck.rb (the duckduckgo part)
* DuckDuckGo : The 'show.haml' page for DuckDuckGo should display search results retrieved from the remote web service *in the ruby code*

* Implement a list of twitter queries via AJAX, similar to locations:
* Read these links to get some ideas:
  http://net.tutsplus.com/tutorials/javascript-ajax/5-ways-to-make-ajax-calls-with-jquery/
  http://webhole.net/2009/11/28/how-to-read-json-with-javascript/
  http://www.chazzuka.com/twitter-api-jquery-jsonp-how-to-229/
* Twitter : Model should include query name & query text
* Twitter : Use the search api from 01_ruby/03_web/duck.rb (the twitter part)
* Twitter : The 'show.haml' page for Twitter should display search results retrieved from the remote web service *as AJAX using JSONP*

Advanced:

* Add a 'nuke' interface that deletes all data in the app
* Add a User model (with name, email, and password) and a 'create new user' and 'list users' interface in the app

Extra Advanced:

* Add a login form to the app, and protect all page views using a scheme similar to this:
  http://stackoverflow.com/questions/3559824/what-is-a-very-simple-authentication-scheme-for-sinatra-rack
