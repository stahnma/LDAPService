#!/usr/bin/ruby

require 'erb'
require 'ldap_utils'
require 'utils'
require 'cgi'
require 'cgi/session'

def activeSession()
  return !($session['login'].nil?)
end

def renderEngine(options)
   findFields(options)
end

#def get_file_as_string(filename)
#  data = ''
#  f = File.open(filename, "r")
#  f.each_line do |line|
#    data += line
#  end
#  return data
#end

def logout(cgi)
     begin 
       $session.close
       $session.delete
     rescue 
        # nothing? 
     end  
       print cgi.header({'Status' => '302 Moved', 'location' =>  '/lds/index.rb'})
     exit 0
end


def login(username, password)
  l  = LdapConnection.new()
  begin 
    l.login(username, password)
  rescue LDAP::ResultError => boom
    raise LDAP::ResultError, boom.to_s, caller
  end
  return l
end

def manageUser(options = {})
   begin
      config = $session['config']
   rescue NoMethodError => boom
      raise LDAP::ResultError, "Unable to read $session", caller
   end
   options['fields'] = {}
   config['UserWritableAttrs'].each do |k, v|
     options['fields'][k] = v 
   end
   options['entry'] = retrInfo(options['fields'])
   return options
#   return renderfarm('manage.erb', options)
end 

#TODO test to make sure they are actually authenticated
def updateLdap(options = {} ) 
  config = $session['config']
  options.delete('action')
  options.each do | k , v|
    if v.to_s.size.to_i < 1
       options[k] = [ ] 
    end
  end
  # Now handle the userPassword stuff
  if options['userPassword'].to_s.length < 1
    options.delete('userPassword')
    options.delete('confirmPassword')
  elsif options['userPassword'] != options['confirmPassword']
    raise ArgumentError, "Passwords do not match.", caller
    return  false
  else
    # Remove the confirmation if it matched properly
    options.delete('confirmPassword')
  end
  
  l = LdapConnection.new
  l.login($session['login'], $session['password'])
  result =  l.update($session['login'], options)
  # Do something about logging out the user
  if options['userPassword'].to_s.length > 1
       $session['password'] =  options['userPassword'].to_s
       l.unbind()
       $session['ldap'] = l.login($session['login'].to_s, $session['password'].to_s)
       a = "Inside if"
       varbug(a)
  end
  return result
end


def varbug(var)
   File.open('/tmp/foo', 'w+') {|f| f.write("The value for this variable is #{var}\n") }
end

def retrInfo( fields)
  l = LdapConnection.new
  l.login($session['login'], $session['password'])
  entry = l.getUserEntry($session['login'])
  return entry
end

def adminBind()
  #config = $session['config']
  config = loadConfig('../configuration.yaml')
  l  = LdapConnection.new
#  pp config
  l.login(config['LDAPInfo']['BindDN'], config['LDAPInfo']['BindPW'])
  return l
end

def emailOrLogin(login)
  if login.chomp.to_s.length < 1
     return false
  end

  if login =~ /@/
    return 'mail'
  else
    return 'uid'
  end
end

def lookupEmail(value, field)
  l = adminBind 
  if field == 'mail'
    begin
      entry = l.getEntryByMail(value)
    rescue LDAP::ResultError => boom
      raise LDAP::ResultError, boom.to_s, caller
    end
  elsif field == 'uid'
    begin
      entry = l.getUserEntry(value)
    rescue LDAP::ResultError => boom
      raise LDAP::ResultError, boom.to_s, caller
    end
  end
  return entry['mail'][0] 
end

def sendmail()
end

