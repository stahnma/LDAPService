require "cgi"
require "cgi/session"


cgi = CGI.new("html3") 
sess = CGI::Session.new(cgi, "session_key" => "rubyweb", "prefix" => "web-session.") 
cgi.out{ 
  cgi.html{
        "\nCustomer #{sess['CustID']} orders an #{sess['Part']}"
  }
}
