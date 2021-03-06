#!/usr/bin/ruby -w

require 'utils'
require 'ldap_utils'
require 'generate_login'
require 'presentation'
require 'pp'
require 'cgi'
require 'cgi/session'
require 'mail'
require 'password'
require 'logger'


config = loadConfig('../configuration.yaml')
stream = ""
cgi = CGI.new("html4")
options = {} 
$session = CGI::Session.new(cgi, 'session_expires' => Time.now + config['PWReset']['Timeout'] * 60 * 60)
$session['config'] = config
# Check for SSL
unless ENV['SERVER_PORT'] == "443" or ENV['SERVER_PORT'] == "4443"
  stream = " " 
  options[:errors] = "Please use https to connect."
  stream += renderfarm('ssl.erb', options)
  cgi.html{
    cgi.out{ stream } 
  }
  exit 0
end
#
def streamLogin(cgi)
 stream = " "
 options = {}
 if cgi.params['action'].to_s == 'login'
    begin
      $session['ldap']  = login(cgi['login'], cgi['password'])
      $session['login'] = cgi['login'].to_s
      $session['password'] = cgi['password'].to_s
    rescue  LDAP::ResultError => boom
       options[:errors]  =  boom.to_s
       options[:forgot_link] = "/password/?action=forgot"
       stream += renderfarm('login.erb', options)
    end
  end
  if cgi.params['action'].to_s == 'logout'
     logout(cgi)
  end
  return stream.to_s
end

def selfManage(cgi)
  # retreive user writable fields
  stream = ""
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
  stream += renderfarm('manage.erb', options)
  return stream
end

# see if this is a good session
stream += streamLogin(cgi)
if activeSession() and cgi.params['action'].to_s != 'forgot' and $session['password']
  # Show management screen
  stream += selfManage(cgi) 
elsif cgi.params['action'].to_s != 'login' and cgi.params['action'].to_s != 'forgot'
  # need to login
  options[:forgot_link] = "/password/?action=forgot"
  stream += renderfarm('login.erb', options)
elsif cgi.params['action'].to_s == 'forgot'
  if cgi.params['step'].to_s == 'validate'
     unless cgi.params['login'].to_s.empty?
       type = emailOrLogin(cgi.params['login'].to_s) 
       begin
         email_address = lookupEmail(cgi.params['login'].to_s, type)
         options[:session_id] = $session.session_id 
         $session['email'] = email_address
         $session['login'] = lookupUID(cgi.params['login'].to_s, type)
         options[:uri] = ENV['HTTP_REFERER'] + "&step=reset&_session_id=" + options[:session_id]
         resetMail(email_address, options)
         options[:notice] = "Verification email sent."
       rescue LDAP::ResultError => boom
         options[:errors] = boom.to_s
       end
     else
        options[:errors] = "You need to enter something."
     end
     options[:login_link] = "/password"
     stream += renderfarm('forgot.erb', options)
  elsif cgi.params['step'].to_s == 'reset'
     options[:login] = $session['login']
     stream += renderfarm('password_reset.erb', options)
  elsif cgi.params['step'].to_s == 'adminreset'
     # Validate a password was Entered (assigned as arrays)
     password = { 'userPassword' => cgi.params['userPassword'], 
                  'confirmPassword' => cgi.params['confirmPassword'] }
     options[:login] = $session['login']
     pw = PW.new(password['userPassword'].to_s)
     if ! pw.empty? and (pw == password['confirmPassword'].to_s)
         begin
           adminUpdate($session['login'] , password)
           options[:notice] = "Account Updated Sucessfully."
           # Logout hack here
           $session.close
           $session.delete
         rescue 
           options[:errors] = "ZOMG"
         end
         # probably logout here
         stream += renderfarm('password_reset.erb', options)
     else
         options[:errors] = "Passwords do not match."
         stream += renderfarm('password_reset.erb', options)
     end
  else 
     options[:login_link] = "/password"
     stream += renderfarm('forgot.erb', options)
  end
end

cgi.html{
  cgi.out{ stream } 
}
