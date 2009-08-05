

task :default do
   sh "rsync -avx  views/style/* /srv/lds/style"
   sh "ruby generate_index.rb > /srv/lds/index.html"
   sh "ruby generate_login.rb > /srv/lds/login.html"
end

task :httpd do
   sh "cp -f contrib/lds-apache.conf /etc/httpd/conf.d"
   sh "/sbin/service httpd restart"
end

task :apache2 do
   sh "cp -f contrib/lds-apache.conf /etc/apache2/conf.d"
   sh "/etc/init.d/apache2 reload"
end

