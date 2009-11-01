#!/usr/bin/env ruby
#
require 'webrick'
require 'webrick/https'
include WEBrick

# To get around an odd feature in SSL generatation where you 
#  will get the same serial number on a new certificate
#  I just add some random text to the end of the hostname.
value = ""; 
12.times{value << ((rand(2)==1?65:97) + rand(25)).chr}


def start_webrick(config = {})
  server = HTTPServer.new(config)
  # If you ever create any more paths, you might need to mount them here
  server.mount('/', HTTPServlet::CGIHandler, File.join(Dir.pwd, "/src/index.rb") ) 
  server.mount('/style', HTTPServlet::FileHandler, File.join(Dir.pwd, "/style") ) 

  yield server if block_given?
  ['INT', 'TERM'].each do |signal|
    trap(signal) { server.shutdown }
  end
  server.start

end

start_webrick(:DocumentRoot => File.join(Dir.pwd, "/src"),
              #:SSLEnable  => true,
              #:SSLVerifyClient  => OpenSSL::SSL::VERIFY_NONE,  
              #:SSLCertName    => [ [ "CN", WEBrick::Utils::getservername  + '.' + value] ],
              :Port => 4443 )
