#!/usr/bin/ruby -w

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'presentation'
require 'pp'
require 'cgi'
require 'cgi/session'


config = loadConfig('../configuration.yaml')
stream = ""
cgi = CGI.new("html4")
$session = CGI::Session.new(cgi)
$session['config'] = config


def streamLogin(cgi)
 stream = " "
 options = {}
 if cgi.params['action'].to_s == 'login'
    begin
      $session['ldap']  = login(cgi['login'], cgi['password'])
      $session['login'] = cgi['login'].to_s
      $session['password'] = cgi['password'].to_s
    rescue  LDAP::ResultError
       options = {:errors => "Invalid Login/Password Combination"}
       stream += renderfarm('login.erb', options)
    end
  end
  return stream.to_s
end

if activeSession($session)
  # retreive user writable fields
  options = manageUser($session)
  if cgi.params['action'].to_s == 'update'
      # options needs to be an array
      if updateLdap($session, cgi.params)
         a = 'q'
         options[:notice] = "Account Updated Sucessfully."
          #stream += renderfarm('manage.erb', options)
          # now show updated with notice
      end
  #stream += renderfarm('manage.erb', options)
  end
  stream += renderfarm('manage.erb', options)
elsif cgi.params['action'].to_s != 'login'
  # need to login
  stream += renderfarm('login.erb')
else
  stream += streamLogin(cgi)
  if activeSession($session)
    stream += "manage2"
  end
end
#stream += cgi.params.inspect
cgi.html{
  cgi.out{ stream } 
}
