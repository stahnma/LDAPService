#!/usr/bin/env ruby 

require 'sinatra'
require 'presentation'



get '/' do
  renderfarm
end

