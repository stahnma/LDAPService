NAME='lssm'
PWD=`pwd`.strip!
SPEC_FILE="contrib/#{NAME}.spec"

RPM_DEFINES = " --define \"_specdir #{PWD}/SPECS\" --define \"_rpmdir #{PWD}/RPMS\" --define \"_sourcedir #{PWD}/SOURCES\" --define \" _srcrpmdir #{PWD}/SRPMS\" --define \"_builddir #{PWD}/BUILD\""
CHROOT="lssm"

task :default => :tarball  do 
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
  sh "rm -rf BUILD SOURCES SPECS SRPMS RPMS *.rpm *.tar.gz #{CHROOT} *.tgz *.deb"
end

task :rpmcheck_fedora do
  sh " [ -f /usr/bin/rpmbuild ] "
end

task :rpmcheck_el do
  sh " [ -f /usr/bin/rpmbuild-md5 ] "
end

task :dirs do
  dirs = [ 'BUILD', 'SPECS', 'SOURCES', 'RPMS', 'SRPMS' ] 
  dirs.each do |d|
    FileUtils.mkdir_p "#{PWD}//#{d}"
  end
  sh "mv *.tar.gz SOURCES"
  sh "cp  contrib/#{NAME}.spec SPECS"
end

"Create a tarball of source in local directory"
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

"Create a SRPM. (using md5 hash, not the new SHA1)"
task :srpm => [ :rpmcheck_el , :tarball , :dirs ] do
  sh "rpmbuild-md5   #{RPM_DEFINES}  -bs #{SPEC_FILE}"
  sh "mv -f SRPMS/* ."
  sh "rm -rf BUILD SRPMS RPMS SPECS SOURCES"
end


"Create a binary RPM. (using md5 hash, not the new SHA1)"
task :rpm => [ :rpmcheck_el , :tarball , :dirs ] do
  sh "rpmbuild-md5   #{RPM_DEFINES}  -bb #{SPEC_FILE}"
  sh "mv -f RPMS/noarch/* ."
  sh "rm -rf BUILD SRPMS RPMS SPECS SOURCES"
end

"Create a CHROOTed install primarily used for Debain package builds."
task :tgz do
  sh "mkdir -p #{CHROOT}/srv/lssm/{src,style,views}"
  sh "cp -pr src/* #{CHROOT}/srv/lssm/src"
  sh "cp -pr views/* #{CHROOT}/srv/lssm/views"
  sh "cp -pr style/* #{CHROOT}/srv/lssm/style"
  sh "mkdir -p #{CHROOT}/etc/lssm"
  sh "cp -pr configuration.yaml #{CHROOT}/etc/lssm"
  sh "pushd #{CHROOT}/srv/lssm; ln -s ../../etc/lssm/configuration.yaml  .; popd"
  sh "mkdir -p #{CHROOT}/etc/apache2/conf.d/"
  sh "cp -pr contrib/lssm-apache.conf  #{CHROOT}/etc/apache2/conf.d/"
  sh "mkdir -p #{CHROOT}/usr/share/doc/lssm"
  sh "cp -pr README TODO AUTHORS Rakefile #{CHROOT}/usr/share/doc/lssm"
  sh "cp -pr contrib #{CHROOT}/usr/share/doc/lssm"
  sh "cp -pr tests #{CHROOT}/usr/share/doc/lssm"
end

"Create a deb package"
task :deb => [ :tgz ] do
  sh "mkdir -p #{CHROOT}/DEBIAN"
  sh "cp -pr contrib/deb/control #{CHROOT}/DEBIAN"
  sh "dpkg --build #{CHROOT}"
end

"Startup a webrick instance on port 4443 for development work"
task :dev do
  sh "helpers/server.rb"
end
