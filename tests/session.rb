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

count = (sess['accesscount'] || 0 ).to_i
count +=1
msg << "<p>Number of visits #{count}</p>"
sess['accesscount'] = count
sess['lastaccess'] = Time.now.to_s
sess.close
cgi.out {
  cgi.html {
    cgi.body {
       msg
    }
  }
}

