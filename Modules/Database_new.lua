--NEW DATABASE--
local rethink=require('luvit-rethinkdb-wrapper')('127.0.0.1',false)
local ts,fmt=tostring,string.format
Database={
	_raw_database=rethink,
	Cache={},
	Type='rethinkdb',
}
Database.Default={
	Settings={
		admin_roles={},
		audit_log='false',
		audit_log_chan='default---channel',
		bet='elec!',
		banned_phrases={},
		co_owner_roles={},
		mod_roles={},
		verify='false',
		verify_role='Member',
		verify_chan='default---channel',
		voting='false',
		voting_chan='default---channel',
	},
	Ignore={},
	Cases={},
	Roles={},
	Votes={},
}
s_pred={
	admin_roles=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local r
		local this=getIdFromString(name)
		if this then
			r=guild:getRole(this)
		else
			r=guild.roles:find(function(r)
				return r.name==name
			end)
		end
		if r then
			table.insert(settings.admin_roles,r.id)
			Database:Update(guild)
			return"Successfully added role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..name..")"
		end
	end,
	audit_log=function(value,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		if convertToBool(value)==nil then
			return"Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.audit_log=value
			Database:Update(guild)
			return"Set audit_log to "..value
		end
	end,
	audit_log_chan=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local c
		local this=getIdFromString(name)
		if this then
			c=guild:getChannel(this)
		else
			c=guild.textChannels:find(function(c)
				return c.name==name
			end)
		end
		if c then
			settings.audit_log_chan=c.name
			Database:Update(guild)
			return"Successfully set audit log channel! ("..c.mentionString..")"
		else
			return"Unsuccessful! Channel does not exist! ("..name..")"
		end
	end,
	co_owner_roles=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local r
		local this=getIdFromString(name)
		if this then
			r=guild:getRole(this)
		else
			r=guild.roles:find(function(r)
				return r.name==name
			end)
		end
		if r then
			table.insert(settings.co_owner_roles,r.id)
			Database:Update(guild)
			return"Successfully added role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..name..")"
		end
	end,
	mod_roles=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local r
		local this=getIdFromString(name)
		if this then
			r=guild:getRole(this)
		else
			r=guild.roles:find(function(r)
				return r.name==name
			end)
		end
		if r then
			table.insert(settings.mod_roles,r.id)
			Database:Update(guild)
			return"Successfully added role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..name..")"
		end
	end,
	verify_role=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local r
		local this=getIdFromString(name)
		if this then
			r=guild:getRole(this)
		else
			r=guild.roles:find(function(r)
				return r.name==name
			end)
		end
		if r then
			settings.verify_role=r.name
			Database:Update(guild)
			return"Successfully set verify role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..r.name..")"
		end
	end,
	verify_chan=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local c
		local this=getIdFromString(name)
		if this then
			c=guild:getChannel(this)
		else
			c=guild.textChannels:find(function(c)
				return c.name==name
			end)
		end
		if c then
			settings.verify_chan=c.name
			Database:Update(guild)
			return"Successfully set verify channel! ("..c.mentionString..")"
		else
			return"Unsuccessful! Channel does not exist! ("..name..")"
		end
	end,
	verify=function(value,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		if convertToBool(value)==nil then
			return"Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.verify=value
			Database:Update(guild)
			return"Set verify to "..value
		end
	end,
	voting=function(value,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		if convertToBool(value)==nil then
			return"Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.voting=value
			Database:Update(guild,nil,'voting',value)
			return"Set audit_log to "..value
		end
	end,
	voting_chan=function(name,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		local c
		local this=getIdFromString(name)
		if this then
			c=guild:getChannel(this)
		else
			c=guild.textChannels:find(function(c)
				return c.name==name
			end)
		end
		if c then
			settings.voting_chan=c.name
			Database:Update(guild)
			return"Successfully set audit log channel! ("..c.mentionString..")"
		else
			return"Unsuccessful! Channel does not exist! ("..name..")"
		end
	end,
}
descriptions={
	admin_roles='Roles that have admin (rank 2) access.',
	audit_log='Value defines whether the log service is running.',
	audit_log_chan='Log service channel to post to.',
	bet='What users say to start a command. Example: !cmds or :cmds',
	banned_phrases='Things users are not permitted to say.',
	mod_roles='Roles that have moderator (rank 1) access.',
	verify='Defines if the verification system is running or not.',
	verify_chan='Channel where users can verify.',
	verify_role='Role given to a member when verified using the verification system.',
}
function Database:Get(guild,index)
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
	if Database.Cache[id]then
		local Cached=Database.Cache[id]
		if Cached[index]then
			return Cached[index]
		else
			return Cached
		end
	else
		local data,err=rethink:get(fmt('guilds/%s',id))
		if err then
			print('GET',err)
		else
			local u
			if data=='null'then
				data=Database.Default
				Database.Cache[id]=data
				u=''
			else
				Database.Cache[id]=data
				for i,v in pairs(Database.Default.Settings)do
					if not data.Settings[i]then
						data.Settings[i]=v
						u=''
					end
				end
			end
			if u then
				Database:Update(guild)
			end
			return data
		end
	end
end
function Database:Update(guild,query,index,value)
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
	if Database.Cache[id]then
		if index then
			Database.Cache[id][index]=value
		end
		local data,err=rethink:post(fmt('guilds/%s%s',id,query and'/'..query or''),Database.Cache[id])
		if err then
			print(err)
			return err
		end
	else
		print"Fetch data before trying to update it. You fool."
	end
end
function Database:Delete(guild,query,index)
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
	if Database.Cache[id]then
		local Cached=Database.Cache[id]
		if Cached[index]then
			Cached[index]=nil
		end
	end
	local data,err=rethink:delete(fmt('guilds/%s%s',id,query and'/'..query or''))
	if err then
		print(err)
		return err
	end
end
function Database:GetCached(guild)
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
	if Database.Cache[id]then
		return Database.Cache[id]
	end
end