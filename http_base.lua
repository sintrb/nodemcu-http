
--hds = "HTTP/1.1 200 OK\r\nServer: nginx/1.4.4\r\nDate: Fri, 10 Apr 2015 03:24:45 GMT\r\nContent-Type: text/html; charset=UTF-8\r\nTransfer-Encoding: chunked\r\nConnection: keep-alive\r\nvia: yq34.pyruntime\r\nContent-Encoding: gzip\r\n";
hds = "GET /edit HTTP/1.1\r\nHost: urlimg.sinaapp.com\r\nConnection: keep-alive\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nUser-Agent: Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36\r\nAccept-Encoding: gzip, deflate, sdch\r\nAccept-Language: zh-CN,zh;q=0.8\r\nCookie: saeut=CkMPGlS8X/4mpy41Ck7qAg==\r\n"


local Utils = {}
local Header = {}
local Socket = {}
local NewLine = "\r\n"
function Utils.NextString(s, str, start)
	local ix = s:find(str, start)
	if not ix then return nil, -1 end
	return s:sub(start, ix-1), ix
end



function Header.New(hds)
	local start = 0
	local l = nil
	local hd = {}
	while true and hds do
		l,start = Utils.NextString(hds,NewLine,start)
		if not l then break end
		if not hd._firstline then
			hd._firstline = l
		else
			local _, _, k, v = l:find("^([%w-]+):%s*(.+)")
			hd[k] = v
		end
		-- print(l)
		start = start + 2
	end
	return hd
end

function Header.GetString(hd)
	local lns = {}
	if hd._firstline then
		table.insert(lns, hd._firstline)
	end
	for k,v in pairs(hd) do
		if type(v) == "string" and (string.sub(k,0,1)~='_') then
			table.insert(lns, k..":"..v)
		end
	end
	return table.concat(lns, NewLine)
end

function Socket.TCPSend(host,port,data,callback)
	local socket = require("socket")
	local sock = socket.connect(host, port)
	sock:send(data)
	local rdata = {}
	repeat
	    local chunk, status, partial = sock:receive(1024)
	    if #partial >0 then
	    	table.insert(rdata, partial)
	   else
	   		break
	   end
	until status ~= "closed"
	sock:close()
	callback(table.concat(rdata))
end

-- Socket.TCPSend("xbase.sinaapp.com",80,
-- 	"GET /monit/1425567511000 HTTP/1.1\r\nHost: xbase.sinaapp.com\r\nConnection: close\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Encoding: deflate\r\nAccept-Language: zh-CN,zh;q=0.8\r\n\r\n",
-- 	function(data)
-- 		print(data)
-- 	end
-- )

return {
	Header = Header,
	NewLine = NewLine,
	Socket = Socket
}

