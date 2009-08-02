#!/usr/bin/ruby

require 'erb'
require 'ldap_utils'
require 'utils'
require 'cgi'
require 'cgi/session'

def activeSession(session)
  return !(session['login'].nil?)
end

def renderEngine(session, options)
   findFields(session,options)
end

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    data += line
  end
  return data
end

def logout(session, cgi)
     begin 
       session.close
       session.delete
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

def manageUser(session, options = {})
   begin
      config = session['config']
   rescue NoMethodError => boom
      raise LDAP::ResultError, "Unable to read $session", caller
   end
   options['fields'] = {}
   config['UserWritableAttrs'].each do |k, v|
     options['fields'][k] = v 
   end
   options['entry'] = retrInfo(session, options['fields'])
   return options
#   return renderfarm('manage.erb', options)
end 

#TODO test to make sure they are actually authenticated
def updateLdap(session, options = {} ) 
  config = session['config']
  options.delete('action')
  options.each do | k , v|
    if v.to_s.size.to_i < 1
       options[k] = [ ] 
    end
  end
  # Now handle the userPassword stuff
  if options['userPassword'].length < 1
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
  l.login(session['login'], session['password'])
  result =  l.update(session['login'], options)
  varbug(result)
  if result and options['userPassword'].length > 1
       session.close
       session.delete
       exit 0
  end
  return result
end


def varbug(var)
   File.open('/tmp/foo', 'w+') {|f| f.write("The value for this variable is #{var}\n") }
end

def retrInfo(session, fields)
  l = LdapConnection.new
  l.login(session['login'], session['password'])
  entry = l.getUserEntry(session['login'])
  return entry
end
