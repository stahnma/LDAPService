#!/usr/bin/env ruby

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'pp'
require 'cgi'
require 'cgi/session'

cgi = CGI.new("html4")
config = loadConfig('../config2.yaml')
#puts "Content-Type: text/html\n\n"
  session = CGI::Session.new(cgi, 'new_session' => true)
#  pp session
#  session = CGI::Session.new(cgi,  'new_session' => false)
session['config'] = config

#TODO make a session broker
#TODO fix session dumping in /tmp

if not cgi.has_key?('action') 
  renderfarm()
elsif cgi.params['action'].to_s == 'login'
  session['ldap']  = login(cgi['login'], cgi['password']) 
  session['login'] = cgi['login'].to_s
  if (session['ldap'])
     renderGood(session)
  end
elsif cgi.params['action'].to_s == 'update'
  #puts "Content-Type: text/html\n\n"
  #puts "Action is update."
  #puts cgi.params
  updateLdap(session, cgi.params)
else
  #TODO Make error page
  #puts "Content-Type: text/html\n\n"
  #puts "Put error page here."
  markup += '<b> Fell to default</b><br/> ' 
end

#TODO make a render engine class or callout
