

task :default do
   sh "rsync -avx  views/style/* /srv/lds/style"
   sh "ruby generate_index.rb > /srv/lds/index.html"
   sh "ruby generate_login.rb > /srv/lds/login.html"
end

task :apache do
   sh "cp -f contrib/lds-apache.conf /etc/httpd/conf.d"
   sh "/sbin/service httpd restart"
end

# Need to copy over apache files
