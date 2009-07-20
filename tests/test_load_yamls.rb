#!/usr/bin/env ruby

require 'yaml'
require 'test/unit'
require 'utils'

class TC_yamlTest < Test::Unit::TestCase
#  def setup 
#  end
#  def teardown
#  end

  def test_file_not_found
     assert_raise( IOError ) { loadConfig('/a_randon_and_missing_file') }
  end

  def test_bogus_file
     bogus_filename="/var/tmp/rubytest123"
     assert_raise( IOError ) { 
         if File.exists?(bogus_filename)
           File.delete(bogus_filename)
         end
         File.open(bogus_filename, 'w') 
         loadConfig(bogus_filename) 
         
     }
     File.delete(bogus_filename)
  end
  
  def test_not_valid_yaml
     assert_raise( ArgumentError ) { loadConfig('/etc/hosts') }
  end
  
  def test_perms
     perm_denied='/var/tmp/rubyfail'
     assert_raise(Errno::EACCES) {
         if File.exists?(perm_denied)
           File.delete(perm_denied)
         end
         doc = "TEST: thing"
         File.open(perm_denied, 'w') {|f| f.write(doc) }
         File.chmod(0000, perm_denied)
         loadConfig(perm_denied)
     }
     File.chmod(0644, perm_denied)
     File.delete(perm_denied)
  end
  def test_all_good
     all_good='/var/tmp/rubygood'
     doc="TEST: thing"
     File.open(all_good, 'w') {|f| f.write(doc) }
     config = loadConfig(all_good)
     assert(config['TEST'] == 'thing'  ) 
  end
end
