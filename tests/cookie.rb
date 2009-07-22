#!/usr/bin/env ruby
#
COOKIE_NAME='LDSCookie'
require 'cgi'
require 'pp'
require 'cgi/session'
cgi = CGI.new
values = cgi.cookies[COOKIE_NAME]
#puts "Content-type: text/html\n\n"
#puts "This is values #{values}"

#pp values

if values.empty?
  msg = "New cookie time"
else
  msg = "Old cookie time<br/>"
  session_cook = values[1]
end
#cookie = CGI::Cookie.new(COOKIE_NAME, Time.now.to_s, 'values' => 'xyazdaflka' )
cookie = CGI::Cookie.new("name" => "preference name",
                                "value" => "whatever you'd like",
                                "expires" => Time.local(Time.now.year + 2,
    Time.now.mon, Time.now.day, Time.now.hour, Time.now.min, Time.now.sec) )
cookie.expires = Time.now + 30*24*3600
cgi.out("cookie" => cookie) { msg } 
puts session_cook

