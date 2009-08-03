#!/usr/bin/evn ruby
#
#
require 'test/unit'
require 'generate_login'
#require './../src/ldap_utils'
#require './../src/utils'    

class TC_ldapTest < Test::Unit::TestCase
  def test_emailOrLogin_uid_pass
      a = emailOrLogin('stahnma')
      assert(a == 'uid')
  end

  def test_emailOrLogin_mail
      a = emailOrLogin('stahnma@')
      puts a 
      assert(a ==  'mail')
  end

  def test_emailOrLogin_blank
      a = emailOrLogin('')
      assert(a ==  false)
  end
     

end

