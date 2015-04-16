------------------------------------------------------------------------------
-- HTTP Base module
--
-- https://github.com/sintrb/nodemcu-http
-- e-mail: sintrb@gmail.com
------------------------------------------------------------------------------

local Utils = {}
local Header = {}
local Socket = {}
local NewLine = "\n"

function Utils.NextString(s, str, start)
	local ix = s:find(str, start)
	if not ix then return nil, -1 end
	return s:sub(start, ix-1), ix
end

function Utils.UnChunk(s)
	local start = 0
	local l = nil
	local buf = {}
	while true and s do
		l,start = Utils.NextString(s,NewLine,start)
		if start<0 then
			break
		end
		if l then
			start = start + #NewLine
			local tl = tonumber(l,16)
			if tl and tl>0 then
				local dat = s:sub(start, start+tl-1)
				start = start + tl
				table.insert(buf, dat)
			end
		end
	end
	return table.concat(buf)
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
			if k then
				hd[k] = v
			end
		end
		-- print(l)
		start = start + #NewLine
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
	-- print("send:",data)
	if net then
		-- on nodemcu
		local sck=net.createConnection(net.TCP, false) 
		sck:on("connection", function(conn)
			conn:send(data)
		end)
		sck:on("receive", function(conn, data)
			callback(data)
		end)
		sck:connect(port,host)
		return sck
	else
		-- on pc
		local socket = require("socket")
		local sock = socket.connect(host, port)
		sock:send(data)
		local buf = {}
		repeat
		    local chunk, status, partial = sock:receive(1024)
		    if #partial >0 then
		    	table.insert(buf, partial)
		   else
		   		break
		   end
		until status ~= "closed"
		sock:close()
		local rd = table.concat(buf)
		callback(rd)
		return sock
	end
end

function Socket.TCPListen(host, port, recvcallback)
	if net then
		-- on nodemcu
		local srv=net.createServer(net.TCP)
		local serv = {}
		serv["running"] = true
		serv["server"] = srv
		srv:listen(port,function(conn) 
			conn:on("receive",function(conn,data) 
				recvcallback(serv, conn, data)
				if not serv["running"] then
					srv:close()
				end
			end)
		end)
		return srv
	else
		-- on pc
		local socket = require("socket")
		local server = assert(socket.bind(host, port))
		local serv = {}
		serv["running"] = true
		serv["server"] = server
		-- on pc, it is die loop....
		while serv["running"] do
			local clt = assert(server:accept())
			while true do
				local data, status = clt:receive()
				if status=="closed" then
					recvcallback(serv, clt, nil)
					break
				else
					recvcallback(serv, clt, data)
				end
			end
		end
		return serv
	end
end

return {
	Header = Header,
	NewLine = NewLine,
	Socket = Socket,
	Utils = Utils
}
