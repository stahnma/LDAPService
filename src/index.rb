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
    rescue  LDAP::ResultError => boom
       #options = {:errors => "Invalid Login/Password Combination"}
       options = {:errors => boom}
       stream += renderfarm('login.erb', options)
    end
  end
  if cgi.params['action'].to_s == 'logout'
     logout(cgi)
  end
  if cgi.params['action'].to_s == 'forgot'
     stream += 'forgot pw'
     # obtain login name
     # email it to registered account email address
     # allow old pw to still be used
     # allow user to reset their pw
     #
  end
  return stream.to_s
end

def selfManage(cgi)
  # retreive user writable fields
  options = manageUser()
  if cgi.params['action'].to_s == 'update'
      # options needs to be an array
      begin
         updateLdap(cgi.params)
         #if newpw.length() > 3 
          # rebind and check for errors
          # $session['ldap']  = login(cgi['login'], newpw.to_s)
          # $session['login'] = cgi['login'].to_s
          # $session['password'] = newpw.to_s
          # options = manageUser()
          # options[:notice] = "Account and Password Updated Sucessfully."
         #end
         options = manageUser()
         options[:notice] = "Account Updated Sucessfully."
      rescue LDAP::ResultError, ArgumentError => boom
         options[:errors] = boom.to_s
      end
  end
  stream = renderfarm('manage.erb', options)
  return stream
end

# see if this is a good session
stream += streamLogin(cgi)
if activeSession()
  # Show management screen
  stream += selfManage(cgi) 
elsif cgi.params['action'].to_s != 'login'
  # need to login
  stream += renderfarm('login.erb')
end
#stream += cgi.inspect
cgi.html{
  cgi.out{ stream } 
}
