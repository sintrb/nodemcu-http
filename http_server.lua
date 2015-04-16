------------------------------------------------------------------------------
-- HTTP Server module
--
-- https://github.com/sintrb/nodemcu-http
-- e-mail: sintrb@gmail.com
------------------------------------------------------------------------------

local Base = require("http_base")

local Server = {}

function Server.New(host, port, header)
	local serv = {}
	serv.hd = Base.Header.New()
	serv.hd["Server"] = "NodeMCU"
	serv.hd["Connection"] = "close"
	if header then
		for k,v in pairs(header) do
			if type(v) == "string" and (string.sub(k,0,1)~='_') then
				serv.hd[k] = v
			end
		end
	end
	serv._host = host
	serv._port = port or 80
	serv._handlers = {}
	serv._debug = true
	return serv
end

function Server.On(serv, path, callback)
	serv._handlers[path] = callback
end

function Server.Find(serv, path)
	local h = nil
	for k,v in pairs(serv._handlers) do
		if path:find(k) then
			h = v
		end
	end
	return h
end

function Server.Listen(serv)
	local buf = ""
	local hd = nil
	Base.Socket.TCPListen('0.0.0.0',9999,function(sserv,clt,data)
		if data~=nil then
			buf = buf .. data .. Base.NewLine
			if hd==nil then
				local ix = buf:find(Base.NewLine..Base.NewLine)
				if ix then
					hd = Base.Header.New(buf)
					local _,_,method,path,prot = hd._firstline:find("^(.+) (.+) (.*)$")
					hd._method = method
					hd._path = path
					hd._prot = prot
					buf = ""
				end
			end
			if hd and (not hd["Content-Length"] or #buf>=tonumber(hd["Content-Length"])) then
				local rhd = Base.Header.New()
				for k,v in pairs(serv.hd) do
					if type(v) == "string" and (string.sub(k,0,1)~='_') then
						rhd[k] = v
					end
				end
				rhd._code = 200
				rhd._status = "OK"
				rhd["Content-Type"] = "text/html"
				local cxt = {
					req = {
						hd = hd,
						body = buf
					},
					res = {
						clt = clt,
						hd = rhd
					}
				}
				local h = Server.Find(serv, hd._path)
				if h then
					local r = h(cxt)
					if r then cxt.res.body = r end
				else
					rhd._code = 404
					rhd._status = "Not Found"
					cxt.res.body = "<html><body><center><h2>404 Not Found</h2></center></body></html>"
				end
				if cxt.res.body then rhd["Content-Length"] = ""..#cxt.res.body end
				local firstline = cxt.req.hd._prot .." ".. cxt.res.hd._code .." ".. cxt.res.hd._status
				rhd._firstline = firstline
				clt:send(Base.Header.GetString(rhd))
				clt:send(Base.NewLine)
				clt:send(Base.NewLine)
				if cxt.res.body then clt:send(cxt.res.body) end

				clt:close()
				buf = ""
				hd = nil
				if serv._debug then
					print(cxt.req.hd._method.." "..cxt.req.hd._path.." "..cxt.res.hd._code.." "..cxt.res.hd._status)
				end
			end
		else
			buf = ""
		end
	end)
end


return Server
