#!/usr/bin/env ruby
#
require 'yaml'
require 'ldap'
require 'pp'
require 'erb'

yamls = YAML::load(File.open("../configuration.yaml"))

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

conn = LDAP::Conn.new(yamls['LDAPInfo']['Host'])
password = password_check(yamls) 
conn.bind(yamls['LDAPInfo']['BindDN'],  password) do |bound|
  bound.search(yamls['LDAPInfo']['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=*)") do |user|
  #     puts "Gecos: #{user['gecos']}"
  #     puts "UID: #{user['uid']}" 
  end
end


def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    data += line
  end
  return data
end
#print "Content-type: text/html\n\n"
template = get_file_as_string("views/manage.erb")
message = ERB.new(template, 0, "-")
header = yamls['Site'] + " user management"
title = 'LDAP Account Self Service'
attrs = yamls['UserWritableAttrs']
puts message.result(binding)


