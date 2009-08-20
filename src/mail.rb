
require 'net/smtp'
require 'erb'
require 'utils'
require 'presentation'

def sendemail(from, to, subject, message, options = {}) 
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

def resetMail(to, options = {} )
  #  Get from , from_alias, from YAML
  config = loadConfig('../configuration.yaml')
  options[:from] =  config['PWReset']['FromAddress']
  options[:from_alias] = config['PWReset']['FromAlias']
  options[:site] = config['Site']
  options[:time] = config['PWReset']['Timeout']
  options[:subject] = "Password Reset Request from '#{options[:site]}.'"
  options[:to] = to
  options[:message] = content(config, 'password_reset_mail.erb', options)
  sendemail(options[:from], options[:to],  options[:subject], options[:message], options)
end
