
require 'erb'
require 'utils'

# Pass a header param set
def header(config, options)
  errors = options[:errors]
  template = get_file_as_string("../views/header.erb")
  message = ERB.new(template, 0, "-")                 
  output = message.result(binding)                    
  return output.to_s                                  
end                                                   

# Footer
def footer(config, options)
  template = get_file_as_string("../views/footer.erb")
  message = ERB.new(template, 0, "-")                 
  output = message.result(binding)                    
  return output                                       
end                                                   

# Content
def content(config, contentfile, options)
  template = get_file_as_string("../views/" + contentfile)
  message = ERB.new(template, 0, "-")                     
  output = message.result(binding)                        
  return output                                           
end                                                       

#renderfarm
def renderfarm(erbfile = 'login.erb', options = {})
  config = loadConfig('../configuration.yaml')     
  output = header(config, options)                 
  output += content(config, erbfile, options)      
  output += footer(config, options)                
  return output                                    
end                                                

