NAME='lssm'

task :default do
   sh "rsync -avx  views/style/* /srv/#{NAME}/style"
   sh "ruby generate_index.rb > /srv/#{NAME}/index.html"
   sh "ruby generate_login.rb > /srv/#{NAME}/login.html"
end

task :httpd do
   sh "cp -f contrib/#{NAME}-apache.conf /etc/httpd/conf.d"
   sh "/sbin/service httpd restart"
end

task :apache2 do
   sh "cp -f contrib/#{NAME}-apache.conf /etc/apache2/conf.d"
   sh "/etc/init.d/apache2 reload"
end

task :clean  do
  sh "rm -f *tar.gz"
end


task :tarball => :clean  do
  puts
  version=`grep ^Version contrib/*.spec | awk '{print $NF}'`.strip()
  cwd=`pwd`.strip()
  sh "mkdir -p /tmp/#{NAME}-#{version}/"
  sh "rsync -ax * /tmp/#{NAME}-#{version}/"
  sh "tar -C /tmp -p -c  -z --exclude=.project --exclude=.git --exclude=.gitignore -f  /tmp/#{NAME}-#{version}.tar.gz #{NAME}-#{version}"
  sh "mv /tmp/#{NAME}-#{version}.tar.gz . "
  puts "Tarball is #{NAME}-#{version}.tar.gz"
end

task :rpm do
end
