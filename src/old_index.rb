#!/usr/bin/ruby -w

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'pp'
require 'cgi'
require 'cgi/session'

markup=""
config = loadConfig('../configuration.yaml')

cgi = CGI.new("html4")
session = CGI::Session.new(cgi)
session['config'] = config


if not cgi.has_key?('action') and not activeSession(session)
  markup += renderfarm()
elsif cgi.params['action'].to_s == 'login'
  begin 
    session['ldap']  = login(cgi['login'], cgi['password']) 
    session['login'] = cgi['login'].to_s
    session['password'] = cgi['password'].to_s
  rescue  LDAP::ResultError
     options = {:errors => "Invalid Login/Password Combination"}
     markup += renderfarm('login.erb', options)
  end
  session['login'] = cgi['login'].to_s
  if (session['ldap'])
     markup += renderGood(session)
  end
elsif cgi.params['action'].to_s == 'update'
  if updateLdap(session, cgi.params).to_s
     options = {:notice => "Account Updated Sucessfully."}
     markup += renderGood(session, options)
     #markup += renderfarm('manage.erb', options)
  end
else
  markup += '<b> Fell to default</b><br/> ' 
end

#markup += "Missed the if"
# Call render here only after all options are decided upon
options = {:notice => "Stuff" } 
renderEngine(session, options)
cgi.out{ 
   markup
}
session.close()
