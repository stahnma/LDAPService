#!/usr/bin/evn ruby
#
#
require 'test/unit'
require 'generate_login'
#require './../src/ldap_utils'
#require './../src/utils'    

class TC_eolTest < Test::Unit::TestCase
  def test_emailOrLogin_uid_pass
      a = emailOrLogin('stahnma')
      assert(a == 'uid')
  end

  def test_emailOrLogin_mail
      a = emailOrLogin('stahnma@')
      assert(a ==  'mail')
  end

  def test_emailOrLogin_blank
      a = emailOrLogin('')
      assert(a ==  false)
  end
end

class TC_Test < Test::Unit::TestCase
  def test_lookup_valid_email 
     a = lookup('michael.stahnke@cat.com', 'mail') 
     assert(a.downcase == 'michael.stahnke@cat.com')
  end

  def test_lookup_invalid_email
     assert_raise( LDAP::ResultError ) {
      lookup('bogus123@example.com', 'mail')
    }
  end

  def test_lookup_valid_uid
     a = lookup('stahnma', 'uid') 
     assert(a.downcase == 'michael.stahnke@cat.com')
  end
  def test_lookup_invalid_uid
     assert_raise( LDAP::ResultError ) {
      lookup('bogus12356', 'uid')
    }
  end

end
