#!/usr/bin/evn ruby
#
#
require 'test/unit'
require './../src/ldap_utils'
require './../src/utils'    

USERNAME='stahnma'

class TC_ldapTest < Test::Unit::TestCase
  def setup                            
    @config = loadConfig('../configuration.yaml')
    
  end                                  
#  #  def teardown                         
#  #  end   
  def testLogin_badPW()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login(USERNAME, 'nah')
    }
  end

  def testLogin_goodPW()
    l = LdapConnection.new()
    l.login(USERNAME, ENV['LDAP_PASSWORD'])
  end

  def testLogin_nilPW()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login(USERNAME, nil)
    }
  end

  def testLogin_blank()
    l = LdapConnection.new()
    assert_raise( LDAP::ResultError ) {
      l.login(USERNAME, '')
    }
  end
  
  # kind of dumb test right now
  def testUpdate()
    l = LdapConnection.new()
    l.login(USERNAME, ENV['LDAP_PASSWORD'])
    options = {}
    options['telephonenumber'] = ['+1 555 555 5555']
    l.update('uid='+USERNAME+',ou=people,'+@config['LDAPInfo']['BaseDN'], options)
  end
end
