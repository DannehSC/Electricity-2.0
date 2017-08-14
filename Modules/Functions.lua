--FUNCTIONS.LUA--
operatingsystem=require('ffi').os
color=discordia.Color
mutex=discordia.Mutex()
query=require("querystring")
enclib=require("encrypter")
http=require("coro-http")
timer=require("timer")
json=require("json")
uv=require("uv")
colors={
	red=color(255,0,0).value,
	green=color(0,255,0).value,
	blue=color(0,0,255).value,
	bright_blue=color(0,200,255).value,
	orange=color(255,160,0).value,
	yellow=color(255,255,0).value,
}
function __genOrderedIndex( t )
	local orderedIndex = {}
	for key in pairs(t) do
		table.insert( orderedIndex, key )
	end
	table.sort( orderedIndex )
	return orderedIndex
end
function orderedNext(t, state)
	local key = nil
	if state == nil then
		t.__orderedIndex = __genOrderedIndex( t )
		key = t.__orderedIndex[1]
	else
		for i = 1,table.getn(t.__orderedIndex) do
			if t.__orderedIndex[i] == state then
				key = t.__orderedIndex[i+1]
			end
		end
	end
	if key then
		return key, t[key]
	end
	t.__orderedIndex = nil
	return
end
function orderedPairs(t)
	return orderedNext, t, nil
end
--for key,val in orderedPairs(tab)do
--	print(key.." : "..tostring(val))
--end
function sorter(a, b)
    local t1, t2 = type(a), type(b)
    if t1 == 'string' and t2 == 'string' then
        local n1 = tonumber(a)
        if n1 then
            local n2 = tonumber(b)
            if n2 then
                return n1 < n2
            end
        end
        return a:lower() < b:lower()
    elseif t1 == 'number' and t2 == 'number' then
        return a < b
    else
        local m1 = getmetatable(a)
        if m1 and m1.__lt then
            local m2 = getmetatable(b)
            if m2 and m2.__lt then
                return a < b
            end
        end
        return tostring(a) < tostring(b)
    end
end
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
	local rank=0
	if server then
		local settings=(Database.Type=='rethinkdb'and Database:Get(member.guild).Settings or Database:Get('Settings',member.guild))
		for i,v in pairs(settings.mod_roles)do
			if member.guild:getRole(v)then
				if member:getRole(v)then
					rank=1
				end
			end
		end
		for i,v in pairs(settings.admin_roles)do
			if member.guild:getRole(v)then
				if member:getRole(v)then
					rank=2
				end
			end
		end
		for i,v in pairs(settings.co_owner_roles)do
			if member.guild:getRole(v)then
				if member:getRole(v)then
					rank=3
				end
			end
		end
		if member.id==member.guild.owner.id then
			rank=3
		end
	end
	if member.id==client.user.id then
		rank=3
	end
	if member.id==client.owner.id then
		rank=4
	end
	return rank
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
    local t={}
	for caught in str:gmatch("/ ?%S*[^/]*")do
		t[caught:sub(2,(caught:find("%s")or 0)-1)]=caught:sub((caught:sub(2):find("%s[^ ]")or -3)+2)
	end
	return t
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
function filter(message)
	local content=message.content
	local settings=(Database.Type=='rethinkdb'and Database:Get(message).Settings or Database:Get('Settings',message))
	if getRank(message.member)>1 then return end
	if settings.anti_link then
		if content:find('discord.gg/')or content:find('discordapp.com/oauth2/authorize?client_id=')or client:find('discordapp.com/api/oauth2/authorize?client_id=')then
			return true,"Invite link."
		end
	end
	for i,v in pairs(settings.banned_phrases)do
		if content:lower():find(v:lower())then
			return true,"Banned phrase."
		end
	end
end
function getIdFromString(str)
	local fs=str:find('<')
	local fe=str:find('>')
	if not fs or not fe then return end
	return str:sub(fs+2,fe-1)
end
function mute(member,channel)
	local overwrite=channel:getPermissionOverwriteFor(member)
	overwrite:denyPermissions('sendMessages')
end
function unmute(member,channel)
	local overwrite=channel:getPermissionOverwriteFor(member)
	overwrite:clearPermissions('sendMessages')
end
function voiceKick(member)
	local guild,voice=member.guild,member.voiceChannel
	if voice then
		local newchan=guild:createVoiceChannel("goodbyegetkicked")
		member:setVoiceChannel(newchan)
		repeat timer.sleep(10)until member.voiceChannel~=nil and member.voiceChannel.id==newchan.id
		newchan:delete()
		return"Member kicked from voice."
	else
		return"No voice channel to kick them from!"
	end
end
function commandDocsDump()
	local r0t,r1t,r2t,r3t,r4t='# Rank 0 (User)\n\n','# Rank 1 (Moderator)\n\n','# Rank 2 (Administrator)\n\n','# Rank 3 (Server Owner)\n\n','# Rank 4 (Bot Creator)\n\n'
	local r0,r1,r2,r3,r4={},{},{},{},{}
	local function makeDoc(commandTable)
		local text='### %s\nDescription: %s\n\nCommands: %s\n\nRank: %s\n\nSwitches: %s\n\nServer only: %s\n'
		local sep=(commandTable.Description:find('|')or #commandTable.Description+1)
		local desc,switches=commandTable.Description:sub(1,sep-1),commandTable.Description:sub(sep+1)
		if #switches==0 then
			switches='None'
		end
		return text:format(commandTable.Name,desc,table.concat(commandTable.Commands,','),tostring(commandTable.Rank),switches,(not commandTable.serverOnly and'False'or'True'))
	end
	for i,v in orderedPairs(Commands)do
		if v.Rank==0 then
			table.insert(r0,v)
		end
		if v.Rank==1 then
			table.insert(r1,v)
		end
		if v.Rank==2 then
			table.insert(r2,v)
		end
		if v.Rank==3 then
			table.insert(r3,v)
		end
		if v.Rank==4 then
			table.insert(r4,v)
		end
	end
	local asdf={r0t,r1t,r2t,r3t,r4t}
	for i,v in pairs{r0,r1,r2,r3,r4}do
		for ii,vv in pairs(v)do
			asdf[i]=asdf[i]..makeDoc(vv)..'\n'
		end
	end
	print(('%s\n%s\n%s\n%s\n%s'):format(asdf[1],asdf[2],asdf[3],asdf[4],asdf[5]))
end
function split(msg,bet)
	local f=msg:find(bet)
	if f then
		return msg:sub(1,f-1),msg:sub(f+1)
	else
		return msg
	end
end
function convertJoinedAtToTime(tim)
	if not tim then return "<NULL>"end
	local M='AM'
	local Date,Rest=split(tim,'T')
	local Time1,Time2=split(Rest,':')
	if tonumber(Time1)>12 then
		Time1=Time1-12
		M='PM'
	end
	return(Time1..':'..Time2:sub(1,5).." "..M.." - "..Date)
end