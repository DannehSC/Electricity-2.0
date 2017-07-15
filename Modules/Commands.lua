--COMMANDS.LUA--
local verification_codes={}
Commands={}
function addCommand(name,desc,cmds,rank,multi_arg,server_only,switches,func)
	local b,e,n,g=checkArgs({'string','string',{'table','string'},'number','boolean','boolean','boolean','function'},{name,desc,cmds,rank,multi_arg,server_only,switches,func})
	--bool,expected,number,got
	if not b then
		error(string.format("Invalid argument #%s to addCommand, %s expected, got %s.",n,e,g))
	end
	Commands[name]={Name=name,Description=desc,Commands=(type(cmds)=='table'and cmds or{cmds}),Rank=rank,Multi=multi_arg,serverOnly=server_only,Switches=switches,Function=func}
end
addCommand('Ping','Pings the bot.','ping',0,false,false,false,function(message,args)
	sendMessage(message,"Pong!")
end)
addCommand('Beep','Beeps the bot.','beep',0,false,false,false,function(message,args)
	sendMessage(message,"Boop!")
end)
addCommand('Cat picture','Gets a cat picture',{'cat','kitty','cpic'},0,false,false,false,function(message,args)
	local file=API.Misc:Cats()
	sendMessage(message,{file=file})
end)
addCommand('Commands','Grabs the list of commands.',{'cmds','commands'},0,false,false,false,function(message,args)
	sendMessage(message,"The commands list has been moved to a webpage!\n<https://github.com/DannehSC/Electricity-2.0/wiki/Commands>")
end)
addCommand('Urban','Urban dictionary','urban',0,false,false,true,function(message,args,switches)
	local d
	if switches['d']~=nil and tonumber(switches['d'])then
		d=tonumber(switches['d'])
	end
	local data=API.Misc:Urban(args[1],d)
	sendMessage(message,data)
end)
addCommand('Verify','Verifies yourself','verify',0,false,true,false,function(message,args)
	local guild=message.guild
	local settings=Database:Get('Settings',guild)
	local chan=guild:getChannel('name',settings.verify_chan)
	if not convertToBool(settings.verify)then
		sendMessage(message,"Verify system: Not enabled")
		return
	end
	if chan then
		if message.channel.id~=chan.id then return end
		local role=guild:getRole('name',settings.verify_role)
		if role then
			if #args[1]==0 then
				sendMessage(message,"Sending verification code.")
				local a,code,stuff=math.random(1,2),enclib.Randomizer(100)
				verification_codes[code]=true
				code='```'..code..'```'
				if a==1 then
					stuff=embed("Code",code)
				else
					stuff=embed(nil,nil,nil,{
						{name="Code",value=code},
					})
				end
				sendMessage(message.author,stuff,true)
			else
				if verification_codes[args[1]]then
					sendMessage(message,"Verify system: Code confirmed.")
					message.member:addRole(role)
					verification_codes[args[1]]=nil
				else
					sendMessage(message,"Verify system: Invalid code")
				end
			end
		else
			sendMessage(message,"Verify system: Role not found")
		end
	end
end)
addCommand('Kick','Kicks a member.',{'kick','deport'},1,false,true,true,function(message,args,switches)
	local bm,n=getBotMember(message.guild)
	if switches['d']then
		if tonumber(switches['d'])then
			n=tonumber(switches['d'])
			if n>7 then
				n=7
			end
			if n<1 then
				n=1
			end
		end
	end
	if not getPermissions(bm,'kickMembers')then return sendMessage(message,"Lack of permissions, kickMembers required.")end
	local u,bpos=message:mentionedUsers(),getHighestRole(bm)
	if u then
		local member=u:getMembership(message.guild)
		print(getRank(member),getRank(message.member))
		if getRank(member)<getRank(message.member)then
			if bpos>getHighestRole(member)then
				local this=member:kick(n)
				if not this then
					sendMessage(message,"Cannot kick member! Unknown error!")
				end
			else
				sendMessage(message,"Cannot kick member! Rank exceeds my own!")
			end
		else
			sendMessage(message,"Cannot kick member! Their rank either exceeds yours, or they are the same rank!")
		end
	else
		sendMessage(message,"Cannot kick member! Nobody mentioned!")
	end
end)
addCommand('Ban','Bans a member.',{'ban','banish','youshallnotpass'},2,false,true,true,function(message,args,switches)
	local guild=message.guild
	local bm,n=getBotMember(guild)
	if not getPermissions(bm,'banMembers')then return sendMessage(message,"Lack of permissions, banMembers required.")end
	if switches['u']then
		for user in guild.bannedUsers do
			if user.id==switches['u']then
				local this=guild:unbanUser(user)
				if not this then
					return sendMessage(message,"Cannot unban member! Unknown error!")
				end
				n=user
			end
		end
		if not n then
			sendMessage(message,"User not found. Did you use a proper ID?")
		else
			sendMessage(message,string.format("User %s#%s (%s) unbanned.",n.username,n.discriminator,n.id))
		end
		return
	elseif switches['l']then
		local tx=''
		for user in guild.bannedUsers do
			tx=tx..'Name:\n\t'..user.username..'\nDiscriminator:\n\t'..user.discriminator..'\nId:\n\t'..user.id..'\n'
		end
		if #tx==0 then
			sendMessage(message,"No users found.")
		else
			sendMessage(message,tx)
		end
		return
	end
	local u,bpos=message:mentionedUsers(),getHighestRole(bm)
	if u then
		local member=u:getMembership(message.guild)
		if getRank(member)<getRank(message.member)then
			if bpos>getHighestRole(member)then
				local this=member:ban()
				if not this then
					sendMessage(message,"Cannot ban member! Unknown error!")
				end
			else
				sendMessage(message,"Cannot ban member! Rank exceeds my own!")
			end
		else
			sendMessage(message,"Cannot ban member! Their rank either exceeds yours, or they are the same rank!")
		end
	else
		sendMessage(message,"Cannot ban member! Nobody mentioned!")
	end
end)
addCommand('Settings','Sets the settings',{'settings','set'},3,false,true,true,function(message,args,switches)
	local guild=message.guild
	local settings=Database:Get('Settings',guild)
	if switches.s then
		if settings[switches.s]then
			if type(settings[switches.s])=='table'then
				return sendMessage(message,"Setting "..switches.s.." is a list setting. Please use lset/lsettings.")
			end
			if switches.v then
				if s_pred[switches.s]then
					local data=s_pred[switches.s](switches.v,message)
					if data then
						sendMessage(message,data)
					end
				else
					Database:Update('Settings',guild,switches.s,switches.v)
				end
			elseif switches.d then
				if descriptions[switches.s]then
					sendMessage(message,string.format("Setting: %s | Description: %s",switches.s,descriptions[switches.s]))
				else
					sendMessage(message,string.format("Setting: %s | Description: %s",switches.s,"No description found." ))
				end
			else
				sendMessage(message,"Setting: "..switches.s.." | Value: "..settings[switches.s])
			end
		else
			return sendMessage(message,"No setting found: "..switches.s)
		end
	elseif switches.l then
		local this=''
		for i,v in pairs(settings)do
			this=this..i..' | '..tostring(v)..'\n'
		end
		sendMessage(message,"Settings list:\n"..this)
	else
		sendMessage(message,"How to use settings menu:\n/s <setting> /v <value>\nSets <setting> to <value>.\n/s <setting> /d\nGrabs description for setting.\n/s <setting>\nCurrent setting.\n/l\nList of settings.")
	end
end)
addCommand('List Settings','Settings for lists',{'lsettings','lset'},3,false,true,true,function(message,args,switches)
	local guild=message.guild
	local settings=Database:Get('Settings',guild)
	local fmt=string.format
	if switches.s then
		if settings[switches.s]then
			if type(settings[switches.s])~='table'then
				return sendMessage(message,"Setting "..switches.s.." is not a list setting. Please use the set/settings command.")
			end
			if switches.a then
				if s_pred[switches.s]then
					s_pred[switches.s](switches.a)
				else
					table.insert(settings[switches.s],switches.a)
					Database:Update('Settings',guild)
				end
			elseif switches.r then
				for i,v in pairs(settings[switches.s])do
					if v:lower()==switches.r:lower()then
						settings[switches.s][i]=nil
						Database:Update('Settings',guild)
						return
					end
				end
				sendMessage(message,'Not found! Value: '..switches.r)
			elseif switches.clear then
				if switches.confirm then
					sendMessage(message,fmt('Clearing %s.',settings.s))
				else
					sendMessage(message,'Use the /confirm switch to confirm this clearing.')
				end
			elseif switches.d then
				if descriptions[switches.s]then
					sendMessage(message,fmt("Setting: %s | Description: %s",switches.s,descriptions[switches.s]))
				else
					sendMessage(message,fmt("Setting: %s | Description: %s",switches.s,"No description found." ))
				end
			else
				sendMessage(message,"Setting: "..switches.s.." | Value: "..table.concat(settings[switches.s],', '))
			end
		else
			return sendMessage(message,"No setting found: "..switches.s)
		end
	else
		sendMessage(message,[[
			How to use list settings menu:
			/s <setting> /a <value>
			Adds <value> to <setting> list.
			/s <setting> /r <value>
			Removes <value> from <setting> list.
			/s <setting> /d
			Grabs description for setting list.
			/s <setting>
			Current setting values.]]
		)
	end
end)
addCommand('Load','Loads code.',{'load','eval','exec'},4,false,false,false,function(message,args)
	local tx=''
	local orig=print
	local function fprint(...)
		local txt=''
		for i,v in pairs({...})do
			txt=txt..tostring(v)..'\t'
		end
		txt=txt:gsub(token,'<Hidden for security>')
		orig(txt)
		tx=tx..'\n'..txt
	end
	local a,b=loadstring(args[1],'Electricity 2.0')
	if not a then
		return sendMessage(message,"[S] Error! - "..b)
	end
	local env=setmetatable({
		print=fprint,
		oprint=orig,
		message=message,
		guild=message.guild,
		channel=message.channel,
		member=message.member,
		hooks={},
		token='<Hidden for security>',
	},{__index=function(self,key)
		if rawget(self,key)then
			return rawget(self,key)
		elseif getfenv(1)[key]then
			return getfenv(1)[key]
		end
	end})
	env._env=env
	setfenv(a,env)
	local c,d=pcall(a)
	if not c then
		return sendMessage(message,"[R] Error! - "..tostring(d))
	end
	if #tx==0 then tx='No output'end
	sendMessage(message,string.format('```%s```',tostring(tx)))
end)