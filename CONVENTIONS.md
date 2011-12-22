# Ruby Conventions

Here's a great place to start: https://github.com/bbatsov/ruby-style-guide

And by conventions, we mean educated but still somewhat
arbitrary tidbits that make code feel better to our
collective spirits. These are subject to change as our
collective spirits grow and learn together. :)

Thanks to the great Rubyists who contributed to this list.


# Function definitions

function definitions should use parens when there are arguments

   def foo(msg)
     puts :bar
   end


# Method invocations

The convention for using parens on invocations is slightly less clear,
but here's what I advocate:

Only omit parens if the method invocation is the only thing on the
current line, i.e.:

   method arg
   method :k1 => 1, :k2 => 2

But:

   var = method(arg)
   method(arg).to_a
   obj.method(:k1 => 1, :k2 => 2)
   obj.method(arg)

