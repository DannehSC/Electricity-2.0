--EVENTS.LUA--
--[[
	TODO:
		Add deleted message log.
		Process edited messages.
]]
Events={}
function Events.messageCreate(message)
	local settings={}
	local bet='!'--default
	local content,command,isServer=message.content,'',false
	if message.author.bot==true then return end
	if message.channel.isPrivate then
		--do nothing, it doesn't really matter
	else
		settings={}--Database:Get(message).Settings
		isServer=true
		local filt,reason=filter(message)
		if filt then
			local reply=message:reply(string.format("Your message has been filtered. Reason: %s This message will self destruct in T-10 seconds.",reason))
			message:delete()
			coroutine.wrap(function()
				timer.setTimeout(10*1000,coroutine.wrap(function()
					reply:delete()
				end))
			end)()
			return
		end
		bet=settings.bet or bet
	end
	local obj=(message.member~=nil and message.member or message.author)
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
	local settings={}
	local isServer=false
	if message.author.bot==true then return end
	if message.channel.isPrivate then
		--do nothing, it doesn't really matter
	else
		settings={}--Database:Get(message).Settings
		isServer=true
		local filt,reason=filter(message)
		if filt then
			local reply=message:reply(string.format("Your message has been filtered. Reason: %s This message will self destruct in T-10 seconds.",reason))
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
	client:setGameName('Mention me for help!')
	print'ready'
end