
# Building Real-Time Web Applications using Backbone.js and Pusher

* Run the script using "ruby application.rb"

You should study the code for application.rb and get to know it well.


Test out the service by visiting http://localhost:4567/ in your browser.

Next Steps:

* In the presence section, use twitter's user api and show an avatar if
  the user's screen name exists:
  http://twitter.com/api/users/profile_image/USERNAME
* Instead of having an endless number of message div's, create an outer
  div with scroll bars that contains a maximum of 1000 messages
* Format messages using the JS library from https://github.com/twitter/twitter-text-js
* Implement playing a sound (bell, whistle, etc) using javascript when
  another user writes a message to @USERNAME when USERNAME is your handle
* Implement rewriting image links (end in .gif, .png, .jpg case-insensitive)
  as thumbnail-size 'img' html tags within the message

Advanced:

* Add a 'clear' button that will clear the chat window in *all* connected clients

More Advanced:

* Add a 'multiple rooms' capability to the app - there should be multiple scrollable div's that have independent message inputs
* The multiple rooms should use the same pusher channel, using a "room" attribute that dispatches to the correct div

