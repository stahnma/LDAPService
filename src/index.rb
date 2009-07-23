#!/usr/bin/ruby -w

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'pp'
require 'cgi'
require 'cgi/session'


config = loadConfig('../configuration.yaml')
stream = ""
cgi = CGI.new("html4")
session = CGI::Session.new(cgi)


if activeSession(session)
  stream += "Welcome back"
else
  stream += "You need to login"
  session['login'] = 's'
end


cgi.html{
  cgi.out{ stream } 
}



# if session.is_new
#   login
# else
#   manage
# end
