#!/usr/bin/env ruby

require 'erb'
require 'controller'

yamls = loadConfig('../configuration.yaml')

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


