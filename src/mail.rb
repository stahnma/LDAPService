#!/usr/bin/env ruby
#
require 'net/smtp'


def sendmail(from, to, subject, message, options = {}) 
  #   => from_alias (optional)
  #   =>  to_alias (optional)       
from = options[:from_alias].to_s  + "<#{from}>"
to = options[:to_alias].to_s  + "<#{to}>"
msg = <<EOF
From: #{from}
To: #{to}
Subject: #{subject}

#{message}
EOF
  

  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message( msg, from, to  ) 
  end
end


sendmail('mike@whatever.com', 'mastahnke@gmail.com', 'whatever', 'message body' , { :from_alias => 'mikealias' , :to_alias => "jojo"}  ) 
