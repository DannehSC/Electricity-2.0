local Handler=require('./Handler')
local Emitter=require('../utils/Emitter')
local Http=require('../utils/dhttp')
local JSON=require('json')
local Timer=require('timer')
local Websocket=require('coro-websocket')
local FS=require('coro-fs')
local Socket={}
local function rtprint(tab)
	local op='<OUTPUT BEGIN>\n'
	for i,v in pairs(tab)do
		if type(v)=='table'then
			for ii,vv in pairs(v)do
				op=op..'\t'.."Table ["..i..']\t\t'..tostring(ii)..' | '..tostring(vv)..' | '..tostring(type(vv))..'\n'
			end
		else
			op=op..'\t'..tostring(i)..' | '..tostring(v)..' | '..tostring(type(v))..'\n'
		end
	end
	op=op..'<OUTPUT END>'
	print(op)
end
function Socket:GetGateway()
	coroutine.wrap(function()
		local file=io.open('gate.json','w')
		--local file=FS.read('./gate.json',1024*48)
		local function doReq()
			local req,data=Http.request('GET','https://discordapp.com/api/gateway')
			if req.code==400 then return print'[Socket Error] Bad request'end
			if not req then
				print'[Socket Error] Bad gateway.'
			else
				local jdata=JSON.decode(data)
				if jdata then
					Socket.Gateway=jdata.url
					local file=io.open('gate.json','w')
					--local file=FS.write('./gate.json',data)
					if file then
						file:write(data)
					end
				end
			end
		end
		if file then
			local data=file:read()
			--local data=file
			if pcall(JSON.decode,data)then
				Socket.Gateway=JSON.decode(data)
			else
				doReq()
			end
		else
			doReq()
		end
	end)()
end
function Socket:ConnectToGateway()
	if not Socket.Gateway then
		Socket:GetGateway()
	end
	local Connection,Read,Write=Websocket.connect(Websocket.parseUrl(Socket.Gateway..'/'))
	print(Connection,Read,Write)
	return Connection,Read,Write
end
function Socket:Handle(...)
	local deta={...}
	print(deta[1])
	if not Socket.Read then return print"[Socket Error] No Socket.Read"end
	for jdata in Socket.Read do
		print(data)
		local data=JSON.decode(jdata)
		rtprint(data)
	end
end
function Socket:Start()
	coroutine.wrap(function()
		Socket:GetGateway()
		repeat Timer.sleep(500)until Socket.Gateway
		local Connection,Read,Write=Socket:ConnectToGateway()
		if Connection then
			Socket.Connection=Connection
			Socket.Read=Read
			Socket.Write=Write
			--rtprint(Connection)
			local a,b=pcall(function()
				coroutine.wrap(function()
					Socket:Handle('a')
					while Timer.sleep(5000)do
						Socket:Handle('a')
					end
				end)()
			end)
			print(a,b)
			Emitter:Fire('Gateway_Connected',Socket.Connection,Socket.Read,Socket.Write)
			print"[Socket] Gateway_Connected"
			Socket.Write({'a','b','c'})
		else
			print"[Socket Error] Gateway failed to connect. Retrying."
			Socket:Start()
		end
	end)()
end
return Socket