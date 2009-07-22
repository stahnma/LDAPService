

task :default do
   sh "rsync -avx  views/style/* /srv/lds/style"
   sh "ruby generate_index.rb > /srv/lds/index.html"
   sh "ruby generate_login.rb > /srv/lds/login.html"
end

# Need to copy over apache files
