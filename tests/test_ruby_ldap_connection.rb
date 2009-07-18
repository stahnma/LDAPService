#!/usr/bin/env ruby
#
require 'yaml'
require 'ldap'
require 'pp'


yamls = YAML::load(File.open("../configuration.yaml"))

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

conn = LDAP::Conn.new(yamls['LDAPInfo']['Host'])
password = password_check(yamls) 
conn.bind(yamls['LDAPInfo']['BindDN'],  password) do |bound|
  bound.search(yamls['LDAPInfo']['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=*)") do |user|
       puts "Gecos: #{user['gecos']}"
       puts "UID: #{user['uid']}" 
  end
end


