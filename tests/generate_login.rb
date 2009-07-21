#!/usr/bin/ruby

require 'erb'
require 'utils'
require 'cgi'
require 'cgi/session'


def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    data += line
  end
  return data
end

# Pass a header param set
def header(config, options)
  errors = options[:errors]
  template = get_file_as_string("views/header.erb")
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  return output
end

# Footer
def footer(config, options)
  template = get_file_as_string("views/footer.erb")
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  return output
end

# Content
def content(config, contentfile, options)
  template = get_file_as_string("views/" + contentfile)
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  return output
end

#renderfarm
def renderfarm(erbfile = 'login.erb', options = {})
  config = loadConfig('../config2.yaml')
  output = header(config, options)
  output += content(config, erbfile, options)
  output += footer(config, options)
  puts "Content-type: text/html\n\n" 
  puts output
end

def login(username, password)
  l  = LdapConnection.new()
  # Handle case where password is null
  begin 
    l.login(username, password)
  rescue LDAP::ResultError => boom
    #raise LDAP::ResultError, "Invalid User/Password combination", caller
    #puts "Send back to #{ENV['HTTP_REFERER']} with an error message in the message box"
   # puts "Content-type: text/html\n\n"
   # puts "Fail whale"
   renderfarm( 'login.erb' , { :errors => "Invalid Login/Password Combination" } )
    exit 1
  end
  return l
end

def renderGood(session)
  l = session['ldap']
  puts "Content-type: text/html\n\n" 
  puts "Edit information please."
  puts "This is session "
  
  puts "<br/>"
   puts session.inspect
  puts "<br/>"
  puts session.session_id
  
  
  puts "<br/>"
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
