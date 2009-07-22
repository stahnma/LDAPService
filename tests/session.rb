#!/usr/bin/ruby
require 'cgi'
require 'cgi/session'

cgi = CGI.new("html3")
sess = CGI::Session.new(cgi)
if sess['lastaccess']
  msg = "<p>Last here on #{sess['lastaccess']}"
else
  msg = "<p>You must be new here"
end
