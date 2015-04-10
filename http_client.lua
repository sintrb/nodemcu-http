------------------------------------------------------------------------------
-- HTTP Client module
--
-- https://github.com/sintrb/nodemcu-http
-- e-mail: sintrb@gmail.com
------------------------------------------------------------------------------

local Base = require("http_base")

local Client = {}

function Client.New(url, header)
	local clt = {}
	clt.hd = Base.Header.New()
	clt.hd["Connection"] = "Close"
	clt.hd["Pragma"] = "no-cache"
	if header then
		for k,v in pairs(header) do
			if type(v) == "string" and (string.sub(k,0,1)~='_') then
				clt.hd[k] = v
			end
		end
	end
	local _,_,prot,host,port,path = url:find("^(https?)://([^/^\?^:]*)([:0-9]*)(.*)$")
	clt._url = url
	clt._prot = prot
	clt._path = path
	clt._host = host
	clt._port = (port and tonumber(port:sub(2),10)) or 80
	clt.hd.Host = host
	return clt
end

function Client.Do(clt, method, body, callback)
	if type(clt) == "string" then
		clt = Client.New(clt)
	end
	clt.hd._firstline = method.." "..clt._path.." HTTP/1.1"
	local chunk = nil
	if body then
		clt.hd["Content-Length"] = ""..#body
		chunk = Base.Header.GetString(clt.hd)..Base.NewLine..Base.NewLine..body..Base.NewLine
	else
		clt.hd["Content-Length"] = 0
		chunk = Base.Header.GetString(clt.hd)..Base.NewLine..Base.NewLine
	end
	Base.Socket.TCPSend(clt._host,clt._port,chunk,function(data)
		local  st1, st2 = string.find(data,Base.NewLine..Base.NewLine)
		local hds = string.sub(data,0,st1)
		local data = string.sub(data,st2+1)
		local hd = Base.Header.New(hds)
		if hd["Transfer-Encoding"] == "chunked" then
			data = Base.Utils.UnChunk(data)
		end
		if callback then
			callback(clt, data)
		end
	end)
end

function Client.Get(clt, callback)
	Client.Do(clt, "GET", nil, callback)
end

function Client.Post(clt, data, callback)
	Client.Do(clt, "POST", data, callback)
end

function Client.Put(clt, data, callback)
	Client.Do(clt, "PUT", data, callback)
end

function Client.Delete(clt, data, callback)
	Client.Do(clt, "DELETE", nil, callback)
end

return Client


