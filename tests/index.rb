#!/usr/bin/env ruby
#

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'pp'
require 'cgi'
require 'cgi/session'
require 'cgi/session/pstore'

cgi = CGI.new("html4")
begin
    session = CGI::Session.new(cgi, 'new_session' => false)
    session.delete
rescue ArgumentError  # if no old session
end
session = CGI::Session.new(cgi, 'new_session' => true)

if not cgi.has_key?('action') 
  renderLogin()
elsif cgi.params['action'] = 'login'
  session['ldap']  = login(cgi['login'], cgi['password']) 
  if (session['ldap'])
     renderGood(session['ldap'])
  end
end
session.close
