local beta=true
local discordia=require('discordia')
local http=require('http')
local json=require('json')
local fb=require('luvit-firebase')
local http=require('coro-http')
local encrypt=require('encrypter')
local thread=require('thread')
local operatingsystem=require('ffi').os
local uv=require('uv')
local spawn=require('coro-spawn')
local split=require('coro-split')
local parse=require('url').parse
local timer=require('timer')
local qstring=require('querystring')
local client=discordia.Client{fetchMembers=true}
local Token='hidden'
local Owner_Id='265695159176396803'
local Audit_Log_ID='284459469365182475'
local Bet=(beta==true and'>'or':')
Bot={
	Name=(beta==true and'Electricity(BETA)'or'Electricity'),
	ClientID='284380758611591170',
	Settings={
		Bet=Bet,
		Start_Game='Say "about'..Bet..'" for help!',
	},
}
Resources={
	OAuth='https://discordapp.com/api/oauth2/authorize?client_id=%s&scope=bot&permissions=16384',
	OAuthA='https://discordapp.com/api/oauth2/authorize?client_id=%s&scope=bot&permissions=8',
	Colors={
		Red=0xFF0000,
		Yellow=0xFFFF00,
		Blue=0x0099FF,
		Bright_Blue=0x00FFFF,
		Green=0x00FF00,
	},
	Default_Guild_Settings={
		Anti_Link=false,
		Audit_Log=false,
		Case_System=false,
		Anti_Owner_Mention=false,
		Vote_System_Enabled=false,
		Invite_Maker=false,
		Join_Log=false,
		Leave_Log=false,
		Vote_Starter_Required_Rank=0,
		Bet=':',
		Before_After='after',
		Join_Message='null',
		Join_Log_Channel='null',
		Invite_Channel='null',
		Case_Channel='null',
		Audit_Log_Channel='null',
		Vote_System_Channel='null',
		Moderator_Role='Moderators',
		Administrator_Role='Administrators',
		Secondary_Administrator_Role='Other Administrators',
	},
	Setting_Descriptions={
		Anti_Link='Prevents users from posting OAUTH2 links, and discord.gg links.',
		Audit_Log='Chooses if the audit-log feature is on.',
		Case_System='Chooses if the case system is active. The case system makes moderators state the reason of their action.',
		Anti_Owner_Mention='If you set this to true, '..Bot.Name..' will automatically delete messages that mention you, so you do not get notified.',
		Vote_System_Enabled='If this is enabled, the vote system shall be active within your guild.',
		Invite_Maker='If enabled, the bot can generate invites using the geninv cmd.',
		Join_Log='If enabled, upon a join, a message is placed in the Join_Log_Channel.',
		Leave_Log='If enabled, upon a guild member leaving, a message is placed in the Join_Log_Channel',
		Vote_Starter_Required_Rank='Decides what rank can start a vote, using the voting system.',
		Bet='Decides what bet shall be used in this guild.',
		Before_After='Decides if the bet is used before, or after. Example: before | >vote topic opt1 opt2 | after | vote>topic>opt1>opt2',
		Join_Message='What the join log says if joinlog is on and joinlogchannel is set. The bot will auto replace "//mention" with the user\'s mention.',
		Join_Log_Channel='Chooses where join log messages go.',
		Invite_Channel='Chooses what channel the invite-maker tries to make the invites in.',
		Case_Channel='Simply chooses what channel the case system uses to log actions.',
		Audit_Log_Channel='Channel for the audit-log.',
		Vote_System_Channel='Channel for the vote system.',
		Moderator_Role='This role provides rank 1 [mod] access in Electricity. Caps sensitive. Arguments: <role name>', 
		Administrator_Role='This role provides rank 2 [admin] access in Electricity. Caps sensitive. Arguments: <role name>',
		Secondary_Administrator_Role='Same as Administrator_Role, just allows you to set two roles to have admin permissions.',
	},
	IDs={
		Error_Channel='293217140285243393',
		Warning_Channel='293217153581187092',
		Official_Server='284895856031956992',
		Test_Server_ID='284381751084843008',
		Ready_Channel_ID='295213688913264641',
	},
}
Case_EDITS={}
Commands={}
Emitter={
	Emitters={},
}
Queue={}
AdvancedQueue={}
Verification_Codes={}
Hooks={
	['Errors']='<REDACTED>',
	['Warnings']='<REDACTED>',
	['Ready']='<REDACTED>',
	['Audit']='<REDACTED>',
	['Errors_B']='<REDACTED>',
	['Warnings_B']='<REDACTED>',
	['Ready_B']='<REDACTED>',
	['Audit_B']='<REDACTED>',
}
function sendLog(hook,title,description,color)
	if beta==true then hook=hook..'_B'end
	local post
	if type(title)=='table'then
		title.color=color
		post={embeds={title}}
	else
		post={embeds={{title=title,description=description,color=color}}}
	end
	http.request("POST",Hooks[hook],{{"Content-Type","application/json"}},json.encode(post))	
end
function timeStamp()
	return os.date("%I:%M:%S %p - %a, %b %d")
end
function wait(s)
	if not tonumber(s)then
		return"argument #1 not a number"
	end
	local ts=timeStamp()
	timer.sleep(s*1000)
	return("Began at: "..ts),("Ended at: "..timeStamp())
end
function ypcall(func,...)
	if type(func)~='function'then
		return false,"argument #1 not a function"
	end
	local coro=coroutine.wrap(func)
	return pcall(coro,...)
end
function yxpcall(func,callback)
	if type(func)~='function'then
		return false,"argument #1 not a function"
	end
	if type(callback)~='function'then
		return false,"argument #2 not a function"
	end
	local coro=coroutine.wrap(func)
	local ccoro=coroutine.wrap(callback)
	return xpcall(coro,ccoro)
end
xypcall=yxpcall
function getFlags(str)
	local r={}
	for flag,content in string.gmatch(str,'%-%-(%S*)%s*([^%-]*)')do
		r[flag]=content
	end
	return r
end
function rtprint(tab)
	local op='<OUTPUT BEGIN>\n'
	for i,v in pairs(tab)do
		if type(v)=='table'then
			for ii,vv in pairs(v)do
				if type(vv)=='table'then
					for iii,vvv in pairs(vv)do
						op=op..'\t'.."Table ["..tostring(vv)..']\t\t'..tostring(iii)..' | '..tostring(vvv)..' | '..tostring(type(vvv))..'\n'
					end
				else
					op=op..'\t'.."Table ["..tostring(v)..']\t\t'..tostring(ii)..' | '..tostring(vv)..' | '..tostring(type(vv))..'\n'
				end
			end
		else
			op=op..'\t'..tostring(i)..' | '..tostring(v)..' | '..tostring(type(v))..'\n'
		end
	end
	op=op..'<OUTPUT END>'
	return op
end
Database={}
Database.Cache={}
Database.Databases={}
Database.Defaults={
	['Settings']=Resources.Default_Guild_Settings,
	['Ignore']=function(guild)
		if not guild then return end
		if guild['guild']then
			guild=guild.guild
		end
		local e,ret=pcall(function()
			local tab={}
			for textChannel in guild.textChannels do
				tab[textChannel.name]=false
			end
			return tab
		end)
		if not e then
			print("[IGNORE DEFAULT] ERROR | "..tostring(ret).." | GUILD NAME: "..tostring(guild.name).." | GUILD ID: "..tostring(guild.id))
			return{}
		else
			return ret
		end
	end,
	['Bans']={['000000']='test#0000'},
	['Cases']={['Case: 0']={Time=tostring(timeStamp()),Moderator='test#0000',ModeratorId='000000',Reason='Setting up the case database.',Case='Mute'}},
	['Roles']={['default']={name='Default',id='00000000'}},
	['Votes']={},
	['Mutes']={},
}
for i,v in pairs({
	['Settings']=fb('xxxx'),
	['Ignore']=fb('xxxx'),
	['Bans']=fb('xxxx'),
	['Cases']=fb('xxxx'),
	['Roles']=fb('xxxx'),
	['Votes']=fb('xxxx'),
	['Mutes']=fb('xxxx'),
})do
	Database.Databases[i]=v
	Database.Cache[i]={}
end
function Database:Get(datab,guild,ind)
	local ts=tostring
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
	if Database.Cache[datab]then
		if Database.Cache[datab][id]then
			return Database.Cache[datab][id]
		else
			local function callback(e,ret)
				if e then
					print(("ERROR IN DATABASE:\n\tDATABASE: %s\n\tGUILD NAME: %s\n\tGUILD ID: %s\n\tREQUEST: %s"):format(ts(datab),ts(guild.name),ts(id),ts(ind)))
				else
					if ret=='null'or ret==nil then
						if Database.Defaults[datab]then
							local t=Database.Defaults[datab]
							if type(t)=='function'then
								t=t(guild)
							end
							Database.Cache[datab][id]=t
							return t
						else
							Database.Cache[datab][id]={}
							return{}
						end
					else
						local data=type(ret)=='table'and ret or json.decode(ret)
						local update=false
						if Database.Defaults[datab]then
							local t=Database.Defaults[datab]
							if type(t)=='function'then
								t=t(guild)
							end
							for index,value in pairs(t)do
								if not data[index]then
									data[index]=value
									update=true
								end
							end
						end
						Database.Cache[datab][id]=data
						if update then
							Database:Update(datab,id)
						end
					end
				end
			end
			local e,ret=Database.Databases[datab]:get(id,callback)
			callback(e,ret)
		end
	else
		print("Database does not exist. ["..tostring(datab).."]")
	end
end
function Database:Update(datab,guild,ind,val)
	local ts=tostring
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
	local Db=Database.Databases[datab]
	local cache=Database.Cache[datab]
	local function cb(e,ret)
		if e then
			print(("ERROR IN DATABASE:\n\tDATABASE: %s\n\tGUILD NAME: %s\n\tGUILD ID: %s\n\tREQUEST: %s"):format(ts(datab),ts(guild.name),ts(id),'Update'))
		end
	end
	if Db then
		if id then
			if cache[id]then
				if ind then
					Database.Cache[datab][id][ind]=val
				end
				local e,ret=Db:set(id,json.encode(Database.Cache[datab][id]),cb)
				if e then
					cb(e,ret)
				end
			else
				local Default=Database.Defaults[datab]
				if type(Default)=='function'then Default=Default(guild)end
				if Default then
					local e,ret=Db:set(id,json.encode(Default),cb)
					if e then
						cb(e,ret)
					end
				end
			end
		else
			if not Database.Cache[datab]then return end
			local data={}
			for i,v in pairs(Database.Cache[datab])do
				print(i)
				local e,ret=Db:set(i,json.encode(v),cb)
				if e then
					cb(e,ret)
				end
			end
		end
	else
		print("Database does not exist. ["..tostring(datab).."]")
	end
end
function FieldsToText(fields)
	local tx=''
	for i,v in pairs(fields)do
		local txt
		local s=tostring(v.name):sub(1,2)=='**'
		if s then
			txt=tostring(v.name)
		else
			txt='**'..tostring(v.name)..'**'
		end
		tx=tx..txt..'\t'..tostring(v.value)..'\n'
	end
	return tx
end
function Emitter:New(EventName,Callback)
	if not EventName then return"Lack of EventName argument (1st argument)"end
	if not EventName then return"Lack of Callback argument (2nd argument)"end
	local Id=encrypt.Randomizer(20)
	local function CheckId()
		for i,v in pairs(Emitter.Emitters)do
			if v.EmitId==Id then
				return true
			end
		end
		return false
	end
	repeat 
		if CheckId()==true then
			Id=encrypt.Randomizer(20)
		end
	until not CheckId()
	table.insert(Emitter.Emitters,{
		EventName=EventName,
		Callback=Callback,
		EmitId=Id,
	})
	return Id
end
function Emitter:Rem(EmitId)
	if not EmitId then return"Lack of Emitter ID argument (1st argument)"end
	for i,v in pairs(Emitter.Emitters)do
		if v.EmitId==EmitId then
			table.remove(Emitter.Emitters,i)
		end
	end
end
function Emitter:Fire(EventName,...)
	if not EventName then return"Lack of EventName argument (1st argument)"end
	for i,v in pairs(Emitter.Emitters)do
		if v.EventName==EventName then
			coroutine.wrap(v.Callback)(...)
		end
	end
end
function Queue:New()
	local NewQueue
	local code=Encrypt.Randomizer(75)
	NewQueue=setmetatable({
		Current='null',
		Previous='null',
		Limit=25,
		Queue={},
		Emits={},
		EName=('Queue'..code),
	},{
		__tostring=NewQueue.EName,
	})
	local function GTN(t)
		local n=0
		for i,v in pairs(t)do
			n=n+1
		end
		return n
	end
	function NewQueue:New(...)
		local t={...}
		for i,v in pairs(t)do
			if GTN(NewQueue.Queue)>NewQueue.Limit then return end
			table.insert(NewQueue.Queue,tostring(v))
		end
	end
	function NewQueue:Next()
		local self=NewQueue
		local cur=self.Queue[1]
		table.remove(self.Queue,1)
		if self.Queue[1]then
			self.Current=self.Queue[1]
		else
			print'<Queue> Queue ended.'
			self.Current='null'
		end
		if cur then
			self.Previous=cur
		else
			self.Previous='null'
		end
		NewQueue:Fire(self.Current,self.Previous)
	end
	function NewQueue:On(callback)
		local self=NewQueue
		if not callback or type(callback)~='function'then return"Invalid type to argument 1 (callback)"end
		local Emit=Emitter:New(self.EName,callback)
		if tostring(Emit):lower():sub(1,4)=='lack'then return tostring(Emit)end
		table.insert(self.Emits,Emit)
	end
	function NewQueue:Fire(...)
		Emitter:Fire(NewQueue.EName,...)
	end
	function NewQueue:Clear()
		NewQueue.Queue={}
	end
	function NewQueue:Destroy()
		NewQueue:Clear()
		for i,v in pairs(NewQueue.Emits)do
			Emitter:Rem(v)
		end
	end
	return NewQueue
end
function AdvancedQueue:New()
	local NQueue=Queue:New()
	NQueue.EName='Advanced_'..NQueue.EName
	
end
function AddCommand(Name,Desc,Cmds,Rank,Func,Multi)
	if not Multi then Multi=false end
	Commands[Name]={Name=Name,Desc=Desc,Cmds=type(Cmds)=='table'and Cmds or{Cmds},Rank=Rank,Func=Func,Multi=Multi}
end
function getTableNumber(t)
	local n=0
	for i,v in pairs(t)do
		n=n+1
	end
	return n
end
function pingWebsite(web)
	local sw=discordia.Stopwatch()
	local req,data=http.request("GET",web)
	if data then
		return tostring(sw.milliseconds)..' ms'
	else
		return "-1 ms (HTTP get failed.)"
	end
end
function oneTable(tab)
	local newtab={}
	for i,v in pairs(tab)do
		table.insert(newtab,v)
	end
	return newtab
end
function startVote(message,args)
	
end
function stopVote(message)
	
end
function addVote(message,num)
	
end
function getAllGuilds()
	local t={}
	for guild in client.guilds do
		if not guild then return end
		table.insert(t,guild)
	end
	return t
end
function Split(msg,bet)
	local f=msg:find(bet)
	if f then
		return msg:sub(1,f-1),msg:sub(f+1)
	else
		return msg
	end
end
function Mute(member)
    local guild=member.guild
    local role=guild:getRole("name","ElectricMuted")or guild:createRole()
    if not role then return false end
	if member:hasRole(role)then return"Member is already muted."end
	if role.name~="ElectricMuted"then
        role.name="ElectricMuted"
        role:disableAllPermissions()
    end
    for textChannel in guild.textChannels do
        local overwrite=textChannel:getPermissionOverwriteFor(role)
        local denied=overwrite:getDeniedPermissions()
        denied:enable('sendMessages')
        overwrite:setDeniedPermissions(denied)
    end
    if not member:addRoles(role)then return false end
	ypcall(function()
		local takenRoles={}
		for role in member.roles do
			if role.name~='ElectricMuted'then
				member:removeRoles(role)
				table.insert(takenRoles,role.id)
			end
		end
		Database:Update('Mutes',member.guild,member.id,takenRoles)
	end)
    member:setMute(true)
    return true
end
function Unmute(member)
    local guild=member.guild
    local role=guild:getRole("name","ElectricMuted")or guild:createRole()
    if not role then return false end
	if not member:hasRole(role)then return"Member is not muted."end
	if role.name~="ElectricMuted"then
        role.name="ElectricMuted"
        role:disableAllPermissions()
    end
    if not member:removeRoles(role)then return false end
	local mutedata=Database:Get('Mutes',member.guild)
	mutedata=mutedata[member.id]
	if mutedata then
		Database:Update('Mutes',member.guild,member.id,nil)
		for i,roleid in pairs(mutedata)do
			local role=guild:getRole(roleid)
			if role then
				member:addRoles(role)
			end
		end
	end
    member:setMute(false)
    return true
end
function getBotMember(guild)
	if guild then
		return client.user:getMembership(guild)
	end
end
function getPermissions(message,perm)
	local member,overwrite
	if not message['member']then
		member=message
	else
		member=message.member
	end
	for role in member.roles do
		if role.permissions:has('administrator')then
			return true
		elseif role.permissions:has(perm)then
			return true
		end
	end
	if message['channel']then
		overwrite=message.channel:getPermissionOverwriteFor(member)
		if overwrite.allowedPermissions:has(perm)then
			return true
		end
	end
	return false
end
function findMember(guild,tofind,exacto)
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
function findDiscrims(guild,discrim)
	if not guild then return false,-1,"bad argument to #1, guild expected"end
	if not tonumber(discrim)then return false,-1,"bad argument to #2, discriminator/number expected"end
	local n=0
	for member in guild.members do
		if tonumber(member.discriminator)==discrim then
			n=n+1
		end
	end
	return true,n,''
end
function sendMessage(obj,content,embed)
	if not embed then embed=false end
	local msg=(embed==true and{embed=content}or content)
	if obj.sendMessage then
		return obj:sendMessage(msg)
	elseif obj.reply then
		return obj:reply(msg)
	else
		client:warning(tostring(obj).." | has no obj:sendMessage or obj:reply function.")
	end
end
function getRank(message)
	local guildsettings=Database:Get('Settings',message.guild)
	local member=message.member
	if not member then return end
	local rank=0
	local MR,AR,SAR
	if guildsettings then
		MR=message.guild:getRole('name',guildsettings.Moderator_Role)
		AR=message.guild:getRole('name',guildsettings.Administrator_Role)
		SAR=message.guild:getRole('name',guildsettings.Secondary_Administrator_Role)
	end
	if MR then
		if member:hasRole(MR)then
			rank=1
		end
	end
	if AR then
		if member:hasRole(AR)then
			rank=2
		end
	end
	if SAR then
		if member:hasRole(SAR)then
			rank=2
		end
	end
	if message.guild.owner then
		if tostring(member.id)==tostring(message.guild.owner.id)then
			rank=3
		end
	end
	if tostring(member.id)==Owner_Id then
		rank=4
	end
	return rank
end
function getRole(message)
	local guildsettings=Database:Get('Settings',message.guild)
	local member=message.member
	local rank=0
	local MR,AR,SAR
	if guildsettings then
		MR=message.guild:getRole('name',guildsettings.Moderator_Role)
		AR=message.guild:getRole('name',guildsettings.Administrator_Role)
		SAR=message.guild:getRole('name',guildsettings.Secondary_Administrator_Role)
	end
	if MR then
		if member:hasRole(MR)then
			return MR
		end
	end
	if AR then
		if member:hasRole(AR)or member:hasRole(SAR)then
			return AR
		end
	end
	if message.guild.owner then
		if tostring(member.id)==tostring(message.guild.owner.id)then
			return{name='Server owner',id='0000000',position=40000}
		end
	end
	if tostring(member.id)==Owner_Id then
		return{name='Bot creator',id='0000000',position=50000}
	end
end
function checkForBans(message)
	local bans=Database:Get('Bans',message.guild)
	if bans then
		local member=message.member
		for id,name in pairs(bans)do
			if name=='nullified'then return end
			if tostring(id)==tostring(member.id)then
				return member:kick()
			end
		end
	end
	return false
end
function convertTextToBoolean(txt)
	if type(txt)=='boolean'then
		return txt
	else
		if type(txt)=='string'then
			if txt:lower():sub(1,3)=='yes'then
				return true
			elseif txt:lower():sub(1,3)=='yus'then
				return true
			elseif txt:lower():sub(1,4)=='true'then
				return true
			elseif txt:lower():sub(1,2)=='no'then
				return false
			elseif txt:lower():sub(1,2)=='nu'then
				return false
			elseif txt:lower():sub(1,5)=='false'then
				return false
			end
		end
	end
end
function convertJoinedAtToTime(tim)
	if not tim then return "<NULL>"end
	local M='AM'
	local Date,Rest=Split(tim,'T')
	local Time1,Time2=Split(Rest,':')
	if tonumber(Time1)>12 then
		Time1=Time1-12
		M='PM'
	end
	return(Time1..':'..Time2:sub(1,5).." "..M.." - "..Date)
end
function embed(title,description,color,fields)
	local tab={}
	if title then
		tab.title=tostring(title)
	end
	if description then
		tab.description=description
	end
	if color then
		tab.color=color
	end
	if fields then
		tab.fields=fields
	end
	return tab
end
function getCatPicture()
	local requestdata,request=http.request('GET','http://random.cat/meow')
	return json.decode(request).file
end
function getGiphy(tosearch)
	tosearch=qstring.urlencode(tosearch)
	local requestdata,request=http.request('GET','http://api.giphy.com/v1/gifs/search?q='..tosearch..'&api_key=<REDACTED>')
	local decoded=json.decode(request)
	local selected=decoded.data[math.random(1,#decoded.data)]
	if not selected or not selected.url then return{embed=embed(nil,"No gif found.",Resources.Colors.Red)}end
	return selected.url
end
function makeInvite(message)
	local guild=message.guild
	local member=message.member
	local channel=message.channel
	local guildsettings=Database:Get('Settings',message.guild)
	if guildsettings then
		if convertTextToBoolean(guildsettings.Invite_Maker)==true then
			local chan=guild:getChannel("name",guildsettings.Invite_Channel)
			if not chan then chan=guild.defaultChannel end
			local invite=chan:createInvite(1*60*60,1,nil,true)
			if invite then
				sendMessage(message,embed(nil,"I have messaged you with the invite.",Resources.Colors.Yellow),true)
				sendMessage(member,embed("Invite","discord.gg/"..invite.code,Resources.Colors.Blue),true)
				if convertTextToBoolean(guildsettings.Audit_Log)==true then
					local chanzel=message.guild:getChannel("name",guildsettings.Audit_Log_Channel)
					if chanzel then
						sendMessage(chanzel,embed("Invite",
							("**Invite generated by:** %s \n\n **Invite code:** %s \n\n **Channel:** %s \n\n **Channel made in:** %s \n\n **Timestamp:** %s"):format(member.username..'#'..member.discriminator..' ('..member.id..')',invite.code,chan.mentionString,channel.mentionString,timeStamp())
						,Resources.Colors.Blue),true)
					end
				end
			else
				sendMessage(message,embed(nil,"Cannot generate invites, lacking permission to generate invites in "..chan.mentionString,Resources.Colors.Blue),true)
			end
		end
	end
end
function setupGuild(guild)
	Database:Get('Settings',guild)
	Database:Get('Ignore',guild)
	Database:Get('Roles',guild)
	Database:Get('Cases',guild)
	Database:Get('Mutes',guild)
	Database:Get('Bans',guild)
end
AddCommand('Verify','Verifies a user. <Only in the official Electricity server.>','verify',0,function(args,message)
	if message.channel.id=='297924241125539852'then
		local Role=message.guild:getRole('name','Member')
		if not args[1]or #args[1]==0 then
			local code=encrypt.Randomizer(25)
			Verification_Codes[code]=true
			sendMessage(message,embed(nil,"Sending verification code.",Resources.Colors.Bright_Blue),true)
			sendMessage(message.author,embed(nil,"Your verification code is `"..code.."`! Use verify: with your code to verify yourself in the server!",Resources.Colors.Bright_Blue),true)
		else
			local code=args[1]
			if Verification_Codes[code]then
				Verification_Codes[code]=nil
				sendMessage(message,embed(nil,"Verified.",Resources.Colors.Bright_Blue),true)
				message.member:addRole(Role)
			else
				sendMessage(message,embed(nil,"Invalid code.",Resources.Colors.Red),true)
			end
		end
	end
end)
AddCommand('Calculate','Calculates <math>',{'calc','calculate'},0,function(args,message)
	if #args[1]<1 then return sendMessage(message,embed(nil,"You must specify what to calculate.",Resources.Colors.Red),true)end
	local function sm(t)
		sendMessage(message,embed(nil,t,Resources.Colors.Yellow),true)
	end
	local f,n=loadstring("return "..args[1])
	if not f then
		sm'Cannot calculate'
	else
		setfenv(f,{math=table.copy(math)})
		local a,b=pcall(f)
		if not a then
			sm'Cannot calculate'
		else
			if not tonumber(b)then
				sm'Cannot Calculate'
			else
				sm(tostring(b))
			end
		end
	end
end)
AddCommand('Ping Website[2]','Pings <website>','wwping',0,function(args,message)
	local m=sendMessage(message,embed(nil,'Pinging: '..args[1],Resources.Colors.Yellow),true)
	local output=''
	local child=spawn('ping',{
		args={args[1]},
		stdio={nil,true,true}
	})
	coroutine.wrap(function()
		split(function()
			for data in child.stdout.read do
				output=output..data..'\n'
			end
		end, function()
			for data in child.stderr.read do
				output=output..data..'\n'
			end
		end, child.waitExit)
		pcall(function()m:delete()end)
		sendMessage(message,embed('Results:',output,Resources.Colors.Yellow),true)
	end)()
end)
AddCommand('Ping website','Pings <website>','wping',0,function(args,message)
	local m=args[1]
	local ms=pingWebsite(m)
	sendMessage(message,embed(nil,"Results of pinging <"..m.."> | "..ms),true)
end)
AddCommand('Generate invite','Generates an invite',{'geninv','invite','getinv'},0,function(args,message)
	makeInvite(message)
end)
AddCommand('Cat','Gets a cat picture',{'cat','meow','kitten'},0,function(args,message)
	sendMessage(message,getCatPicture())
end)
AddCommand('Giphy','Searches giphy','giphy',0,function(args,message)
	local m=args[1]
	sendMessage(message,getGiphy(m))
end)
AddCommand('Vote','Voting system','vote',0,function(args,message)
	if message then return sendMessage(message,embed(nil,"I am sorry, but this feature is temporarily disabled due to very odd bugs.",Resources.Colors.Red),true)end
	
end,true)
AddCommand('Commands','Displays the commands','cmds',0,function(args,message,bet,frontal)
	local m=args[1]
	local a=true
	local txt=(frontal==false and'**Say cmds'..bet..'cmd to get info on that command!**\n'or'**Say '..bet..'..cmds cmd to get info on that command!**\n')
	local R0,R1,R2,R3,R4,fields={},{},{},{},{},nil
	for i,v in pairs(Commands)do
		for ind,cmd in pairs(v.Cmds)do
			if m:sub(1,#cmd):lower()==cmd:lower()or m:sub(1,#i):lower()==i:lower()then
				a=false
				fields={
					{name="Name:",value=i},
					{name="Desc:",value=v.Desc},
					{name="Cmds:",value=table.concat(v.Cmds,', ')},
					{name="Rank:",value=tostring(v.Rank)},
				}
			end
		end
		if a==true then
			if v.Rank==0 then
				table.insert(R0,i..' | Commands: {'..table.concat(v.Cmds,',')..'}\n')
			elseif v.Rank==1 then
				table.insert(R1,i..' | Commands: {'..table.concat(v.Cmds,',')..'}\n')
			elseif v.Rank==2 then
				table.insert(R2,i..' | Commands: {'..table.concat(v.Cmds,',')..'}\n')
			elseif v.Rank==3 then
				table.insert(R3,i..' | Commands: {'..table.concat(v.Cmds,',')..'}\n')
			elseif v.Rank==4 then
				table.insert(R4,i..' | Commands: {'..table.concat(v.Cmds,',')..'}\n')
			end
		end
	end
	if a==true then
		local R0T,R1T,R2T,R3T,R4T='','','','',''
		for ind,tx in pairs(R0)do
			R0T=R0T..tx
		end
		for ind,tx in pairs(R1)do
			R1T=R1T..tx
		end
		for ind,tx in pairs(R2)do
			R2T=R2T..tx
		end
		for ind,tx in pairs(R3)do
			R3T=R3T..tx
		end
		for ind,tx in pairs(R4)do
			R4T=R4T..tx
		end
		sendMessage(message.member,embed("Commands",nil,Resources.Colors.Yellow,{
			{name="User [Rank 0] commands:",value=R0T},
			{name="Moderator [Rank 1] commands:",value=R1T},
			{name="Administrator [Rank 2] commands:",value=R2T},
			{name="Server owner [Rank 3] commands:",value=R3T},
			{name="Bot creator [Rank 4] commands:",value=R4T},
		}),true)
	else
		sendMessage(message.member,embed("Commands",nil,Resources.Colors.Yellow,fields),true)
	end
	sendMessage(message,embed(nil,"I have messaged you with the commands list.",Resources.Colors.Yellow),true)
end)
AddCommand('Beep','Beeps the bot.','beep',0,function(args,message)
	sendMessage(message,embed(nil,"Boop!",Resources.Colors.Yellow),true)
end)
AddCommand('Nib','nib','nib',0,function(args,message)
	sendMessage(message,":regional_indicator_n: :regional_indicator_i: :regional_indicator_b:")
end)
AddCommand('Bot invite','OAuth2 invite link.','botinv',0,function(args,message)
	sendMessage(message.member,embed(nil,"For administrative:\n"..Resources.OauthA:format(Bot.ClientID).."\nFor non administrative:\n"..Resources.OAuth:format(Bot.ClientID),Resources.Colors.Yellow),true)
	sendMessage(message,embed("I have messaged you with the invitation link. :smile: ",Resources.Colors.Yellow),true)
end)
AddCommand('Join','Joins the official server!','join',0,function(args,message)
	sendMessage(message.member,"https://discord.gg/KCMxtK8")
	sendMessage(message,embed(nil,"I have messaged you with the invitation link.",Resources.Colors.Yellow),true)
end)
AddCommand('User Info','Gets your user info.','uinfo',0,function(args,message)
	local user=message.member.user
	local mem=message.member
	if message:mentionedUsers() then
		user=message.guild:getMember(message:mentionedUsers().id)
		mem=user:getMembership(message.guild)
	end
	local tab={
		guild=message.guild,
		member=mem,
	}
	local rankn=getRank(tab)
	local rank="User [0]"
	if rankn==1 then
		rank="Moderator [1]"
	end
	if rankn==2 then
		rank="Administrator [2]"
	end
	if rankn==3 then
		rank="Server owner [3]"
	end
	if tostring(user.id)==Owner_Id then
		rank="Creator [4]"
	end
	sendMessage(message,embed("User info",nil,Resources.Colors.Yellow,{
		{name='Name:',value=(user.name~=user.username and user.username.." ("..user.name..")"or user.name)},
		{name='Discriminator:',value=user.discriminator},
		{name='Id:',value=user.id},
		{name='Rank:',value=rank},
		{name="Is bot:",value=(user.bot==true and'Yes'or'No')},
		{name="Is member of the official server:",value=(user:getMembership(client:getGuild(Resources.IDs.Official_Server))~=nil and'Yes'or'No')},
		{name="Joined the guild at:",value=convertJoinedAtToTime(mem.joinedAt)},
	}),true)
end)
AddCommand('About','About the bot','about',0,function(args,message,bet,frontal)
	local ts=tostring
	sendMessage(message,embed("Bot info",nil,Resources.Colors.Yellow,{
		{name="My name is:",value=ts(Bot.Name)},
		{name="I was created on:",value="2/23/17 by "..ts(client.owner.username)..'#'..ts(client.owner.discriminator).."."},
		{name="I am currently in:",value=ts(client:getGuildCount())..' guilds!'},		
		{name="I currently serve:",value=ts(client.memberCount)..' members!'},
		{name="To join my official server:",value=ts((frontal==false and"Say `join"..bet.."`"or"Say `"..bet.."join`"))},
		{name="To view the commands:",value=ts((frontal==false and"Say `cmds"..bet.."`"or"Say `"..bet.."cmds`"))},
		{name="To see guild info:",value=ts((frontal==false and"Say `ginfo"..bet.."`"or"Say `"..bet.."ginfo`"))},
		{name="I've been running since:",value=ts(start)},
	}),true)
end)
AddCommand("Nerd info","Nerdy info for devs","ninfo",0,function(args,message)
	local ts=tostring
	local cpu=uv.cpu_info()
	local threads=#cpu
	local cpumodel=cpu[1].model
	local mem=math.floor(collectgarbage('count')/1000)
	sendMessage(message,embed('Nerdy Info',nil,Resources.Colors.Yellow,{
		{name='OS:',value=tostring(operatingsystem)},
		{name='CPU Threads:',value=ts(threads)},
		{name='CPU Model:',value=ts(cpumodel)},
		{name='Memory usage:',value=ts(mem)..' MB'},
	}),true)
end)
AddCommand('Guild info','Gets the guild\'s info','ginfo',0,function(args,message)
	local guild=message.guild
	local oname=guild.owner.username..'#'..guild.owner.discriminator
	local nam=(guild.owner.nickname and guild.owner.nickname..' ('..oname..')'or oname)..' | '..guild.owner.id
	local function getVerificationLevel()
		local v=guild.verificationLevel
		if v==0 then
			return"No requirements. (0)"
		elseif v==1 then
			return"Verified email on Discord. (1)"
		elseif v==2 then
			return"Registered on Discord for longer than 5 minutes. (2)"
		elseif v==3 then
			return"Guild member for more than 10 minutes. (3)"
		else
			return"No verification level. (-1)"
		end
	end
	sendMessage(message,embed("Guild info",nil,Resources.Colors.Yellow,{
		{name="Full guild name:",value=guild.name},
		{name="Guild id:",value=guild.id},
		{name="Guild owner:",value=nam},
		{name="Guild member count:",value=guild.totalMemberCount},
		{name="Guild channel count:",value=(guild:getChannelCount()..' (Text: '..guild:getTextChannelCount()..' | Voice: '..guild:getVoiceChannelCount()..')')},
		{name="Guild verification level:",value=tostring(getVerificationLevel())},
		{name="Region:",value=tostring(guild.region)},
		{name="Shard id:",value=guild.shardId},
		{name="This guild was created at:",value=convertJoinedAtToTime(guild.timestamp)},
	}),true)
end)
AddCommand('Chance of','Gets the chance of <message>','chance',0,function(args,message)
	sendMessage(message,embed(nil,"The chances are "..tostring(math.random(1,100)).."%!",Resources.Colors.Yellow),true)
end)
AddCommand('Subscribe','Subscribe to Electricity updates!','subscribe',0,function(args,message,b,f)
	local mem=message.member
	local user=mem.user
	local Server=client:getGuild(Resources.IDs.Official_Server)
	local member=user:getMembership(Server)
	if member then
		member:addRoles(Server:getRole("name","Subscribers"))
	else
		sendMessage(message,embed(nil,"You must be in the official Electricty server to subscribe! Say "..(not f and("join"..b)or(b.."join")).." to join!",Resources.Colors.Yellow),true)
	end
end)
AddCommand('Roll the dice','Dice!','rtdice',0,function(args,message)
	local f=math.random(1,6)
	sendMessage(message,embed(nil,"You rolled a "..tostring(f),Resources.Colors.Yellow),true)
end)
AddCommand('Flip a coin!','Coin flip!','cflip',0,function(args,message)
	local f=math.random(1,2)
	sendMessage(message,embed(nil,(f==1 and"Tails"or"Heads"),Resources.Colors.Yellow),true)
end)
AddCommand('Hug','Gives a user a hug.','hug',0,function(args,message,bet)
	if message:mentionedUsers()then
		local user=message:mentionedUsers()
		local mem=user:getMembership(message.guild)
		sendMessage(message,mem.mentionString..' You have been hugged by '..message.member.mentionString)
	else
		sendMessage(message,embed(nil,"You must mention the user you wish to hug.",Resources.Colors.Red),true)
	end
end)
AddCommand('Role','Role Manager, use the command with no arguments for more info.',{'role','roles'},0,function(args,message,b,frontal)
	local mem=message.member
	local rank=getRank(message)
	local publicroles=Database:Get('Roles',message.guild)
	local asd=true
	if args[1]:lower()=='public'then
		if args[2]:lower()=='list'then
			local t=''
			for i,v in pairs(publicroles)do
				if v.id==Database.Defaults['Roles']['default'].id then 
					--asd
				else
					t=t..tostring(v.name)..' | '..tostring(v.id)..'\n'
				end
			end
			message.channel:sendMessage({embed=embed('**Public Roles**',t,Resources.Colors.Bright_Blue)})
			asd=false
		else
			if args[3]then
				if args[2]:lower()=='add'and rank>2 then
					if publicroles[args[3]:lower()]then
						message.channel:sendMessage({embed=embed(nil,'This role is already on the public list!',Resources.Colors.Red)})
					else
						local r=message.guild:getRole('name',args[3])
						if r then
							Database:Update('Roles',message.guild,args[3]:lower(),{name=args[3],id=r.id})
						else
							message.channel:sendMessage({embed=embed(nil,'The role does not exist!',Resources.Colors.Red)})
						end
					end
					asd=false
				elseif args[2]:lower()=='rem'and rank>2 then
					if not publicroles[args[3]:lower()]then
						message.channel:sendMessage({embed=embed(nil,'This role is not on the public list!',Resources.Colors.Red)})
					else
						Database:Update('Roles',message.guild,args[3],nil)
					end
					asd=false
				elseif args[2]:lower()=='get'then
					if publicroles[args[3]:lower()]then
						local r=guild:getRole('name',publicroles[args[3]:lower()].name)
						if r then
							mem:addRole(r)
						else
							message.channel:sendMessage({embed=embed(nil,'The role does not exist!',Resources.Colors.Red)})
						end
					else
						message.channel:sendMessage({embed=embed(nil,'This role is not on the public list!',Resources.Colors.Red)})
					end
					asd=false
				elseif args[2]:lower()=='take'then
					if publicroles[args[3]:lower()]then
						local r=guild:getRole('name',publicroles[args[3]:lower()].name)
						if mem:getRole(r.id)then
							if r then
								mem:removeRole(r)
							else
								message.channel:sendMessage({embed=embed(nil,'The role does not exist!',Resources.Colors.Red)})
							end
						else
							message.channel:sendMessage({embed=embed(nil,'The role does not exist!',Resources.Colors.Red)})
						end
					else
						message.channel:sendMessage({embed=embed(nil,'This role is not on the public list!',Resources.Colors.Red)})
					end
					asd=false
				end
			end
		end
	elseif args[1]:lower()=='give'and rank>0 then
		local mentioned=message:mentionedUsers()
		local member=mentioned:getMembership(message.guild)
		local Role=getRole(message)
		local ToTake=message.guild:getRole('name',args[2])
		if ToTake then
			if Role.position>ToTake.position then
				member:addRole(ToTake)
			end
		end
		asd=false
	elseif args[1]:lower()=='take'and rank>0 then
		local mentioned=message:mentionedUsers()
		local member=mentioned:getMembership(message.guild)
		local Role=getRole(message)
		local ToTake=message.guild:getRole('name',args[2])
		if ToTake then
			if Role.position>ToTake.position then
				member:removeRole(ToTake)
			end
		end
		asd=false
	end
	if asd==true then
		if frontal==false then
			local t=[[To see the list of public roles say role%spublic%slist.
			To get a public role, say role%spublic%sget%s|role| (caps don't matter.)
			To take a public role from yourself, say role%spublic%stake%s|role| (caps don't matter.)
			To remove a role from the public roles, say role%spublic%sadd%s|role|
			To add a role to the public roles, say role%spublic%sadd%s|role|
			To give a role, say role%sgive%s|mentioned person|%s|role|
			To take a role, say role%stake%s|mentioned person|%s|role|]]
			message.channel:sendMessage({embed=embed('**Role Manager Help**',t:format(b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b,b),Resources.Colors.Bright_Blue)})
		else
			local t=[[To see the list of public roles say %srole public list.
			To get a public role, say %srole public get |role| (caps don't matter.)
			To take a public role from yourself, say %srole public take |role| (caps don't matter.)
			To remove a role from the public roles, say %srole public add |role|
			To add a role to the public roles, say %srole public add |role|
			To give a role, say %srole give |mentioned person| |role|
			To take a role, say %srole take |mentioned person| |role|]]
			message.channel:sendMessage({embed=embed('**Role Manager Help**',t:format(b,b,b,b,b,b,b),Resources.Colors.Bright_Blue)})
		end
	end
end,true)
AddCommand('Purge','Purges <number> of messages',{'purge','bulkdelete','bulkdel'},1,function(args,message)
	local n=tonumber(args[1])or 50
	message.channel:bulkDelete(n)
	message:reply({embed=embed(nil,"Purged "..tostring(n).." messages!",Resources.Colors.Yellow)})
end)
AddCommand('Kick','Kicks a user','kick',1,function(args,message)
	local member=message.member
	local userrank=getRank(message)
	local guildSettings=Database:Get('Settings',message.guild)
	if message:mentionedUsers()then
		local user=message:mentionedUsers()
		local mem=user:getMembership(message.guild)
		if userrank>getRank({member=mem,guild=message.guild})then
			local function moot()
				if getPermissions({member=getBotMember(message.guild),channel=message.channel},'kickMembers')then
					local boo=mem:kick()
					if boo==true then
						message.channel:sendMessage({embed={description="I have kicked "..mem.username..".",color=Resources.Colors.Yellow}})
					else
						message.channel:sendMessage({embed={description="I lack the permissions to do that.",color=Resources.Colors.Yellow}})
					end
					return boo
				else
					message.channel:sendMessage({embed={description="I lack the Kick Members permission required to do that.",color=Resources.Colors.Yellow}})
				end
			end
			if convertTextToBoolean(guildSettings.Case_System)then
				if moot()==true then
					local casename='Case: '..getTableNumber(Database:Get('Cases',message.guild))
					local MSG=message.channel:sendMessage({embed={description="Please state the reason for kicking.",color=Resources.Colors.Yellow}})
					Case_EDITS[message.member.name]={Name=casename,Channel=message.channel,toDelete=MSG,Time=tostring(timeStamp()),Moderator=member.username..'#'..member.discriminator,Against=mem.username..'#'..mem.discriminator,AgainstId=mem.id,ModeratorId=member.id,Reason='',Case='Kick'}
				end
			else
				moot()
			end
		else
			message.channel:sendMessage({embed={description="You cannot kick someone with your rank or higher!",color=Resources.Colors.Red}})
		end
	else
		message.channel:sendMessage({embed={description="You must mention the user you wish to kick.",color=Resources.Colors.Red}})
	end
end)
AddCommand('Mute','Mutes a player.','mute',1,function(args,message)
	local member=message.member
	local userrank=getRank(message)
	local guildSettings=Database:Get('Settings',message.guild)
	if message:mentionedUsers()then
		local user=message:mentionedUsers()
		local mem=user:getMembership(message.guild)
		if userrank>getRank({member=mem,guild=message.guild})then
			local function moot()
				local boo=Mute(mem)
				if boo==true then
					message.channel:sendMessage({embed={description="I have muted "..mem.username..".",color=Resources.Colors.Yellow}})
				elseif type(boo)=='string'then
					message.channel:sendMessage({embed=embed(nil,boo,Resources.Colors.Red)})
					boo=false
				else
					message.channel:sendMessage({embed={description="I lack the permissions to do that.",color=Resources.Colors.Red}})
				end
				return boo
			end
			if convertTextToBoolean(guildSettings.Case_System)then
				if moot()==true then
					local casename='Case: '..getTableNumber(Database:Get('Cases',message.guild))
					local MSG=message.channel:sendMessage({embed={description="Please state the reason for muting.",color=Resources.Colors.Yellow}})
					Case_EDITS[message.member.name]={Name=casename,Channel=message.channel,toDelete=MSG,Time=tostring(timeStamp()),Moderator=member.username..'#'..member.discriminator,Against=mem.username..'#'..mem.discriminator,AgainstId=mem.id,ModeratorId=member.id,Reason='',Case='Mute'}
				end
			else
				moot()
			end
		else
			message.channel:sendMessage({embed={description="You cannot mute someone with your rank or higher!",color=Resources.Colors.Red}})
		end
	else
		message.channel:sendMessage({embed={description="You must mention the user you wish to mute.",color=Resources.Colors.Red}})
	end
end)
AddCommand('Unmute','Unmutes a player.','unmute',1,function(args,message)
	local member=message.member
	local userrank=getRank(message)
	local guildSettings=Database:Get('Settings',message.guild)
	if message:mentionedUsers() then
		local user=message:mentionedUsers()
		local mem=user:getMembership(message.guild)
		local function unmoot()
			local boo=Unmute(mem)
			if boo==true then
				message.channel:sendMessage({embed={description="I have unmuted "..mem.username..".",color=Resources.Colors.Yellow}})
			elseif type(boo)=='string'then
				message.channel:sendMessage({embed=embed(nil,boo,Resources.Colors.Red)})
				boo=false
			else
				message.channel:sendMessage({embed={description="I lack the permissions to do that.",color=Resources.Colors.Yellow}})
			end
			return boo
		end
		if convertTextToBoolean(guildSettings.Case_System)then
			if unmoot()==true then
				local casename='Case: '..getTableNumber(Database:Get('Cases',message.guild))
				local MSG=message.channel:sendMessage({embed={description="Please state the reason for unmuting.",color=Resources.Colors.Yellow}})
				Case_EDITS[message.member.name]={Name=casename,Channel=message.channel,toDelete=MSG,Time=tostring(timeStamp()),Moderator=member.username..'#'..member.discriminator,Against=mem.username..'#'..mem.discriminator,AgainstId=mem.id,ModeratorId=member.id,Reason='',Case='Unmute'}
			end
		else
			unmoot()
		end
	else
		message.channel:sendMessage({embed={description="You must mention the user you wish to unmute.",color=Resources.Colors.Red}})
	end
end)
AddCommand('Say','Says <message>','say',2,function(args,message)
	local m=args[1]
	message.channel:sendMessage(tostring(m))
end)
AddCommand('Say embed','Says <message> with an embed','saye',2,function(args,message)
	local m=args[1]
	message.channel:sendMessage({embed={description=tostring(m),color=Resources.Colors.Yellow}})
end)
AddCommand('Ban Manager','Manages ban','ban',2,function(args,message,b,frontal)
	local guildSettings=Database:Get('Settings',message.guild)
	local bans=Database:Get('Bans',message.guild)
	local toban=message:mentionedUsers()
	local member=message.member
	if not bans then message.channel:sendMessage({embed={description="Loading bans.",color=Resources.Colors.Red}})return end
	if args[1]:lower()=='list'then
		local t=''
		for id,name in pairs(bans)do
			t=t..tostring(name)..': '..tostring(id)..'\n'
		end
		message.channel:sendMessage({embed={title='Bans',description=t,color=Resources.Colors.Yellow}})
	elseif args[1]:lower()=='clear'then
		if getRank(message)>=3 then
			bandb:set(guild.id,tab,function(er,re)
				if er then
					message.channel:sendMessage({embed={description="Error: "..tostring(er),color=Resources.Colors.Red}})
				end
			end)
			message.channel:sendMessage({embed={description="Reset ban database.",color=Resources.Colors.Yellow}})
		else
			if not bans then message.channel:sendMessage({embed={description="Your rank is not sufficient to reset bans.",color=Resources.Colors.Red}})return end
		end
	else
		if args[1]:lower()=='add'then
			local mem=toban:getMembership(message.guild)
			if mem then
				local function ban()
					if getPermissions({member=getBotMember(message.guild),channel=message.channel},'kickMembers')then
						Database:Update('Bans',message.guild,message,toban.id,toban.name..'#'..toban.discriminator)
						message.channel:sendMessage({embed={description="I have banned "..mem.username..'#'..mem.discriminator,color=Resources.Colors.Yellow}})
						return mem:kick()
					else
						return false
					end
				end
				if convertTextToBoolean(guildSettings.Case_System)then
					if ban()==true then
						local casename='Case: '..getTableNumber(Database:Get('Cases',message.guild))
						local MSG=message.channel:sendMessage({embed={description="Please state the reason for banning.",color=Resources.Colors.Yellow}})
						Case_EDITS[message.member.name]={Name=casename,Channel=message.channel,toDelete=MSG,Time=tostring(timeStamp()),Moderator=member.username..'#'..member.discriminator,Against=mem.username..'#'..mem.discriminator,AgainstId=mem.id,ModeratorId=member.id,Reason='',Case='Ban'}
					else
						message:reply({embed=embed(nil,"I lack the Kick Members permission.",Resources.Colors.Yellow)})
					end
				else
					if ban()==true then
						--shrug
					else
						message:reply({embed=embed(nil,"I lack the Kick Members permission.",Resources.Colors.Yellow)})
					end
				end
			else
				if not bans then message.channel:sendMessage({embed={description="Person not found.",color=Resources.Colors.Red}})return end
			end
		elseif args[1]:lower()=='rem'then
			local theid,daname
			local function unban()
				for id,name in pairs(bans)do
					local thename,discriminator=Split(name,'#')
					if thename then
						if thename:lower()==args[2]:lower()then
							Database:Update('Bans',message.guild,message,id,nil)
							message.channel:sendMessage({embed={description="I have unbanned "..name,color=Resources.Colors.Yellow}})
							theid=id
							daname=name
							return true
						end
					end
				end
				message.channel:sendMessage({embed={description="Person not found.",color=Resources.Colors.Red}})
			end
			if convertTextToBoolean(guildSettings.Case_System)then
				if unban()==true then
					local casename='Case: '..getTableNumber(Database:Get('Cases',message.guild))
					local MSG=message.channel:sendMessage({embed={description="Please state the reason for unbanning.",color=Resources.Colors.Yellow}})
					Case_EDITS[message.member.name]={Name=casename,Channel=message.channel,toDelete=MSG,Time=tostring(timeStamp()),Moderator=member.username..'#'..member.discriminator,Against=daname,AgainstId=theid,ModeratorId=member.id,Reason='',Case='Unban'}
				end
			else
				unban()
			end
		else
			if frontal==false then
				message.channel:sendMessage({embed={title='Ban',description=([[
					Say ban%slist for a list of bans.
					Say ban%sreset to reset the bans.
					Say ban%sadd%s @user to add them to the bans.
					Say ban%srem%s username to remove them from bans.
				]]):format(b,b,b,b,b,b),color=Resources.Colors.Yellow}})
			else
				message.channel:sendMessage({embed={title='Ban',description=([[
					Say %sban list for a list of bans.
					Say %sban reset to reset the bans.
					Say %sban add @user to add them to the bans.
					Say %sban rem username to remove them from bans.
				]]):format(b,b,b,b),color=Resources.Colors.Yellow}})
			end
		end
	end
end,true)
AddCommand('Ignore','Ignores commands in the channel spoken in.','ignore',3,function(args,message)
	Database:Update('Ignore',message.guild,message.channel.name,'true')
	message.channel:sendMessage({embed={description="Commands will be ignored in this channel.",color=Resources.Colors.Yellow}})
end)
AddCommand('Unignore','Unignores commands in the channel spoken in.','unignore',3,function(args,message)
	Database:Update('Ignore',message.guild,message.channel.name,'false')
	message.channel:sendMessage({embed={description="Commands will no longer be ignored in this channel.",color=Resources.Colors.Yellow}})
end)
AddCommand('Settings','Sets settings','settings',3,function(args,message,b,frontal)
	local settings=Database:Get('Settings',message.guild)
	if not settings then message.channel:sendMessage({embed={description="Loading settings.",color=Resources.Colors.Red}})return end
	if #args[1]==0 or args[1]:lower()=='help'then
		local txt=''
		if not frontal then
			txt=[[settings]]..b..[[list - Gets a list of settings.
			settings]]..b..[[{setting}]]..b..[[value - Sets the setting to <value>. The setting is case sensitive!
			settings]]..b..[[reset - Resets all settings. [CANNOT BE UNDONE.]
			settings]]..b..[[desc]]..b..[[{setting} - Grabs a description for the setting.]]
		else
			txt=b..[[settings list - Gets a list of settings.
			]]..b..[[settings {setting} value - Sets the setting to <value>. The setting is case sensitive!
			]]..b..[[settings reset - Resets all settings. [CANNOT BE UNDONE.]
			]]..b..[[settings desc {setting} - Grabs a description for the setting.]]
		end
		message.channel:sendMessage({embed={description=tostring(txt),color=Resources.Colors.Yellow}})
	else
		if args[1]:lower()=='list'then
			local txt=''
			for setting,value in pairs(settings)do
				txt=txt..tostring(setting)..':\t'..tostring(value)..'\n'
			end
			message.channel:sendMessage({embed={description=tostring(txt),color=Resources.Colors.Yellow}})
		elseif args[1]:lower()=='reset'then
			local tab={}
			for name,val in pairs(Resources.Default_Guild_Settings)do
				Database.Cache['Settings'][message.guild.id][name]=val
			end
			Database:Update('Settings',message.guild)
			message.channel:sendMessage({embed={description="All settings reset!",color=Resources.Colors.Yellow}})
		else
			if args[2]then
				if args[1]:lower()=='desc'then
					if settings[args[2]]==nil then message.channel:sendMessage({embed={description="No setting found! ("..args[2]..")",color=Resources.Colors.Red}})return end
					local txt=''
					local t=Resources.Setting_Descriptions[args[2]]
					if t then
						txt=tostring(t)
					else
						txt='No information found.'
					end
					message.channel:sendMessage({embed={description=args[2]..":\t"..txt,color=Resources.Colors.Yellow}})
					return
				elseif settings[tostring(args[1])]~=nil then
					Database:Update('Settings',message.guild,args[1],args[2])
					message.channel:sendMessage({embed={description=args[1].." set to:\t"..args[2],color=Resources.Colors.Yellow}})
					return
				else
					message.channel:sendMessage({embed={description="No setting found! ("..args[1]..")",color=Resources.Colors.Red}})
				end
			end
		end
	end
end,true)
AddCommand('Global Message','Sends a global message to all guild owners.','globaldm',4,function(args,message)
	local guilds=getAllGuilds()
	for i,guild in pairs(guilds)do
		guild.owner:sendMessage({embed={description="Message from the bot's creator!\n"..tostring(args[1]),color=Resources.Colors.Yellow}})
	end
end)
AddCommand('Load','Loads <string>','load',4,function(args,message)
	if #args[1]<1 then return message:reply({embed=embed(nil,"ERROR: Nothing to load.",Resources.Colors.Red)})end
	local tx=''
	local orig=print
	local function fprint(...)
		local txt=''
		for i,v in pairs({...})do
			txt=txt..tostring(v)..'\t'
		end
		txt=txt:gsub(Token,'<Hidden for security>')
		orig(txt)
		tx=tx..'\n'..txt
	end
	local function tprint(tab)
		local txt=''
		for i,v in pairs(tab)do
			txt=txt..tostring(i)..' | '..tostring(v)..'\n'
		end
		txt=txt:gsub(Token,'<Hidden for security>')
		orig(txt)
		tx=tx..'\n'..txt
	end
	args[1]=args[1]:gsub('```Lua','')
	args[1]=args[1]:gsub('```','')
	local a,b=loadstring(args[1])
	if not a then
		fprint("[BP] ERROR: "..b)
	else
		local env=setmetatable({
			print=fprint,
			tprint=tprint,
			oprint=orig,
			Client=client,
			Discordia=discordia,
			Channel=message.channel,
			Message=message,
			Guild=message.guild,
			client=client,
			discordia=discordia,
			channel=message.channel,
			message=message,
			guild=message.guild,
			Http=http,
			Timer=timer,
			JSON=json,
			Bot=Bot,
			getRank=getRank,
			encrypt=encrypt,
			env=getfenv(0),
		},{__index=function(self,key)
			if rawget(self,key)then
				return rawget(self,key)
			elseif getfenv(1)[key]then
				return getfenv(1)[key]
			end
		end})
		setfenv(a,env)
		local c,d=pcall(a)
		if not c then
			fprint("[AP] ERROR: "..d)
		end
	end
	if #tx==0 then tx="No output"end
	message:reply("**Output** ```Lua\n"..tx..'```')
end)
--[==[AddCommand('Stop','Stops '..Bot.Name,'stop',4,function(args,message)
	if args[1]:sub(1,2)=='-r'then
		message.channel:sendMessage({embed={description='Restarting...',color=Resources.Colors.Yellow}})
		--os.execute((beta==true and[[start T:\Lua\startb.bat]]or[[start C:\Users\Administrator\Desktop\DiscordBots\dangerspookycanyon\Electricity\startbot.bat]]))
		os.execute('exit')
		os.execute('cls')
		os.exit()
	else
		os.execute('exit')
		os.execute('cls')
		os.exit()
	end
end)]==]
AddCommand('Get bot dump','Gets the bot\'s dump file. Don\'t worry about it.','bdump',4,function(args,message)
	message:reply({file='bot.log'})
end)
local ignore={'400 / BAD REQUEST / nil','Cannot send messages to this user','Missing Permissions',}
client:on('warning',function(...)
	local ignored=false
	local tx=tostring(...)
	for i,v in pairs(ignore)do
		if tx:find(v)then
			ignored=true
		end
	end
	if ignored==true then
		--print(tx)
	else
		pcall(function()sendLog('Warnings',nil,'```'..tx..'```',Resources.Colors.Red)end)
		print(tx)
	end
end)
client:on('error',function(...)
	local ignored=false
	local tx=tostring(...)
	for i,v in pairs(ignore)do
		if tx:find(v)then
			ignored=true
		end
	end
	if ignored==true then
		--print(tx)
	else
		pcall(function()sendLog('Errors',nil,'```'..tx..'```',Resources.Colors.Red)end)
		print(tx)
	end
end)
client:on('ready', function()
    print('Logged in as '.. client.user.username)
	client:setGameName(Bot.Settings.Start_Game)
	start=os.date("%I:%M:%S %p on %a, %b %d")
	os.execute('title '..Bot.Name)
	for i,v in pairs(getAllGuilds())do
		setupGuild(v)
	end
	pcall(function()sendLog('Ready',nil,("ONLINE ("..timeStamp()..")"),Resources.Colors.Green)end)--pcall(function()client:getGuild(Resources.IDs.Test_Server_ID):getChannel(Resources.IDs.Ready_Channel_ID):sendMessage({embed=embed(nil,("ONLINE ("..timeStamp()..")"),Resources.Colors.Yellow)})end)
end)
client:on('channelCreate',function(channel)
	Database:Update('Ignore',channel.guild,channel.name,false)
end)
client:on('channelDelete',function(channel)
	Database:Update('Ignore',channel.guild,channel.name,nil)
end)
client:on('memberLeave',function(member)
	if not member then return end
	local settings=Database:Get('Settings',member.guild)
	if settings then
		if convertTextToBoolean(settings.Join_Log)==true then
			local chan=member.guild:getChannel("name",settings.Join_Log_Channel)
			if chan then
				chan:sendMessage({embed=embed(nil,(member.username..'#'..member.discriminator.." has left."),Resources.Colors.Yellow)})
			end
		end
	end
end)
client:on('memberJoin',function(member)
	if not member then return end
	checkForBans({member=member,guild=member.guild})
	local settings=Database:Get('Settings',member.guild)
	if settings then
		if convertTextToBoolean(settings.Join_Log)==true then
			local chan=member.guild:getChannel("name",settings.Join_Log_Channel)
			if chan then
				local tx=settings.Join_Message:gsub('//mention',member.mentionString)
				chan:sendMessage(tx)
			end
		end
	end
end)
client:on('guildCreate',function(guild)
	guild.owner:sendMessage({embed=embed(nil,"If you haven't already, please grant embed-link permissions to Electricity in "..guild.name..".\nOtherwise, 99% of the bot shall break.\nThank you for choosing Electricity!",Resources.Colors.Yellow)})
	setupGuild(guild)
end)
client:on('messageUpdate',function(message)
	if message.channel.isPrivate==true then return end
	if not message.member then return end
	local guildsettings=Database:Get('Settings',message.guild)
	local rank=getRank(message)
	if guildsettings then
		if convertTextToBoolean(guildsettings.Anti_Link)==true then
			if getRank(message)<3 then
				if message.content:find'https://discordapp.com/api/oauth2/'then
					if message:delete()then
						message.channel:sendMessage({embed={description='Bot invite links are not allowed here!',color=Resources.Colors.Red}})
					end
				elseif message.content:find'discord.gg/'then
					if message:delete()then
						message.channel:sendMessage({embed={description='Guild invite links are not allowed here!',color=Resources.Colors.Red}})
					end
				end
			end
		end
		if convertTextToBoolean(guildsettings.Anti_Owner_Mention)==true then
			if getRank(message)<1 then
				local mention=message:mentionedUsers()
				if mention then
					if mention.id==message.guild.owner.id then
						if message:delete()then
							message.channel:sendMessage({embed={description='The server owner would like to not be mentioned. If you need assistance, please contact the staff.',color=Resources.Colors.Red}})
						end
					end
				end
			end
		end
	end
end)
client:on('messageCreate',function(message)
	local a,b=pcall(function()
		if message.channel.isPrivate==true then
			message.author:sendMessage({embed=embed(nil,"I do not operate in DMs. Feel free to invite me to a server!\nAdministrative link:\n"..Resources.OAuthA:format(Bot.ClientID).."\nNon-Administrative link:\n"..Resources.OAuth:format(Bot.ClientID),Resources.Colors.Yellow)})
			return
		end
		local guildsettings,guildignore
		local yxz,zxy=pcall(function()
			guildsettings=Database:Get('Settings',message.guild)--getGuildSettings(message)
			guildignore=Database:Get('Ignore',message.guild)--getGuildIgnore(message)
		end)
		if not yxz then
			message.channel:sendMessage({embed={description='Error grabbing guild settings! Error: '..zxy,color=Resources.Colors.Red}})
		end
		local member=message.member
		if not member then return end
		local isabot=member.bot
		local botmember=client.user:getMembership(message.guild)
		if checkForBans(message)then return end
		if isabot then
			if member.id~=botmember.id then
				return
			end
		end
		local rank=getRank(message)
		if guildsettings then
			if convertTextToBoolean(guildsettings.Anti_Link)==true then
				if getRank(message)<3 then
					if message.content:find'https://discordapp.com/api/oauth2/'then
						if message:delete()then
							message.channel:sendMessage({embed={description='Bot invite links are not allowed here!',color=Resources.Colors.Red}})
						end
					elseif message.content:find'discord.gg/'then
						if message:delete()then
							message.channel:sendMessage({embed={description='Guild invite links are not allowed here!',color=Resources.Colors.Red}})
						end
					end
				end
			end
			if convertTextToBoolean(guildsettings.Anti_Owner_Mention)==true then
				if getRank(message)<1 then
					local mention=message:mentionedUsers()
					if mention then
						if mention.id==message.guild.owner.id then
							if message:delete()then
								message.channel:sendMessage({embed={description='The server owner would like to not be mentioned. If you need assistance, please contact the staff.',color=Resources.Colors.Red}})
							end
						end
					end
				end
			end
		end
		if guildignore then
			if guildignore[message.channel.name]then
				if convertTextToBoolean(guildignore[message.channel.name])==true then
					if message.content:lower():sub(1,8)=='unignore'then
						--just continues
					else
						return
					end
				end
			end
		end
		for user in message.mentionedUsers do
			if user.id==botmember.id then
				message:reply({embed=embed(nil,"The bet for this server is: '"..(beta==true and Bot.Settings.Bet or guildsettings and guildsettings.Bet~=nil and guildsettings.Bet or Bot.Settings.Bet).."'",Resources.Colors.Yellow)})
			end
		end
		if Case_EDITS[member.name]then
			local tab=Case_EDITS[member.name]
			Case_EDITS[member.name]=nil
			tab.Channel:sendMessage({embed={description="Reason added to "..tab.Name..".",color=Resources.Colors.Yellow}})
			tab.Reason=message.content
			tab.toDelete:delete()
			Database:Update('Cases',message.guild,tab.Name,{Time=tab.Time,Moderator=tab.Moderator,Against=tab.Against,AgainstId=tab.AgainstId,ModeratorId=tab.ModeratorId,Reason=tab.Reason,Case=tab.Case})
			if guildsettings then
				local logchannel=message.guild:getChannel('name',guildsettings.Case_Channel)
				if logchannel then
					logchannel:sendMessage({embed={title=tab.Name,fields={
						{name='Action:',value=tab.Case},
						{name='Staff who issued:',value=tab.Moderator},
						{name='Staff ID:',value=tab.ModeratorId},
						{name='Against:',value=tab.Against},
						{name='Against ID:',value=tab.AgainstId},
						{name='Reason:',value=tab.Reason},
						{name='Timestamp:',value=tab.Time},
					},color=Resources.Colors.Yellow}})
				end
			end
			message:delete()
		end
		for Name,Table in pairs(Commands)do
			for ind,cmd in pairs(Table.Cmds)do
				local bet=(beta==true and Bot.Settings.Bet or guildsettings and guildsettings.Bet~=nil and guildsettings.Bet or Bot.Settings.Bet)
				local aft=(guildsettings and guildsettings.Before_After:lower()=='before'or false)
				if aft==false then
					if message.content:sub(1,#cmd+#bet):lower()==cmd..bet:lower()then
						local args=(Table.Multi==true and string.split(message.content:sub(#bet+#cmd),bet)or{'',message.content:sub(#bet+#cmd+1)})
						table.remove(args,1)
						if #args==0 then table.insert(args,'')end
						if rank>=Table.Rank then
							local a,b=pcall(Table.Func,args,message,bet,false)
							if not a then
								message.channel:sendMessage({embed={description=("ERROR: "..b),color=Resources.Colors.Red}})
							end
						else
							message.channel:sendMessage({embed={description=("Your rank is not sufficient to use this command. [%s/%s]"):format(rank,Table.Rank),color=Resources.Colors.Red}})
						end
						local title=(member.name~=member.username and member.username.." ("..member.name..")"or member.name)..'#'..member.discriminator
						local fields={ 
							{name="Name:",value=title}, 
							{name="Id:",value=member.id}, 
							{name="Guild info:",value="\n**Guild name:** "..message.guild.name.."\n**Guild id:** "..message.guild.id,inline=true},
							{name="Channel info:",value="\n**Channel name:** "..message.channel.name.."\n**Channel id:** "..message.channel.id,inline=true},
							{name="Full content:",value=message.content},
							{name="Shard:",value=message.guild.shardId,inline=true},
							{name="Timestamp:",value=timeStamp(),inline=true},
						}
						local em={
							embed={
								fields={ 
									{name="Name:",value=title}, 
									{name="Id:",value=member.id}, 
									{name="Guild info:",value="\n**Guild name:** "..message.guild.name.."\n**Guild id:** "..message.guild.id,inline=true},
									{name="Channel info:",value="\n**Channel name:** "..message.channel.name.."\n**Channel id:** "..message.channel.id,inline=true},
									{name="Full content:",value=message.content},
									{name="Shard:",value=message.guild.shardId,inline=true},
									{name="Timestamp:",value=timeStamp(),inline=true},
								},
								color=Resources.Colors.Bright_Blue
							}
						}
						pcall(function()sendLog('Audit',nil,FieldsToText(fields),Resources.Colors.Green)end)--client:getGuild(Resources.IDs.Test_Server_ID):getChannel(Audit_Log_ID):sendMessage(em)
						if guildsettings then
							if convertTextToBoolean(guildsettings.Audit_Log)==true then
								local chan=message.guild:getChannel("name",guildsettings.Audit_Log_Channel)
								if chan then
									table.remove(em.embed.fields,3)
									chan:sendMessage(em)
								end
							end
						end
					end
				else
					if message.content:sub(1,#bet+#cmd):lower()==bet..cmd:lower()then
						local args=(Table.Multi==true and string.split(message.content:sub(#bet+#cmd),' ')or{'',message.content:sub(#bet+#cmd+2)})
						table.remove(args,1)
						if #args==0 then table.insert(args,'')end
						if rank>=Table.Rank then
							local a,b=pcall(Table.Func,args,message,bet,true)
							if not a then
								message.channel:sendMessage({embed={description=("ERROR: "..b),color=Resources.Colors.Red}})
							end
						else
							message.channel:sendMessage({embed={description=("Your rank is not sufficient to use this command. [%s/%s]"):format(rank,Table.Rank),color=Resources.Colors.Red}})
						end
						local title=(member.name~=member.username and member.username.." ("..member.name..")"or member.name)..'#'..member.discriminator
						local fields={ 
							{name="Name:",value=title}, 
							{name="Id:",value=member.id}, 
							{name="Guild info:",value="\n**Guild name:** "..message.guild.name.."\n**Guild id:** "..message.guild.id,inline=true},
							{name="Channel info:",value="\n**Channel name:** "..message.channel.name.."\n**Channel id:** "..message.channel.id,inline=true},
							{name="Full content:",value=message.content},
							{name="Shard:",value=message.guild.shardId,inline=true},
							{name="Timestamp:",value=timeStamp(),inline=true},
						}
						local em={
							embed={
								fields={ 
									{name="Name:",value=title}, 
									{name="Id:",value=member.id}, 
									{name="Guild info:",value="\n**Guild name:** "..message.guild.name.."\n**Guild id:** "..message.guild.id,inline=true},
									{name="Channel info:",value="\n**Channel name:** "..message.channel.name.."\n**Channel id:** "..message.channel.id,inline=true},
									{name="Full content:",value=message.content},
									{name="Shard:",value=message.guild.shardId,inline=true},
									{name="Timestamp:",value=timeStamp(),inline=true},
								},
								color=Resources.Colors.Bright_Blue
							}
						}
						pcall(function()sendLog('Audit',nil,FieldsToText(fields),Resources.Colors.Green)end)--client:getGuild(Resources.IDs.Test_Server_ID):getChannel(Audit_Log_ID):sendMessage(em)
						if guildsettings then
							if convertTextToBoolean(guildsettings.Audit_Log)==true then
								local chan=message.guild:getChannel("name",guildsettings.Audit_Log_Channel)
								if chan then
									table.remove(em.embed.fields,3)
									chan:sendMessage(em)
								end
							end
						end
					end
				end
			end
		end
	end)
	if not a then
		pcall(function()client:getGuild(Resources.IDs.Test_Server_ID):getChannel(Resources.IDs.Error_Channel):sendMessage('```'..tx..'```')end)
		print(tx)
	end
end)
client:run(Token)