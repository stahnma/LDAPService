#!/usr/bin/env ruby

require 'utils'
require 'ldap'
require 'pp'


class LdapConnection 
  
   def initialize()
     config = loadConfig('../config2.yaml')
     @ldapconf = config['LDAPInfo']
     @conn = LDAP::Conn.new(@ldapconf['Host']) 
   end
   
   def login(user, pw)
     dn = 'uid=' + user + ',ou=people,' + @ldapconf['BaseDN']
     if pw.nil? or pw == ''
       raise LDAP::ResultError, "Invalid User/Password combination", caller
     end
        
     begin
       @bound = @conn.bind(dn,  pw) 
     rescue LDAP::ResultError
       raise LDAP::ResultError, "Invalid User/Password combination", caller
       return false
     end
     return true
   end

   def getUsers()
     @bound.search(@ldapconf['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=*)") do |user|
       return user
     end
   end
  
   def getUserEntry(uid)
     @bound.search(@ldapconf['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=#{uid})") do |user|
         return user.to_hash
     end
   end

   def update()
   end
end

#TODO handle if password is not defined in either spot
def password_check( yamls )
  # Check to see if it's defined in an ENV var
  password = ""
  if ENV['LDAP_PASSWORD']
    password = ENV['LDAP_PASSWORD']
  else
    password = yamls['LDAPInfo']['BindPW']
  end
  return password
end

#conn = LDAP::Conn.new(yamls['LDAPInfo']['Host'])
#password = password_check(yamls)
#conn.bind(yamls['LDAPInfo']['BindDN'],  password) do |bound|
#  bound.search(yamls['LDAPInfo']['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=*)") do |user|
  #     puts "Gecos: #{user['gecos']}"
  #     puts "UID: #{user['uid']}"
#  end
#end

# connect to the LDAP directory

# authenticate a user
# create a session
# bind as a manager

#l  = LdapConnection.new()
#puts l.inspect
#l.login('stahnma', ENV['LDAP_PASSWORD'])
#l.getUsers()
#l.getUserEntry('stahnjd')
#l.connect()