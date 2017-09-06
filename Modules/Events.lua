--EVENTS.LUA--
--[[
	TODO:
		Add deleted message log.
]]
Cooldowns={}
Events={}
function Events.messageCreate(message)
	if not _G.ready then return end
	local settings,ignore={},{}
	local bet=Database.Default.Settings.bet--default
	local content,command,isServer,private=message.content,'',false,false
	if message.author.bot==true then return end
	if message.channel.type==enums.channelType.private then
		private=true
	else
		settings=Database:Get(message).Settings
		ignore=Database:Get(message).Ignore
		isServer=true
		local filt,reason=filter(message)
		if filt then
			local reply=message:reply(string.format("Your message has been filtered. Reason: %s | This message will self destruct in T-10 seconds.",reason))
			message:delete()
			coroutine.wrap(function()
				timer.setTimeout(10*1000,coroutine.wrap(function()
					reply:delete()
				end))
			end)()
			return
		end
		bet=settings.bet or bet
		if ignore[message.channel.id]==true then
			if message.content:sub(1,#bet+#'unignored'):lower()==bet..'unignore'then
				--don't return
			else
				return'Ignored'
			end
		end
	end
	local obj=(private and message.author or message.member or message.guild:getMember(message.author))
	local rank=getRank(obj,isServer)
	if content==client.user.mentionString then
		sendMessage(message,("To see info about the bot | %sabout\nTo see commands | %scmds\nTo see settings | %ssettings /l"):format(bet,bet,bet))
	end
	if content:sub(1,#bet)==bet then
		local n
		if content:find' 'then
			n=content:find' '
			command=content:sub(#bet+1,n-1)
			n=n+1
		else
			command=content:sub(#bet+1)
			n=9999
		end
		for name,tab in pairs(Commands)do
			for ind,cmd in pairs(tab.Commands)do
				if command:lower()==cmd:lower()then
					if Cooldowns[obj.id]then sendTempMessage({message,embed(nil,"You're on cooldown!",colors.bright_blue),true},2)message:delete()return end
					if tab.serverOnly then
						if not isServer then
							sendMessage(message,'Command error:\nThis command does not work in DMs.')
							return
						end
					end
					if rank>=tab.Rank then
						local switches,args
						if tab.Multi then
							args=string.split(content:sub(n),' ')
						else
							args={content:sub(n)}
						end
						if tab.Switches then
							switches=getSwitches(args[1])
						else
							switches={}
						end
						local a,b=pcall(tab.Function,message,args,switches)
						if not a then
							sendMessage(message,'Command error:\n'..b)
							sendLog(hooks[FFB('Errors')],"**COMMAND ERROR**",string.format("Error message: %s\n\nGuild id: %s\n\nChannel id: %s\n\nUser id: %s",b,isServer and message.guild.id or"PRIVATE CHANNEL",message.channel.id,message.author.id))
						end
					else
						sendMessage(message,'Command error:\nYour rank is not high enough to run this command')
					end
				end
			end
		end
	end
end
function Events.messageUpdate(message)
	if not _G.ready then return end
	local settings={}
	local isServer=false
	if message.author.bot==true then return end
	if message.channel.isPrivate then
		--do nothing, it doesn't really matter
	else
		settings=Database:Get(message).Settings
		isServer=true
		local filt,reason=filter(message)
		if filt then
			local reply=message:reply(string.format("Your message has been filtered. Reason: %s | This message will self destruct in T-10 seconds.",reason))
			message:delete()
			coroutine.wrap(function()
				timer.setTimeout(10*1000,coroutine.wrap(function()
					reply:delete()
				end))
			end)()
			return
		end
	end
end
function Events.ready()
	local waiting,already_set=0,false
	local function checked()
		local result=pcall(function()
			local db=Database._raw_database
			local a,b=http.request('GET',string.format('%s://%s:5000/guilds/test?key=%s',db.method,db.ip,db.key))
		end)
		--[[if result==false then
			waiting=waiting+1
		end]]
		return result
	end
	--client:setGame('Loading...')
	repeat
		print'Waiting for python wrapper...'
		--[[if waiting>2 and not already_set then
			client:setGame('Loading...')
			already_set=true
		end]]
		timer.sleep(500)
	until checked()==true
	client:setGame('Mention me for help!')
	for guild in client.guilds:iter()do
		Database:Get(guild)
	end
	client:info'Bot is ready.'
	_G.ready=true
end