#!/usr/bin/ruby

require 'erb'
require 'ldap_utils'
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
  template = get_file_as_string("../views/header.erb")
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  return output.to_s
end

# Footer
def footer(config, options)
  template = get_file_as_string("../views/footer.erb")
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  return output
end

# Content
def content(config, contentfile, options)
  template = get_file_as_string("../views/" + contentfile)
  message = ERB.new(template, 0, "-")
  output = message.result(binding)
  return output
end

#renderfarm
def renderfarm(erbfile = 'login.erb', options = {})
  config = loadConfig('../configuration.yaml')
  output = header(config, options)
  output += content(config, erbfile, options)
  output += footer(config, options)
  #puts "Content-type: text/html\n\n" 
  return output
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
   raise LDAP::ResultError, "Invalid User/Password combination", caller

   #return renderfarm( 'login.erb' , { :errors => "Invalid Login/Password Combination" } )
  end
  return l
end

def findFields(session)
   config = session['config']
#   puts "This is config <br/>"
   options = {}
   options['fields'] = {}
   config['UserWritableAttrs'].each do |k, v|
     options['fields'][k] = v 
     #puts "Key => #{k} : Value => #{v} <br/>"
   end
 #  puts options.inspect()
   options['entry'] = retrInfo(session, options['fields'])
   
   #puts "Content-type: text/html\n\n" 
   #pp session
   return renderfarm('manage.erb', options)
end 

#TODO make sure they are actuall authenticated
def updateLdap(session, options = {} ) 
   config = session['config']
  # puts "Content-type: text/html\n\n" 
  # puts "This is options "
  # pp options
  # puts "<br /><br />"
  # puts "Session :" 
  # pp session
  # puts config['LDAPInfo']['BaseDN']
#   dn = 'uid='+ session['login']+'ou=people,'+config['BaseDN']
   #session['ldap'].modify(dn, options)
end




def retrInfo(session, fields)
   # Get LDAP information
  #puts "Content-type: text/html\n\n" 
  entry = session['ldap'].getUserEntry(session['login'])
  data = {}
  #puts entry.inspect
  #fields.each do | k, v| 
  #  puts "Need value for #{v}<br/>"
  #  puts entry[v] 
  #end
  return entry
end

def renderGood(session)
  l = session['ldap']
  a = l.getUserEntry('stahnjd')
  findFields(session)
end
