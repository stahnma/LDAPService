#!/usr/bin/ruby

require 'erb'
require 'utils'


def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    data += line
  end
  return data
end

#TODO Break out display into a seperate method 
#  that include the header/footer automatically
#
def renderLogin(options = {})
  puts "Content-type: text/html\n\n" 
  config = loadConfig('../config2.yaml')
  template = get_file_as_string("views/header.erb")
  message = ERB.new(template, 0, "-")
  #puts options[:errors] if not options[:errors].nil?
     errors = options[:errors]
  #end 
  header = config['Site'] + " user management"
  title = 'LDAP Account Self Service'
  if defined? config['AltLogo'] 
    alt_logo = config['AltLogo']
  else
    alt_logo = ""
  end
  logo = config['Style'].to_s + '/' + config['Logo'].to_s
  style = config['Style']
  attrs = config['UserWritableAttrs']
  site = config['Site']
  output =  message.result(binding)
  template = get_file_as_string("views/login.erb")
  message = ERB.new(template, 0, "-")
  output += message.result(binding)
  template = get_file_as_string("views/footer.erb")
  message = ERB.new(template, 0, "-")
  output += message.result(binding)
  puts output
  
  
end

def fillPost()
  post = {}
  STDIN.read.split('&').each do | line| 
     key, val = line.split('=')
     post[key] = val
  end
  return post
end

def login(username, password)
  l  = LdapConnection.new()
  # Handle case where password is null
  begin 
    l.login(username, password)
  rescue LDAP::ResultError => boom
    #raise LDAP::ResultError, "Invalid User/Password combination", caller
    #puts "Send back to #{ENV['HTTP_REFERER']} with an error message in the message box"
    renderLogin( { :errors => "Invalid Login/Password Combination" } )
    exit 1
  end
  return l
end

def renderGood(l)
  puts "Content-type: text/html\n\n" 
  puts "Edit information please."
  # Ideally you read some of this stuff from a cookie
  a = l.getUserEntry('stahnjd')
  a.each do | key, value|
     puts "#{key}: #{value} <br />\n"
  end
end

# Login should really be only a router to the next step
# Index should only call login, if a login isn't already found

#l  = LdapConnection.new()
#pp l.login(post['login'], post['password'])
#a = l.getUserEntry(post['login'])
#a.each do | key, value|
#   puts "#{key}: #{value} <br />\n"
#end 
