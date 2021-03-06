#
require 'ldap_utils'
require 'utils'
require 'generate_login'
require 'mail'
require 'getoptlong'

def usage
  puts "#{$0} --userid <username> --email <email@example.com> --firstname <your> --lastname <mom>"
  puts "[ --ldapuser <#{ENV['USER']}> | --ldappassword $LDAP_PASSWORD ] [ --delete userid ] "
  exit 1
end

def addLdapUser(username, lastname, firstname, email, ldapuser, ldappassword)
  config = loadConfig('../configuration.yaml')
  l = LdapConnection.new
  l.login(ldapuser, ldappassword)
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
  begin
    l.add(dn, options)
  # This might be rescuing other types of errors than simply duplicates, but I haven't been able to create any yet
  rescue LDAP::ResultError
    puts "Userid '#{username}' already found in LDAP."
    exit 2
  end
end

def delete_account(username, ldapuser, ldappassword)
  config = loadConfig('../configuration.yaml')
  l = LdapConnection.new
  l.login(ldapuser, ldappassword)
  l.delete(username)
end

def sendNewUserLetter(username, lastname, firstname, email)
  userid=username
  config = loadConfig('../configuration.yaml')
  sitename = config['Site']
  hostname = config['UserSetup']['ExampleHostname']
  forgot_password_link = config['UserSetup']['ResetURI']
  altsitenames = config['UserSetup']['AltSiteNames']
  template = get_file_as_string("../views/new_user.erb")
  message = ERB.new(template, 0, "-")
  sendemail(config['PWReset']['FromAddress'], email, "Shiney new account from #{config['Site']}", message.result(binding))
end

def process_options
  account = {}
  opts = GetoptLong.new( [ '--help', '-h', GetoptLong::NO_ARGUMENT ] ,
    [ '--userid', '-u', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--email', '-e', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--firstname', '-f', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--lastname', '-l', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--ldapuser', '-L', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--ldappassword', '-P', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--delete', '-d', GetoptLong::OPTIONAL_ARGUMENT ]
  )
  begin
  opts.each do | opt, arg|
    case opt
      when '--help'
        usage
        exit 1
      when '--userid'
        account[:userid] = arg.to_s
      when '--email'
        account[:email] = arg.to_s
      when '--firstname'
        account[:firstname] = arg.to_s.capitalize
      when '--lastname'
        account[:lastname]  = arg.to_s.capitalize
      when '--ldapuser'
        account[:ldapuser] = arg.to_s
      when '--ldappassword'
        account[:ldappassword] = arg.to_s
      when '--delete'
        account[:userid] = arg.to_s
        account[:action] = 'delete'
      end
  end
  rescue GetoptLong::InvalidOption 
      puts "Invalid command line option provided.\n\n"
      usage
      exit 1
  end

  account[:ldapuser] = ENV['USER'] unless account[:ldapuser]
  account[:ldappassword] = ENV['LDAP_PASSWORD'] unless account[:ldappassword]

  unless ( (account[:userid] and account[:email] and account[:lastname] and account[:firstname]) or (account[:action] == "delete") )
    usage
    exit 1
  end

  unless account[:ldappassword]
    puts "Please set $LDAP_PASSWORD environment variable."
    exit 1
  end

  if account[:action] == 'delete' 
     if delete_account(account[:userid], account[:ldapuser], account[:ldappassword])
       exit 0
     else
       puts "Unable to remove account."
       exit 2
     end
  end
  return account
end


config = loadConfig('../configuration.yaml')
account = process_options()
if (addLdapUser(account[:userid], account[:lastname], account[:firstname], account[:email], account[:ldapuser], account[:ldappassword]) ) 
  sendNewUserLetter(account[:userid], account[:lastname], account[:firstname], account[:email])
end
