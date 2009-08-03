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
options = {} 
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
#  if cgi.params['action'].to_s == 'forgot'
#     stream = renderfarm('forgot.erb', options)
     # obtain login name
     # email it to registered account email address
     # allow old pw to still be used
     # allow user to reset their pw
     #
#  end
  return stream.to_s
end

def selfManage(cgi)
  # retreive user writable fields
  options = manageUser()
  if cgi.params['action'].to_s == 'update'
      begin
         updateLdap(cgi.params)
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
if activeSession() #and cgi.params['action'].to_s != 'forgot'
  # Show management screen
  stream += selfManage(cgi) 
elsif cgi.params['action'].to_s != 'login' and cgi.params['action'].to_s != 'forgot'
  # need to login
  stream += renderfarm('login.erb')
elsif cgi.params['action'].to_s == 'forgot'
  if cgi.params['step'].to_s == 'validate'
     # Do the stuff
     #  bind as a privileged user
     #  validate the login
     #  look for an email address
     options[:notice] = "Verification email sent."
     stream += renderfarm('forgot.erb', options)
  else 
     stream += renderfarm('forgot.erb')
  end
end
#stream += cgi.inspect
cgi.html{
  cgi.out{ stream } 
}
