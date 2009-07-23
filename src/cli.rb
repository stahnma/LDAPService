#/usr/bin/env ruby
#
#
require 'ldap_utils'
require 'utils'
require 'generate_login'

user=ENV['USER']
password=ENV['LDAP_PASSWORD']

l = LdapConnection.new
l.login(user, password)
#options = { 'telephoneNumber' => [" +1 309 840 1541" ] } 
options = { 'telephoneNumber' => [ ] } 
l.update(user, options)
