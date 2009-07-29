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


def streamLogin(session, cgi)
 stream = " "
 options = {}
 if cgi.params['action'].to_s == 'login'
    begin
      session['ldap']  = login(cgi['login'], cgi['password'])
      session['login'] = cgi['login'].to_s
      session['password'] = cgi['password'].to_s
    rescue  LDAP::ResultError
       options = {:errors => "Invalid Login/Password Combination"}
       stream += renderfarm('login.erb', options)
    end
  end
  if cgi.params['action'].to_s == 'logout'
     session.close
     session.delete
     print cgi.header({'Status' => '302 Moved', 'location' =>  '/lds/index.rb'})
     exit 0
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

def selfManage(session, cgi)
  # retreive user writable fields
  options = manageUser($session)
  if cgi.params['action'].to_s == 'update'
      # options needs to be an array
      begin
          updateLdap($session, cgi.params)
         options[:notice] = "Account Updated Sucessfully."
      rescue LDAP::ResultError
         options[:errors] = "Insufficient Access to Update Attributes."
      end
  end
  stream = renderfarm('manage.erb', options)
  return stream
end

# see if this is a good session
stream += streamLogin($session, cgi)
if activeSession($session)
  # Show management screen
  stream += selfManage($session, cgi) 
elsif cgi.params['action'].to_s != 'login'
  # need to login
  stream += renderfarm('login.erb')
end
#stream += cgi.inspect
cgi.html{
  cgi.out{ stream } 
}
