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

def login(username, password)
  l  = LdapConnection.new()
  begin 
    l.login(username, password)
  rescue LDAP::ResultError => boom
    raise LDAP::ResultError, "Invalid User/Password combination", caller
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

#TODO make sure they are actually authenticated
def updateLdap(session, options = {} ) 
  config = session['config']
  options.delete('action')
  options.each do | k , v|
    if v.to_s.size.to_i < 1
       options[k] = [ ] 
    end
  end
  l = LdapConnection.new
  l.login(session['login'], session['password'])
  return l.update(session['login'], options)
  # return l.getUserEntry('stahnma')
end

def retrInfo(session, fields)
  l = LdapConnection.new
  l.login(session['login'], session['password'])
  entry = l.getUserEntry(session['login'])
  return entry
end
