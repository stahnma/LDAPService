#!/usr/bin/env ruby


require 'yaml'
require 'ldap'



def loadConfig(filename)
    if File.exists?(filename) and File.size(filename) == 0 
     raise IOError, 'Zero Byte File', caller
    end 
    begin
      config =  YAML::load(File.open(filename))
    rescue Errno::EACCES => boom
      raise Errno::EACCES, "Permission denied on #{filename}", caller
    rescue Errno::ENOENT => boom
      raise IOError, boom, caller
    rescue ArgumentError => boom
      raise ArgumentError, "Invalid YAML detected in #{filename}", caller
    end 
    return config
end

# login
# Update attrs
# reset pw
# admin reset

