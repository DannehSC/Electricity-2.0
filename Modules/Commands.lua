--COMMANDS.LUA--
--[[
	POSSIBLE:
		Emergency staff command shut off.
		
]]
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
	sendMessage(message,embed(nil,"Pong!",colors.green),true)
end)
addCommand('Beep','Beeps the bot.','beep',0,false,false,false,function(message,args)
	sendMessage(message,embed(nil,"Boop!",colors.green),true)
end)
addCommand('Join','Sends a link to join the official Electricity guild!','join',0,false,false,false,function(message,args)
	sendMessage(message.author,embed(nil,"[Invite](https://discordapp.com/invite/KCMxtK8)",colors.yellow),true)
end)
addCommand('Join2','Sends a raw link to join the official Electricity guild!','join2',0,false,false,false,function(message,args)
	sendMessage(message.author,"https://discordapp.com/invite/KCMxtK8")
end)
addCommand('About','Reads you info about the bot.',{'about','help'},0,false,false,false,function(message,args)
	local tx=''
	local owner=client.owner
	local bet=Database:Get(message).Settings.bet
	function append(ntx,fin)
		fin=fin or false
		tx=tx..ntx..(fin==false and'\n\n'or'')
	end
	append("I am the bot known as Electricity 2.0.")
	append("I was created by %s#%d (DannehSC on Github)")
	append("To see the commands list: Please say `%scmds` or `%scommands`")
	append("To see nerd info: Please say `%sninfo`")
	append("To see uptime: Please say `%suptime`")
	append("To see the settings: Please say `%ssettings /l`")
	append("To join the support server: `%sjoin` or `%sjoin2`")
	append("If you are in a guild, you can see info about the guild. Please say `%sginfo`")
	append("Thank you for using Electricity!",true)
	sendMessage(message,embed("Info",(tx):format(owner.username,owner.discriminator,bet,bet,bet,bet,bet,bet,bet,bet),colors.bright_blue),true)
end)
addCommand('Bot Info','Fetches info about the bot!','binfo',0,false,false,false,function(message,args)
	local count=0
	for g in client.guilds:iter()do	
		count=count+g.totalMemberCount
	end
	sendMessage(message,embed("Bot info",nil,colors.yellow,{
		{name="Guild count",value=#client.guilds,inline=true},
		{name="Shard count",value=client.shardCount,inline=true},
		{name="Member count",value=count,inline=true},
	}),true)
end)
addCommand('User Info','Fetches info about a user','uinfo',0,false,true,false,function(message,args)
	local u=message.mentionedUsers:iter()()
	if not u then
		u=message.author
	end
	local m=message.guild:getMember(u)
	if not m then
		return sendMessage(message,"[ERROR] Member not found. Please contact support through the `join` cmd or `join2` cmd.")
	end
	sendMessage(message,embed("User Info",nil,colors.yellow,{
		{name="Username",value=u.username,inline=true},
		{name="Discriminator",value=u.discriminator,inline=true},
		{name="Identification",value=u.id,inline=true},
		{name="User Rank",value=getRank(m,true),inline=true},
		{name="Joined guild at",value=convertJoinedAtToTime(m.joinedAt),inline=true},
		{name="Joined discord at",value=convertJoinedAtToTime(u.timestamp),inline=true},
	}),true)
end)
addCommand('Uptime','Returns the time the bot has been loaded.','uptime',0,false,false,false,function(message,args)
	local time=uptime:getTime():toTable()
	sendMessage(message,embed(nil,string.format("Week%s: %s\nDay%s: %s\nHour%s: %s\nMinute%s: %s\nSecond%s: %s",
		time.weeks~=1 and's'or'',time.weeks,
		time.days~=1 and's'or'',time.days,
		time.hours~=1 and's'or'',time.hours,
		time.minutes~=1 and's'or'',time.minutes,
		time.seconds~=1 and's'or'',time.seconds
	),colors.blue),true)
end)
addCommand('Bot invite','Sends you the bot invite links.','botinv',0,false,false,false,function(message,args)
	sendMessage(message,embed('Links',
		"[Non administrative](https://discordapp.com/oauth2/authorize?client_id=284380758611591170&scope=bot)\n[Administrative](https://discordapp.com/oauth2/authorize?client_id=284380758611591170&scope=bot&permissions=8)",
	colors.yellow),true)
end)
addCommand('Cat picture','Gets a cat picture',{'cat','kitty','cpic'},0,false,false,false,function(message,args)
	local file,err=API.Misc:Cats()
	sendMessage(message,file or err)
end)
addCommand('Coin flip!','Flips a coin!',{'cflip','coinflip','flippy'},0,false,false,false,function(message,args)
	local f=math.random(1,2)
	sendMessage(message,embed(nil,(f==1 and"Tails"or"Heads"),colors.yellow),true)
end)
addCommand('Roll the dice','Dice!',{'rtdice','dice','roll'},0,false,false,false,function(message,args)
	local f=math.random(1,6)
	sendMessage(message,embed(nil,"You rolled a "..tostring(f),colors.yellow),true)
end)
addCommand('Dog picture','Gets a dog picture',{'dog','bork','dpic'},0,false,false,false,function(message,args)
	local file,err=API.Misc:Dogs()
	sendMessage(message,file or err)
end)
addCommand('Joke','Gets a joke',{'joke','joker','batmansparents','dadjoke'},0,false,false,false,function(message,args)
	local joke=API.Misc:Joke()
	sendMessage(message,joke)
end)
addCommand('Commands','Grabs the list of commands.',{'cmds','commands'},0,false,false,false,function(message,args)
	local cmds=splitForDiscord()
	local msg=sendMessage(message.author,'Sending commands')
	if msg then
		msg:delete()
		for i=1,#cmds do
			sendMessage(message.author,cmds[i],true)
		end
		if message.guild~=nil then
			sendMessage(message,embed('Notification','Commands sent to DMs.',colors.yellow),true)
		end
	else
		sendMessage(message,embed("Commands","__***Could not send commands via DM.***__\nThe commands list has been moved to a webpage!\n<https://github.com/DannehSC/Electricity-2.0/wiki/Commands>",colors.yellow),true)
	end
end)
addCommand('Calculate','Calculates math.',{'calc','calculate'},0,false,false,false,function(message,args)
	if #args[1]<1 then return sendMessage(message,embed(nil,"You must specify what to calculate.",colors.red),true)end
	local function sm(t)
		sendMessage(message,embed(nil,t,colors.bright_blue),true)
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
addCommand('LMGTFY','Let me google that for you','lmgtfy',0,false,false,false,function(message,args)
	sendMessage(message,("http://lmgtfy.com/?q=%s"):format(query.urlencode(args[1])))
end)
addCommand('Urban','Fetches urban dictionary definitions.|/d Definition number','urban',0,false,false,true,function(message,args,switches)
	local d
	if switches['d']~=nil and tonumber(switches['d'])then
		d=tonumber(switches['d'])
	end
	local data,err=API.Misc:Urban(args[1],d)
	sendMessage(message,embed(nil,data or err,colors.blue),true)
end)
addCommand('Nerdy info','Info for nerds.','ninfo',0,false,false,false,function(message,args)
	local ts=tostring
	local cpu=uv.cpu_info()
	local threads=#cpu
	local cpumodel=cpu[1].model
	local mem=math.floor(collectgarbage('count')/1000)
	sendMessage(message,embed('Nerdy Info',nil,colors.yellow,{
		{name='OS:',value=ts(operatingsystem)},
		{name='CPU Threads:',value=ts(threads)},
		{name='CPU Model:',value=ts(cpumodel)},
		{name='Memory usage:',value=ts(mem)..' MB'},
	}),true)
end)
addCommand('Guild info','Fetches info about the guild','ginfo',0,false,true,false,function(message,args)
	local ts=tostring
	local guild=message.guild
	local chan_count=#guild.textChannels+#guild.voiceChannels
	local oname=guild.owner.username..'#'..guild.owner.discriminator
	local nam=(guild.owner.nickname and guild.owner.nickname..' ('..oname..')'or oname)
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
		elseif v==4 then
			return"Guild member must have phone registered. (4)"
		else
			return"Unknown verification level. (-1)"
		end
	end
	sendMessage(message,embed("Guild info",nil,colors.yellow,{
		{name="Full guild name:",value=guild.name,inline=true},
		{name="Guild id:",value=guild.id,inline=true},
		{name="Region:",value=ts(guild.region),inline=true},
		{name="Owner:",value=nam,inline=true},
		{name="Owner ID:",value=guild.owner.id,inline=true},
		{name="Owner status:",value=ts(guild.owner.status),inline=true},
		{name="Member count:",value=guild.totalMemberCount,inline=true},
		{name="Channel count:",value=(chan_count..' (Text: '..#guild.textChannels..' | Voice: '..#guild.voiceChannels..')'),inline=true},
		{name="Shard id:",value=ts(guild.shardId):sub(1,3),inline=true},
		{name="Verification level:",value=ts(getVerificationLevel()),inline=true},
		{name="This guild was created at:",value=convertJoinedAtToTime(guild.timestamp)},
	}),true)
end)
addCommand('Base64','Encodes your message with base64|/u Unbase64','b64',0,false,false,true,function(message,args,switches)
	local data
	if switches['u']then
		data=ssl.base64(args[1],false)
	else
		data=ssl.base64(args[1],true)
	end
	sendMessage(message,embed("Base64",data,colors.blue),true)
end)
addCommand('Destroy','Destroys your message.|/ct Custom text','destroy',0,false,false,true,function(message,args,switches)
	local tx,ct=args[1],''
	if switches['ct']then
		tx=tx:sub(0,tx:find('/ct')-1)
		ct=switches['ct']
	else
		ct=' has been destroyed'
	end
	sendMessage(message,embed(nil,tostring(tx)..ct,colors.blue),true)
end)
addCommand('Verify','Verifies yourself','verify',0,false,true,false,function(message,args)
	local guild=message.guild
	local settings=Database:Get(message).Settings
	local chan=guild.textChannels:find(function(c)
		return c.name==settings.verify_chan
	end)
	if not convertToBool(settings.verify)then
		sendMessage(message,embed("Verification system","Not enabled",colors.red),true)
		return
	end
	if chan then
		if message.channel.id~=chan.id then return end
		local role=guild.roles:find(function(r)
			return r.name==settings.verify_role
		end)
		if role then
			if #args[1]==0 then
				sendMessage(message,embed(nil,"Sending verification code.",colors.yellow),true)
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
					sendMessage(message,embed("Verification system","Code confirmed.",colors.green),true)
					message.member:addRole(role)
					verification_codes[args[1]]=nil
				else
					sendMessage(message,embed("Verification system","Invalid code",colors.red),true)
				end
			end
		else
			sendMessage(message,embed("Verification system","Role not found",colors.red),true)
		end
	end
end)
addCommand('Vote','Vote handler command.|/start Starts vote /add Add vote to <option> /h Help /stop Stops vote',{'vote','stuffballotbox'},0,false,true,true,function(message,args,switches)
	local guild=message.guild
	local settings=Database:Get(message).Settings
	local ctb=convertToBool
	if ctb(settings.voting)==true and guild:getChannel('name',settings.voting_chan).id~=message.channel.id then 
		return sendMessage(message,embed(nil,"Invalid vote. [WRONG CHANNEL]",colors.red),true)
	end
	if switches.start then
		if ctb(settings.voting)==true then
			local options=string.split(switches.start,',')
			local topic=options[1]
			table.remove(options,1)
			local vote=newVote(guild,message.member,topic,options)
			if type(vote)=='string'then
				sendMessage(message,tostring(vote))
			else
				Database:Get(guild).Votes['activeVote']=vote
				Database:Update(guild)
				sendMessage(message,getVoteCount(guild))
			end
		else
			sendMessage(message,embed(nil,"Invalid vote. [VOTING NOT ENABLED]",colors.red),true)
		end
		return
	elseif switches.add then
		return sendMessage(message,embed(nil,addVote(guild,message.member,tonumber(switches.add)),colors.blue),true)
	elseif switches.h then
		return sendMessage(message,embed(nil,"Welcome to the help menu. Please separate options using `,`",colors.green),true)
	elseif switches.stop then
		return sendMessage(message,embed(nil,endVote(guild),colors.blue),true)
	end
	sendMessage(message,embed(nil,getVoteCount(guild),colors.blue),true)
end)
addCommand('Kill','Kills a person with a super zapper!',{'kill','die','youaredeadtome','getrekt'},0,false,true,false,function(message,args)
	coroutine.wrap(function()
		local mem=message.member
		local u=message.mentionedUsers:iter()()
		if u then
			Cooldowns[mem.id]=true
			local function sm(t)
				sendMessage(message,embed(nil,t,colors.bright_blue),true)
			end
			sm('Initializing laser...')
			timer.sleep(5*1000)
			sm('Aiming laser.')
			timer.sleep(2.5*1000)
			sm('Firing! Kaboom!')
			timer.sleep(1000)
			sm('Boom! You\'re dead! '..u.mentionString)
			Cooldowns[mem.id]=nil
		else
			sendMessage(message,embed(nil,"Cannot kill member! Nobody mentioned!",colors.red),true)
		end
	end)()
end)
addCommand('Remind','Remind you of <message>|/t Time /l List',{'remind','tellmelater','remindmelater'},0,false,true,true,function(message,args,switches)
	local guild=message.guild
	local member=message.member
	if switches['l']then
		local list=''
		local timers=Timing:getTimers(message.author.id)
		if getCount(timers)<1 then
			list='No timers present.'
		end
		for i,v in pairs(timers)do
			local tx=''
			local spl=string.split(v.data,'||')
			local typ,chan,time,time_left=spl[1],'','',''
			if typ=='REMINDER'then
				guil=spl[2]
				if guild.id~=guil then return end
				chan=spl[3]
				time=timeBetween(toSeconds(parseTime(spl[5])))
				if spl[5]=='nil'then time='<UNKNOWN?>'end
				time_left=timeBetween(v.endTime-os.time())
				local chan=guild:getChannel(chan)or{id=chan,mentionString='<NOT FOUND>'}
				tx=tx..string.format('**Type: %s**\nChannel: %s\nTime: %s\nTime left: %s',typ,chan.mentionString,time,time_left)
			else
				tx=tx..typ
			end
			list=list..tx..'\n'
		end
		if #list>2000 then
			list='Too many timers to list.'
		end
		return sendMessage(message,embed('List',list,colors.bright_blue),true)
	end
	if not switches['t']then
		return sendMessage(message,"Time switch (/t) not provided.")
	end
	local time=switches['t']
	local secs=toSeconds(parseTime(switches['t']))
	local tx=args[1]:gsub('||',('|'..string.char(226,128,139)..'|'))
	local found=args[1]:find('/t')
	tx=tx:sub(1,found-2)
	Timing:newTimer(guild,secs,string.format('REMINDER||%s||%s||%s||%s||%s',guild.id,message.channel.id,member.id,time,tx))
	sendMessage(message,embed('Reminder','Set new reminder for '..timeBetween(secs)..' from now.',colors.blue),true)
end)
addCommand('Mute','Mutes a member.|/u Unmute /g Global mute/unmute /v Voice mute/unmute /t Time',{'mute','silence','shutupandtakemymoney'},1,false,true,true,function(message,args,switches)
	coroutine.wrap(function()
		local guild=message.guild
		local bm=guild.me
		local global,voice,un,secs
		if not getPermissions(bm,'manageChannels')then return sendMessage(message,"Lack of permissions, manageChannels required.")end
		if switches['u']then
			un=true
		end
		if switches['g']then
			global=true
		end
		if switches['v']then
			voice=true
		end
		if switches['t']and not switches['u']then
			secs=toSeconds(parseTime(switches['t']))
		end
		local u,bpos=message.mentionedUsers:iter()(),getHighestRole(bm)
		if u then
			local member=guild:getMember(u)
			if getRank(member)<getRank(message.member)then
				if bpos>getHighestRole(member)then
					if voice then
						if un then
							member:unmute()
						else
							member:mute()
						end
						sendMessage(message,(un and"Unmuted "or"Muted ")..member.mentionString.." [VOICE]")
					else
						if un then
							if global then
								for channel in guild.textChannels:iter() do
									unmute(member,channel)
								end
							else
								unmute(member,message.channel)
							end
							sendMessage(message,(global and"Globally unmuted "or"Unmuted ")..member.mentionString)
						else
							if global then
								for channel in guild.textChannels:iter() do
									mute(member,channel)
								end
							else
								mute(member,message.channel)
							end
							if secs then
								Timing:newTimer(guild,secs,string.format('UNMUTE||%s||%s||%s',guild.id,(global and'all'or message.channel.id),member.id))
							end
							sendMessage(message,(global and"Globally muted "or"Muted ")..member.mentionString..(secs and' | For '..switches['t']or''))
						end
					end
				else
					sendMessage(message,"Cannot mute member! Rank exceeds my own!")
				end
			else
				sendMessage(message,"Cannot mute member! Their rank either exceeds yours, or they are the same rank!")
			end
		else
			sendMessage(message,"Cannot mute member! Nobody mentioned!")
		end
	end)()--possibly pausing the main thread is bad
end)
addCommand('Kick','Kicks a member.|/r Reason',{'kick','deport'},1,false,true,true,function(message,args,switches)
	local reason
	local bm,voice=getBotMember(message.guild),false
	local settings=Database:Get(message).Settings
	if switches['r']then
		reason=switches.r
	end
	if not getPermissions(bm,'kickMembers')then return sendMessage(message,"Lack of permissions, kickMembers required.")end
	local u,bpos=message.mentionedUsers:iter()(),getHighestRole(bm)
	if u then
		local member=message.guild:getMember(u)
		if getRank(member)<getRank(message.member)then
			if bpos>getHighestRole(member)then
				if settings.required_reason and not switches.r then
					sendMessage(message,"Cannot kick member! Reason required!")
				else
					local this=member:kick(reason)
					if not this then
						sendMessage(message,"Cannot kick member! Unknown error!")
					end
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
addCommand('Voice Kick','Kicks a member from voice.',{'vkick','vdeport'},1,false,true,false,function(message,args,switches)
	local bm=getBotMember(message.guild)
	if not getPermissions(bm,'manageChannels')then return sendMessage(message,"Lack of permissions, manageChannels required.")end
	if not getPermissions(bm,'moveMembers')then return sendMessage(message,"Lack of permissions, moveMembers required.")end
	local u,bpos=message.mentionedUsers:iter()(),getHighestRole(bm)
	if u then
		local member=message.guild:getMember(u)
		if getRank(member)<getRank(message.member)then
			if bpos>getHighestRole(member)then
				coroutine.wrap(function()--no pausing the main thread
					local vk=voiceKick(member)
					sendMessage(message,"Result: "..vk)
				end)()
			else
				sendMessage(message,"Cannot v-kick member! Rank exceeds my own!")
			end
		else
			sendMessage(message,"Cannot v-kick member! Their rank either exceeds yours, or they are the same rank!")
		end
	else
		sendMessage(message,"Cannot v-kick member! Nobody mentioned!")
	end
end)
addCommand('Ban','Bans a member.|/r Reason /u Unban /l Ban list',{'ban','banish','youshallnotpass'},2,false,true,true,function(message,args,switches)
	local reason,days
	local guild=message.guild
	local enf=reasonEnforced(guild)
	local bm,n=getBotMember(guild)
	if not getPermissions(bm,'banMembers')then return sendMessage(message,"Lack of permissions, banMembers required.")end
	if switches['u']then
		for user in guild:getBans():iter()do
			if user.id==switches['u']then
				if enf and switches['r']then
					local mem=message.member
					sendModLog(guild,{
						{name='Staff',value=mem.name..'#'..mem.discriminator,inline=true},
						{name='Staff ID',value=mem.id,inline=true},
						{name='Staff Rank',value=tostring(getRank(mem,true)),inline=true},
						{name='Against',value=user.name..'#'..user.discriminator,inline=true},
						{name='Against ID',value=user.id,inline=true},
						{name='Action',value='Unban',inline=true},
						{name='Reason',value=switches['r']},
					})
				elseif enf and switches['r']==nil then
					return sendMessage(message,embed(nil,"Reason not provided!",colors.red),true)
				end
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
		for user in guild.bannedUsers:iter()do
			tx=tx..'Name:\n\t'..user.username..'\nDiscriminator:\n\t'..user.discriminator..'\nId:\n\t'..user.id..'\n'
		end
		if #tx==0 then
			sendMessage(message,"No users found.")
		else
			sendMessage(message,tx)
		end
		return
	end
	if switches['r']then
		reason=switches.r
	end
	if switches['d'] and tonumber(switches['d'])then
		days=tonumber(switches['d'])
	end
	local user,bpos=message.mentionedUsers:iter()(),getHighestRole(bm)
	if user then
		local member=guild:getMember(user)
		if getRank(member)<getRank(message.member)then
			if bpos>getHighestRole(member)then
				if enf and switches['r']then
					local mem=message.member
					sendModLog(guild,{
						{name='Staff',value=mem.name..'#'..mem.discriminator,inline=true},
						{name='Staff ID',value=mem.id,inline=true},
						{name='Staff Rank',value=tostring(getRank(mem,true)),inline=true},
						{name='Against',value=user.name..'#'..user.discriminator,inline=true},
						{name='Against ID',value=user.id,inline=true},
						{name='Action',value='Unban',inline=true},
						{name='Reason',value=reason},
					})
				elseif enf and switches['r']==nil then
					return sendMessage(message,embed(nil,"Reason not provided!",colors.red),true)
				end
				local this=member:ban(reason,days)
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
addCommand('Settings','Sets the settings.|/s Setting /v Value /d Description /l Settings list',{'settings','set'},3,false,true,true,function(message,args,switches)
	local guild=message.guild
	local settings=Database:Get(message).Settings
	if switches.s then
		if switches.s:sub(#switches.s)==' 'then
			switches.s=switches.s:sub(1,#switches.s-1)
		end
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
					Database:GetCached(guild).Settings[switches.s]=switches.v
					Database:Update(guild)
					sendMessage(message,embed(nil,string.format("Set %s to %s",switches.s,switches.v),colors.bright_blue),true)
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
		for i,v in orderedPairs(settings)do
			local o=guild:getRole(v)or guild:getChannel(v)
			if o then
				if not o.channelType then
					v=o.name
				else
					v=o.mentionString
				end
			end
			this=this..'**'..i..'** | '..(type(v)=='table'and'List setting'or tostring(v))..'\n'
		end
		sendMessage(message,embed("Settings list",this),true)
	else
		sendMessage(message,[[
			How to use settings menu:
			/s <setting> /v <value> - Sets <setting> to <value>.
			/s <setting> /d - Grabs description for setting.
			/s <setting> - Current setting.
			/l - List of settings.
		]])
	end
end)
addCommand('List Settings','Settings for lists|/s Setting /a Add value /r Remove value /d Description',{'lsettings','lset'},3,false,true,true,function(message,args,switches)
	local guild=message.guild
	local settings=Database:Get(message).Settings
	local fmt=string.format
	if switches.s then
		if switches.s:sub(#switches.s)==' 'then
			switches.s=switches.s:sub(1,#switches.s-1)
		end
		if settings[switches.s]then
			if type(settings[switches.s])~='table'then
				return sendMessage(message,"Setting "..switches.s.." is not a list setting. Please use the set/settings command.")
			end
			if switches.a then
				if s_pred[switches.s]then
					local response=s_pred[switches.s](switches.a,message)
					if response then
						sendMessage(message,embed(nil,response,colors.bright_blue),true)
					end
				else
					table.insert(settings[switches.s],switches.a)
					Database:Update(guild)
					sendMessage(message,embed(nil,string.format("Added %s to %s",switches.a,switches.s),colors.bright_blue),true)
				end
			elseif switches.r then
				for i,v in pairs(settings[switches.s])do
					local o=guild:getRole(v)or guild:getChannel(v)
					if o~=nil then
						if o.name:lower()==switches.r:lower()then
							settings[switches.s][i]=nil
							Database:Update(guild)
							sendMessage(message,embed(nil,string.format("Removed %s from %s",switches.r,switches.s),colors.bright_blue),true)
							return
						end
					else
						if v:lower()==switches.r:lower()then
							settings[switches.s][i]=nil
							Database:Update(guild)
							sendMessage(message,embed(nil,string.format("Removed %s from %s",switches.r,switches.s),colors.bright_blue),true)
							return
						end
					end
				end
				sendMessage(message,'Not found! Value: '..switches.r)
			elseif switches.clear then
				if switches.confirm then
					sendMessage(message,fmt('Clearing %s.',settings.s))
					Database:GetCached(guild).Settings[settings.s]=Database.Default.Settings[settings.s]
					Database:Update(guild)
				else
					sendMessage(message,'Use the /confirm switch to confirm this clearing.')
				end
			elseif switches.d then
				if descriptions[switches.s]then
					sendMessage(message,embed(nil,fmt("Setting: %s | Description: %s",switches.s,descriptions[switches.s])),true)
				else
					sendMessage(message,embed(nil,fmt("Setting: %s | Description: %s",switches.s,"No description found.")),true)
				end
			else
				local tx=''
				for i,v in pairs(settings[switches.s])do
					local o=guild:getRole(v)or guild:getChannel(v)
					if o then
						tx=tx..o.name..', '
					else
						tx=tx..v..', '
					end
				end
				sendMessage(message,embed(nil,"Setting: "..switches.s.." | Value: "..tx,colors.bright_blue),true)
			end
		else
			return sendMessage(message,"No setting found: "..switches.s)
		end
	else
		sendMessage(message,[[
			How to use list settings menu:
			/s <setting> /a <value> - Adds <value> to <setting> list.
			/s <setting> /r <value> - Removes <value> from <setting> list.
			/s <setting> /d - Grabs description for setting list.
			/s <setting> - Current setting values.
		]])
	end
end)
addCommand('Ignore','Ignores texts in a channel.','ignore',3,false,true,false,function(message,args)
	local chan=message.channel
	local ignored=Database:Get(message).Ignore
	ignored[chan.id]=true
	if Database.Type=='rethinkdb'then
		Database:Update(message)
	else
		Database:Update('Ignore',message)
	end
end)
addCommand('Unignore','Unignores texts in a channel.','unignore',3,false,true,false,function(message,args)
	local chan=message.channel
	local ignored=Database:Get(message).Ignore
	ignored[chan.id]=nil
	if Database.Type=='rethinkdb'then
		Database:Delete(message,'Ignore/'..chan.id)
	else
		Database:Update('Ignore',message)
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
		return txt
	end
	local function fp(...)
		local n = select('#', ...)
		local arguments = {...}
		for i = 1, n do
			arguments[i] = pprint.dump(arguments[i],nil,true):gsub(token,'<Hidden for security>')
		end
		local txt=table.concat(arguments, "\t").."\n"
		tx=tx..txt
		return txt
	end
	local toload=args[1]:gsub('```lua',''):gsub('```','')
	local a,b=loadstring(toload,'Electricity 2.0')
	if not a then
		return sendMessage(message,"[S] Error! - "..b)
	end
	local env=setmetatable({
		print=fprint,
		p=fp,
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
	sendMessage(message,string.format('```%s```',tostring(tx):gsub(token,'<Hidden for security>')))
end)
addCommand('test','test','test',4,false,false,false,function(message,args)
	error('error')
end)
addCommand('restart','restart','restart',4,false,false,false,function(message,args)
	loadModule(args[1])
end)