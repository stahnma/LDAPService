
require 'utils'
require 'ldap'
require 'pp'


class LdapConnection 
  
   def initialize(ssl = false)
     config = loadConfig('../configuration.yaml')
     @ldapconf = config['LDAPInfo']
     #TODO arbitrate SSL vs nonSSL
     begin
       if ssl 
         @conn = LDAP::SSLConn.new(@ldapconf['Host'], 636) 
       else
         @conn = LDAP::Conn.new(@ldapconf['Host']) 
       end
     rescue LDAP::ResultError
       raise LDAP::ResultError, "Error Connecting to LDAP Server", caller
     end
   end

   def add(dn, attrs)
     @bound.add(dn, attrs)
   end
  
   def login(user, pw)
     dn = getDN(user)
     if pw.nil? or pw == ''
       raise LDAP::ResultError, "Password is blank", caller
     end
     begin
       @bound = @conn.bind(dn,  pw) 
     rescue LDAP::ResultError => boom
       raise LDAP::ResultError, boom, caller
       return false
     end
     return true
   end

   def findNextUIDNumber(start_range = -1 )
     max = -1
     @bound.search(@ldapconf['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uidNumber=*)", 'uidNumber') do |uidNumber|
      uid = uidNumber['uidNumber'][0].to_i
         if uid > max
            max=uid
        end
     end
     return max+1 if max+1 > start_range.to_i
     start_range
   end

   # This seems buggy.  Like it would return one result, even though there are many
   def getUsers()
     @bound.search(@ldapconf['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=*)") do |user|
       return user
     end
   end

   def getEntryByMail(mail)
     @bound.search(@ldapconf['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(mail=#{mail})") do |user|
       return user.to_hash
     end
     raise LDAP::ResultError, "No entry with mail #{mail} found", caller
   end
  
   def getUserEntry(uid)
     @bound.search(@ldapconf['BaseDN'], LDAP::LDAP_SCOPE_SUBTREE, "(uid=#{uid})") do |user|
         return user.to_hash
     end
     raise LDAP::ResultError, "No entry with uid #{uid} found", caller
   end

   def update(user, options)
     dn =  getDN(user)
     begin 
       return @bound.modify(dn, options)
     rescue LDAP::ResultError => boom
       raise LDAP::ResultError, boom.to_s, caller 
     return false
     end
   end

   def unbind()
     return @bound.unbind
   end
   def bound?()
     return @bound.bound?
   end

   def getDN(user)
     unless user =~ /dc=/ 
     #  #TODO fix hard-coded ou=people
      dn = 'uid=' + user + ',ou=people,' + @ldapconf['BaseDN']
     else
      dn = user
     end
     return dn
   end
end

#TODO handle if password is not defined in either spot
def password_check( yamls )
  # Check to see if it's defined in an ENV var
  password = ""
  if ENV['LDAP_PASSWORD']
    password = ENV['LDAP_PASSWORD']
  else
    password = yamls['LDAPInfo']['BindPW']
  end
  return password
end
