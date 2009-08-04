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
 
  def ==(str)
      @password == str
  end

  def empty?
     @password.empty?
  end

  def strong?
      enoughUppercase? and enoughLowercase? and enoughNumeric? and enoughSpecialChars? and minLength?
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
