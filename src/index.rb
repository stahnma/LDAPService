#!/usr/bin/ruby -w

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'pp'
require 'cgi'
require 'cgi/session'

markup=""
cgi = CGI.new("html4")
config = loadConfig('../config2.yaml')
  session = CGI::Session.new(cgi, 'new_session' => true)
session['config'] = config

#TODO make a session broker
#TODO fix session dumping in /tmp

if not cgi.has_key?('action') 
  markup = renderfarm()
elsif cgi.params['action'].to_s == 'login'
  session['ldap']  = login(cgi['login'], cgi['password']) 
  session['login'] = cgi['login'].to_s
  if (session['ldap'])
     markup = renderGood(session)
  end
elsif cgi.params['action'].to_s == 'update'
  markup = updateLdap(session, cgi.params)
else
  #TODO Make error page
  markup += '<b> Fell to default</b><br/> ' 
end

#TODO make a render engine class or callout
cgi.out{ 
   markup
}
