local Base = require("http_base")
local hds = "GET /edit HTTP/1.1\r\nHost: urlimg.sinaapp.com\r\nConnection: keep-alive\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nUser-Agent: Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36\r\nAccept-Encoding: gzip, deflate, sdch\r\nAccept-Language: zh-CN,zh;q=0.8\r\nCookie: saeut=CkMPGlS8X/4mpy41Ck7qAg==\r\n"


local Client = {}

function Client.New(url)
	local clt = {}
	clt.hd = Base.Header.New()
	clt.hd["Connection"] = "Close"
	clt.hd["Pragma"] = "no-cache"
	local _,_,prot,host,path = url:find("^(https?)://([^/^\?]*)(.*)$")
	clt._prot = prot
	clt._path = path
	clt._host = host
	clt._port = 80
	clt.hd.Host = host
	return clt
end

function Client.Do(clt, method, body, callback)
	clt.hd._firstline = method.." "..clt._path.." HTTP/1.1"
	local hds = Base.Header.GetString(clt.hd)..Base.NewLine..Base.NewLine
	local trunk = hds
	Base.Socket.TCPSend(clt._host,clt._port,trunk,function(data)
		local  st1, st2 = string.find(data,Base.NewLine..Base.NewLine)
		local hds = string.sub(data,0,st1)
		local data = string.sub(data,st2+1)
		local hd = Base.Header.New(hds)
		if hd["Transfer-Encoding"] == "chunked" then
			
		end
		print(data)
		end)
end



local clt = Client.New("http://api.yeelink.net//v1.0/device/18073/sensor/31457/datapoints")
Client.Do(clt, "GET")