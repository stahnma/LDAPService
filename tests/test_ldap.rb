#!/usr/bin/evn ruby
#
#
require 'ldap_utils'
require 'test/unit'
require 'utils'    

class TC_ldapTest < Test::Unit::TestCase
  def setup                            
    @config = loadConfig('../config2.yaml')
  end                                  
#  #  def teardown                         
#  #  end   
  def testLogin_badPW()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login('uid=stahnma,ou=people,'+ @config['LDAPInfo']['BaseDN'], 'nah')
    }
  end

  def testLogin_goodPW()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login('uid=stahnma,ou=people,'+ @config['LDAPInfo']['BaseDN'], ENV['LDAP_PASSWORD'])
    }
  end

  def testLogin_nilPW()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login('uid=stahnma,ou=people,'+ @config['LDAPInfo']['BaseDN'], nil)
    }
  end

  def testLogin_blank()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login('uid=stahnma,ou=people,'+ @config['LDAPInfo']['BaseDN'], '')
    }
  end
end
