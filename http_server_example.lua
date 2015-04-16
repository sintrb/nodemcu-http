------------------------------------------------------------------------------
-- HTTP Server example
--
-- https://github.com/sintrb/nodemcu-http
-- e-mail: sintrb@gmail.com
------------------------------------------------------------------------------

Server = require("http_server")


local serv = Server.New('0.0.0.0', 9999)
Server.On(serv, "^/$", function(cxt)
	return '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Hello World</title></head><body>this is a demo.</body></html>'
end)
Server.On(serv, "^/hi$", function(cxt)
	return "say hi"
end)

Server.Listen(serv)