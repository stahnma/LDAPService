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
     checker(/[A-Z]/ , @minUpper)
  end

  def enoughLowercase?
     checker(/[a-z]/ , @minLower)
  end
  
  def enoughNumeric?
     checker(/[0-9]/ , @minNum)
  end
 
  def enoughSpecialChars?
     checker(/\W/ , @minSpecial)
  end
   
  def minLength?
     @password.length >= @minLength
  end
 
  def passwordMatches?(str)
      str == @password 
  end

  def strong?
      self.enoughUppercase? and self.enoughLowercase?  and self.enoughNumeric? and self.enoughSpecialChars? and self.minLength?
  end
  
  private
  def checker(pattern, value)
    match = 0
    @password.each do |letter| 
       if letter =~ pattern
         match+=1
       end
    end
    match.to_i >= value.to_i
  end
end
