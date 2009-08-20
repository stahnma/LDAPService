#
require 'ldap_utils'
require 'utils'
require 'generate_login'
require 'mail'

user=ENV['USER']
password=ENV['LDAP_PASSWORD']

#l = LdapConnection.new
#l.login(user, password)

#options = { 'telephoneNumber' => [" +1 309 840 1541" ] } 
#options = { 'telephoneNumber' => [" +1 555 840 1541" ] } 
#adminUpdate('stahnma', options)
#options = { 'telephoneNumber' => [ ] } 
#l.update(user, options)


# New User
#
# username
# First , Last
# email address
#
# New User in LDAP Method
# Send the confirmation Mail method
#
username='timmy'
lastname='stahnke'
firstname='michael'
email='mastahnke@gmail.com'


def addLdapUser(username, lastname, firstname, email)
  config = loadConfig('../configuration.yaml')
  # Login to LDAP
  l = LdapConnection.new
  l.login('stahnma', ENV['LDAP_PASSWORD'])
  uidNumber = l.findNextUIDNumber
  gidNumber = config['UserSetup']['DefaultGroupID'].to_i
  options = {}
  options = { 'cn' => [ lastname ] ,  
              'sn' => [ lastname ] ,  
              'mail' => [ email ] ,
              'uid' => [ username ] , 
              'uidNumber' => [ uidNumber.to_s ] ,
              'gidNumber' => [ gidNumber.to_s ] ,
              'gecos' => [ "#{firstname} #{lastname}" ] ,
              'homedirectory' => [ config['UserSetup']['HomePrefix'] + '/' + username ] , 
              'loginshell' =>  [ config['UserSetup']['LoginShell'] ] ,
              'givenName' => [ firstname ] ,
              'objectclass' =>  config['UserSetup']['ObjectClasses'] 
           }
  p options
  dn = "uid=#{username},ou=people,dc=stahnkage,dc=com"
  l.add(dn, options)
end
  




def sendNewUserLetter(username, lastname, firstname, email)
  userid=username
  options = {} 
  # Get proper information from the YAML File
  config = loadConfig('../configuration.yaml')
  sitename = config['Site']
  hostname = config['UserSetup']['ExampleHostname']
  forgot_password_link = 'blahblah'
  options[:from_alias] = 'bob'
  options[:to_alias]= firstname + ' ' + lastname
  # Fill out the ERb
  template = get_file_as_string("../views/new_user.erb")
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  # Ship it
  sendemail(config['PWReset']['FromAddress'], email, "Shiney new account from #{config['Site']}", output)
end

#sendNewUserLetter(username, lastname, firstname, email)
addLdapUser(username, lastname, firstname, email)
