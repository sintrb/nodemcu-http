------------------------------------------------------------------------------
-- HTTP Client example
--
-- https://github.com/sintrb/nodemcu-http
-- e-mail: sintrb@gmail.com
------------------------------------------------------------------------------

Client = require("http_client")

Client.Post("http://xbase.sinaapp.com/monit/status?u=t&p=t", "this is a test~", function(clt, data)
	print(data)
	Client.Get("http://xbase.sinaapp.com/monit/status?u=t&p=t", function(clt, data)
		print(data)
	end)
end)