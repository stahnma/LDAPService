#!/usr/bin/env ruby
#
class PW

  attr_accessor :password
  def initialize(password, options = {})
    @password = password
    @minUpper = options[:min_upper] || 1
    @minLower = options[:min_lower] || 1
    @minNum   = options[:min_num] || 1
    @minSpecial  = options[:min_spec] || 1
    @minLength = options[:min_length] || 8
  end
  
  def enoughUppercase?
     return checker(Regexp.new('[A-Z]') , @minUpper)
  end

  def enoughLowercase?
     return checker(Regexp.new('[a-z]') , @minLower)
  end
  
  def enoughNumeric?
     return checker(Regexp.new('[0-9]') , @minNum)
  end
 
  def enoughSpecialChars?
     return checker(Regexp.new('\W') , @minSpecial)
  end
   
  def minLength?
     if @password.length < @minLength
        return false
     end
     return true
  end
 
  def passwordMatches?(str)
      if str == @password 
        return true
      end
      return false
  end

  def strong?
      if self.enoughUppercase? and self.enoughLowercase?  and self.enoughNumeric? and self.enoughSpecialChars? and self.minLength?
         return true
      end
      return false
  end
  
  private
  def checker(pattern, value)
    match = 0
    @password.each do |letter| 
       if letter =~ pattern
         match+=1
       end
       if match.to_i >= value.to_i
         return true
       end
       return false
     end
  end
end
