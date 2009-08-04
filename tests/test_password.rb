#!/usr/bin/env ruby
#
#
require 'password'

p = PW.new('f$iFFFFu3e')
puts p.password
puts "Has enough Uppercase #{p.enoughUppercase?}"
puts "Has enough Lowercase #{p.enoughLowercase?}"
puts "Has enough Numeric   #{p.enoughNumeric?}"
puts "Has enough Special   #{p.enoughSpecialChars?}"
puts "Has min length   #{p.minLength?}"
puts "Validate Strength   #{p.strong?}"
puts "match test #{p.passwordMatches?('f$iFFFFu3e')}"

