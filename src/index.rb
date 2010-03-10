#!/usr/bin/env ruby 

require 'sinatra'
require 'presentation'


enable :sessions

get '/' do 
  # show the default login screen
  renderfarm
end

get '/account/:name' do
  "Hello #{params[:name]}!"
end

get '/account/:name/password/forgot' do
  "Hello #{params[:name]} did you forget your pw?"
end

post  '/login' do 
  session['login']  = params[:login]
  session['password'] = params[:password]
  "Hello #{session.inspect}"
end

get '/logout' do
  session['login'] = nil
  session['password'] = nil
  
  #unset(session['pass'])
end
