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
	local file=getCatFile()
	sendMessage(message,{file=file})
end)
addCommand('Commands','Grabs the list of commands.',{'cmds','commands'},0,false,false,false,function(message,args)
	sendMessage(message,"The commands list has been moved to a webpage!\n\n`https://github.com/DannehSC/Electricity-2.0/wiki/Commands`")
end)
addCommand('Urban','Urban dictionary','urban',0,false,false,true,function(message,args,switches)
	local d
	if switches['d']~=nil and tonumber(switches['d'])then
		d=tonumber(switches['d'])
	end
	local data=urban(args[1],d)
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
	if not getPermissions(bm,'kickMembers')then error"Lack of permissions, kickMembers required."end
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
	local c,d=pcall(coroutine.wrap(a))
	if not c then
		return sendMessage(message,"[R] Error! - "..tostring(b))
	end
	if #tx==0 then tx='No output'end
	sendMessage(message,string.format('```%s```',tostring(tx)))
end)