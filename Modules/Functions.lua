--FUNCTIONS.LUA--
color=discordia.Color
mutex=discordia.Mutex()
query=require("querystring")
enclib=require("encrypter")
http=require("coro-http")
json=require("json")
colors={
	red=color(255,0,0),
	green=color(0,255,0),
	blue=color(0,0,255),
	bright_blue=color(0,200,255),
	orange=color(255,160,0),
	yellow=color(255,255,0),
}
function timeStamp()
	return os.date("%I:%M:%S %p - %a, %b %d")
end
function sendLog(hook,title,description,color)
	if not hook then print"NO HOOK"return end
	local post
	if type(title)=='table'then
		title.color=color
		post={embeds={title}}
	else
		post={embeds={{title=title,description=description,color=color}}}
	end
	coroutine.wrap(function()
		mutex:lock()
		http.request("POST",hook,{{"Content-Type","application/json"}},json.encode(post))
		mutex:unlockAfter(1500)
	end)()
end
function checkArgs(types,vals)
	for i,v in pairs(types)do
		if type(v)=='table'then
			local t1=true
			if type(vals[i])~=v[1] then
				t1=false
			end
			if t1==false then
				if type(vals[i])~=v[2] then
					return false,v,i,type(vals[i])
				end
			end
		else
			if type(vals[i])~=v then
				return false,v,i,type(vals[i])
			end
		end
	end
	return true,'',#vals
end
function set(a,b,c)
	if a then
		b[c]=a
	end
end
function embed(title,desc,color,fields)
	local emb={}
	set(title,emb,'title')
	set(desc,emb,'description')
	set(color,emb,'color')
	set(fields,emb,'fields')
	return emb
end
function sendMessage(obj,con,emb)
	local doSend,orig=false,con
	if type(con)=='string'then
		if #con>1999 then
			con=con:sub(1,1982)..'- | **CONTINUED**'
			doSend=true
		end
	end
	if emb then
		con={embed=con}
	end
	if obj.reply then
		obj:reply(con)
	elseif obj.sendMessage then
		obj:sendMessage(con)
	end
	if doSend then
		sendMessage(obj,'-'..orig:sub(1983))
	end
end
function getRank(member,server)
	if member.id==client.owner.id then
		return 4
	end
	if server then
		
	end
	return 0
end
function getPermissions(member,flag)
	local roles={}
	for role in member.roles do
		table.insert(roles,role)
	end
	if channel then
		local overwrite=channel:getPermissionOverwriteFor(member)
		if getPermissions(member,'administrator')then
			return true
		end
		if overwrite.allowedPermissions:has(flag)then
			return true
		end
		for _,role in pairs(roles)do
			local roverwrite=channel:getPermissionOverwriteFor(role)
			if roverwrite.allowedPermissions:has(flag)then
				return true
			end
		end
	else
		for _,role in pairs(roles)do
			local permissions=role:getPermissions()
			if permissions:has('administrator')then
				return true
			end
			if permissions:has(flag)then
				return true
			end
		end
	end
	return false
end
function getBotMember(guild)
	return client.user:getMembership(guild)
end
function getHighestRole(member)
	local h=0
	if member.guild.owner.id==member.id then h=99999 end
	if member.id==client.owner.id then h=99999999999 end
	for role in member.roles do
		if role.position>h then
			h=role.position
		end
	end
	return h
end
function compareNumber(a,b)
	if a>b then return 1 end
	if b>a then return 2 end
	if b==a then return 3 end
end
function findMembers(guild,tofind,exacto)
	local rmembers={}
	if not guild then return{},"bad argument to #1, guild expected"end
	if not tofind then return{},"bad argument to #2, string expected"end
	if exacto==nil then exacto=true end
	for member in guild.members do
		if exacto then
			if tofind:lower()==member.name:lower()then
				table.insert(rmembers,member)
			end
		else
			if member.name:lower():sub(1,#tofind)==tofind:lower()then
				table.insert(rmembers,member)
			end
		end
	end
	return rmembers
end
function getSwitches(str)
	local r={}
	for flag,content in string.gmatch(str,'%/(%S*)%s*([^%-]*)')do
		r[flag]=content
	end
	return r
end
function convertToBool(t)
	if type(t)=='boolean'then return t end
	t=t:lower()
	if t=='yes'or t=='true'then
		return true
	end
	if t=='no'or t=='false'then
		return false
	end
end