#!/usr/bin/ruby

require 'erb'
require 'ldap_utils'
require 'utils'
require 'cgi'
require 'cgi/session'
require 'password'

def activeSession()
  return !($session['login'].nil?)
end

def renderEngine(options)
   findFields(options)
end

def logout(cgi)
     begin 
       $session.close
       $session.delete
     rescue 
        # nothing? 
     end  
       print cgi.header({'Status' => '302 Moved', 'location' =>  '/lssm/index.rb'})
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
   options[:write_fields] = {}
   config['UserWritableAttrs'].each do |k, v|
     options[:write_fields][k] = v 
   end
   options[:read_fields] = {}
   config['ReadOnlyAttrs'].each do |k, v|
     options[:read_fields][k] = v 
   end
   options[:entry] = retrInfo()
   return options
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
  pw = PW.new(options['userPassword'])
  if pw.empty?
    options.delete('userPassword')
    options.delete('confirmPassword')
  elsif ! (pw == options['confirmPassword'])
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
       # Rebind happens too quickly if replciation hasn't occurred yet
       sleep 2
       $session['ldap'] = l.login($session['login'].to_s, options['userPassword'].to_s)
  end
  return result
end


def retrInfo()
  l = LdapConnection.new
  l.login($session['login'].to_s, $session['password'].to_s)
  entry = l.getUserEntry($session['login'])
end

def adminBind()
  #config = $session['config']
  config = loadConfig('../configuration.yaml')
  l  = LdapConnection.new
#  pp config
#  TODO generate a an error if this bind can't happen
  begin
    l.login(config['LDAPInfo']['BindDN'], config['LDAPInfo']['BindPW'])
  rescue LDAP::ResultError => boom
    raise LDAP::ResultError, boom.to_s, caller
  end
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

def lookupUID(value, field)
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
  return entry['uid'][0]
end


def adminUpdate(login, options)
  l = adminBind
  options.delete('confirmPassword')
  l.update(login, options)
end
