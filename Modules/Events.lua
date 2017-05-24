Events={}
function Events.messageCreate(message)
	local bet='-' --temporary, to replace with database.
	local content,command,isServer,botUser,botMember=message.content,'',false,client.user
	if message.author.bot then return end
	if message.channel.isPrivate then
		--do nothing, it doesn't really matter
	else
		botMember=botUser:getMembership(message.guild)
		isServer=true
	end
	if content:sub(1,#bet)==bet then
		local n
		if content:find' 'then
			command=content:sub(#bet+1,content:find' '-1)
			n=content:find' '+1
		else
			command=content:sub(#bet+1)
			n=9999
		end
		for name,tab in pairs(Commands)do
			for ind,cmd in pairs(tab.Commands)do
				if cmd:lower():sub(1,#command)==command:lower()then
					if tab.serverOnly then
						if not isServer then
							sendMessage(message,'This command does not work in DMs.')
							return
						end
					end
					local args=string.split(content:sub(n),' ')
					local a,b=pcall(tab.Function,message,args)
					if not a then
						sendMessage(message,'Command error:\n'..b)
					end
				end
			end
		end
	end
end
function Events.ready()
	print'ready'
end