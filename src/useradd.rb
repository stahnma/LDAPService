#
require 'ldap_utils'
require 'utils'
require 'generate_login'
require 'mail'

user=ENV['USER']
password=ENV['LDAP_PASSWORD']

# prompt or CLI for this crap
username='timmy4'
lastname='stahnke'
firstname='michael'
email='mastahnke@yahoo.com'

# Ensure current user can login to LDAP
config = loadConfig('../configuration.yaml')

# Do some type of configuration file validation


def addLdapUser(username, lastname, firstname, email)
  config = loadConfig('../configuration.yaml')
  l = LdapConnection.new
  l.login('stahnma', ENV['LDAP_PASSWORD'])
  uidNumber = l.findNextUIDNumber.to_s
  gidNumber = config['UserSetup']['DefaultGroupID'].to_s
  options = { 'cn' => [ lastname ] ,  
              'sn' => [ lastname ] ,  
              'mail' => [ email ] ,
              'uid' => [ username ] , 
              'uidNumber' => [ uidNumber ] ,
              'gidNumber' => [ gidNumber ] ,
              'gecos' => [ "#{firstname} #{lastname}" ] ,
              'homedirectory' => [ config['UserSetup']['HomePrefix'] + '/' + username ] , 
              'loginshell' =>  [ config['UserSetup']['LoginShell'] ] ,
              'givenName' => [ firstname ] ,
              'objectclass' =>  config['UserSetup']['ObjectClasses'] 
           }
  dn = "uid=#{username},#{config['UserSetup']['AccountOU']},#{config['LDAPInfo']['BaseDN']}"
  l.add(dn, options)
  sendNewUserLetter(username, lastname, firstname, email)
end



def sendNewUserLetter(username, lastname, firstname, email)
  userid=username
  config = loadConfig('../configuration.yaml')
  sitename = config['Site']
  hostname = config['UserSetup']['ExampleHostname']
  forgot_password_link = 'blahblah'
  template = get_file_as_string("../views/new_user.erb")
  message = ERB.new(template, 0, "-")
  sendemail(config['PWReset']['FromAddress'], email, "Shiney new account from #{config['Site']}", message.result(binding))
end

addLdapUser(username, lastname, firstname, email)
#sendNewUserLetter(username, lastname, firstname, email)
