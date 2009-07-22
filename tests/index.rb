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
config = loadConfig('../config2.yaml')
puts "Content-Type: text/html\n\n"
COOKIE_NAME='lds_session'
cookie = cgi.cookies[COOKIE_NAME]
pp cookie
if cookie.empty?
  puts "New session, new cookie <br/>"
  session = CGI::Session.new(cgi, 'new_session' => true)
  pp session
  cookie = CGI::Cookie.new("name" => 'lds', 
                            "values" => session.session_id,  
                            "expires" => Time.local(Time.now.year + 2, Time.now.mon, Time.now.day, 
                                                    Time.now.hour, Time.now.min, Time.now.sec) )
  cgi.header("cookie" => cookie)
else
  puts "Found cookie, or session"
  session = CGI::Session.new(cgi, 'session_id' => 'thingireadfromcookie' , 'new_session' => false)
end
session['config'] = config
puts "<br/><br />Cookie Info <br />"
puts cookie.to_s
puts "<br><br>"
cgi.out("cookie" => cookie) {'blah'}
exit 0


if not cgi.has_key?('action') 
  renderfarm()
elsif cgi.params['action'].to_s == 'login'
  session['ldap']  = login(cgi['login'], cgi['password']) 
  session['login'] = cgi['login'].to_s
  if (session['ldap'])
     renderGood(session)
  end
elsif cgi.params['action'].to_s == 'update'
  puts "Content-Type: text/html\n\n"
  puts "Action is update."
  puts cgi.params
  updateLdap(session, cgi.params)
else
  #TODO Make error page
  puts "Content-Type: text/html\n\n"
  puts "Put error page here."
  
end
session.close
