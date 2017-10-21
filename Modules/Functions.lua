--FUNCTIONS.LUA--
operatingsystem=require('ffi').os
color=discordia.Color.fromRGB
mutex=discordia.Mutex()
pprint=require("pretty-print")
query=require("querystring")
enclib=require("encrypter")
http=require("coro-http")
timer=require("timer")
ssl=require('openssl')
json=require("json")
uv=require("uv")
colors={
	red=color(255,0,0).value,
	blue=color(0,0,255).value,
	green=color(0,255,0).value,
	orange=color(255,160,0).value,
	yellow=color(255,255,0).value,
	bright_blue=color(0,200,255).value,
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
function getTimestamp()
	return discordia.Date():toISO('T','Z')
end
function embed(title,desc,color,fields,other)
	local emb={}
	set(title,emb,'title')
	set(desc,emb,'description')
	set(color,emb,'color')
	set(fields,emb,'fields')
	if other then
		for i,v in pairs(other)do
			set(v,emb,i)
		end
	end
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
		return obj:reply(con)
	elseif obj.sendMessage then
		return obj:sendMessage(con)
	elseif obj.send then
		return obj:send(con)
	end
	if doSend then
		sendMessage(obj,'-'..orig:sub(1983))
	end
end
function sendTempMessage(tab,seconds)
	coroutine.wrap(function()
		local msg=sendMessage(unpack(tab))
		timer.sleep(seconds*1000)
		msg:delete()
	end)()
end
function getRank(member,server)
	if not member then client:warning('No member object. getRank()')return 0 end
	local rank=0
	if server then
		local settings=Database:Get(member.guild).Settings
		for i,v in pairs(settings.mod_roles)do
			local o=member.guild:getRole(v)
			if o then
				if member:hasRole(o)then
					rank=1
				end
			end
		end
		for i,v in pairs(settings.admin_roles)do
			local o=member.guild:getRole(v)
			if o then
				if member:hasRole(o)then
					rank=2
				end
			end
		end
		for i,v in pairs(settings.co_owner_roles)do
			local o=member.guild:getRole(v)
			if o then
				if member:hasRole(o)then
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
	for role in member.roles:iter() do
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
	return guild:getMember(client.user)
end
function getHighestRole(member)
	local h=0
	if member.guild.owner.id==member.id then h=99999 end
	if member.id==client.owner.id then h=99999999999 end
	for role in member.roles:iter()do
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
	for member in guild.members:iter()do
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
	local settings=Database:Get(message).Settings
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
	return overwrite:denyPermissions('sendMessages')
end
function unmute(member,channel)
	local overwrite=channel:getPermissionOverwriteFor(member)
	return overwrite:clearPermissions('sendMessages')
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
	local a=io.open('docs.txt','w')
	local b=a:write(('%s\n%s\n%s\n%s\n%s'):format(asdf[1],asdf[2],asdf[3],asdf[4],asdf[5]))
	local c=b:flush()
	local d=c:close()
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
function newVote(guild,member,topic,voptions)
	local vote=Database:Get(guild).Votes
	if vote.activeVote then
		return"Invalid vote. [VOTE ALREADY RUNNING]"
	end
	voptions=voptions or{}
	if #voptions<2 then
		return"Invalid vote. [NOT ENOUGH OPTIONS]"
	end
	local vote={
		starterID=member.id,
		topic=topic,
		options={}
	}
	for i,v in pairs(voptions)do
		table.insert(vote.options,{count=0,option=v,voters={}})
	end
	return vote
end
function endVote(guild)
	local vote=Database:Get(guild).Votes
	if not vote.activeVote then
		return"Invalid vote. [NO VOTE RUNNING]"
	end
	local tx="End of vote results: \n\n"..getVoteCount(guild)
	local db=Database:Get(guild).Votes
	db.activeVote=nil
	Database:Update(guild)
	return tx
end
function getVoteCount(guild)
	local tx=''
	local vote=Database:Get(guild).Votes
	if vote.activeVote then
		local vdata=vote.activeVote
		tx=tx..'Vote topic: '..vdata.topic..'\n\nOptions:\n'
		for i=1,#vdata.options do
			local data=vdata.options[i]
			tx=tx..'#'..i..' | Option: '..data.option..' | Votes: '..data.count..'\n'
		end
	else
		return"[NO RUNNING VOTE]"
	end
	return tx
end
function addVote(guild,member,optionNum)
	local vote=Database:Get(guild).Votes
	if vote.activeVote then
		local vdata=vote.activeVote
		for i,v in pairs(vdata.options)do
			for ii,vv in pairs(v.voters)do
				if vv==member.id then
					v.count=v.count-1
					table.remove(v.voters,ii)
					--return"Invalid vote. [ALREADY VOTED]"
				end
			end
		end
		local op=vdata.options[optionNum]
		if op then
			op.count=op.count+1
			table.insert(op.voters,member.id)
			Database:Update(guild)
			return"Valid vote. [COUNT ADDED]\n"..getVoteCount(guild)
		else
			return"Invalid vote. [OPTION DOES NOT EXIST]"
		end
	else
		return"Invalid vote. [NO RUNNING VOTE]"
	end
end
function checkForCopies(tab,value)
	for i,v in pairs(tab)do
		if v==value then
			return true
		end
	end
end
function parseTime(message)
	local t={}
	for i,v in pairs(string.split(message,' '))do
		for de,str in v:gmatch('(%d?%d?%d?%d?%d)(%S?%S?%S?%S)')do
			local s=str:lower()
			if s=='y'or s:sub(1,4)=='year'then
				t.years=de
			elseif s=='mo'or s:sub(1,5)=='month'then
				t.months=de
			elseif s=='w'or s:sub(1,4)=='week'then
				t.weeks=de
			elseif s=='d'or s:sub(1,3)=='day'then
				t.days=de
			elseif s=='h'or s:sub(1,4)=='hour'then
				t.hours=de
			elseif s=='m'or s=='mi'or s:sub(1,6)=='minute'then
				t.minutes=de
			elseif s=='s'or s:sub(1,6)=='second'then
				t.seconds=de
			end
		end
	end
	return t
end
function toSeconds(tim)
	if not type(tim)=='table'then return 0 end
	local s=0
	local secs={
		years=31536000,
		months=60*60*24*31,
		weeks=60*60*24*7,
		days=60*60*24,
		hours=60*60,
		minutes=60,
		seconds=1,
	}
	for typ,val in pairs(tim)do	
		s=s+(secs[typ]*val)
	end
	return s
end
function resolveGuild(guild)
	local ts=tostring
	if not guild then error"No ID/Guild/Message provided"end
	local id
	if type(guild)=='table'then
		if guild['guild']then
			id=ts(guild.guild.id)
		else
			id=ts(guild.id)
		end
	else
		id=ts(guild)
		guild=client:getGuild(id)
	end
	return id,guild
end
function resolveChannel(guild,name)
	local this=getIdFromString(name)
	if this then
		c=guild:getChannel(this)
	else
		c=guild.textChannels:find(function(c)
			return c.name==name
		end)
	end
	return c
end
function sendAudit(guild,content,embed)
	local id,guild=resolveGuild(guild)
	local settings=Database:Get(guild).Settings
	if convertToBool(settings.audit_log)==true then
		local chan=resolveChannel(guild,settings.audit_log_chan)
		if chan then
			sendMessage(chan,content,embed)
		end
	end
end
function sendModLog(guild,fields)
	local id,guild=resolveGuild(guild)
	local settings=Database:Get(guild).Settings
	if convertToBool(settings.mod_log)==true then
		local chan=resolveChannel(guild,settings.mod_log_chan)
		if chan then
			sendMessage(chan,embed('ModLog',nil,colors.blue,fields),true)
		end
	end
end
function reasonEnforced(guild)
	local id,guild=resolveGuild(guild)
	local settings=Database:Get(guild).Settings
	if convertToBool(settings.mod_log)==true then
		return true
	end
end