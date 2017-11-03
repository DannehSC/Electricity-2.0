--NEW DATABASE--
local data=require('./database.lua')
local rethink=require('luvit-reql')
local conn=rethink.connect(data)
local ts,fmt=tostring,string.format
local function getTableCount(t)
	local x=0
	for i,v in pairs(t)do
		x=x+1
	end
	return x
end
Database={
	_raw_database=rethink,
	_conn=conn,
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
		mod_log='false',
		mod_log_chan='default---channel',
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
	Timers={},
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
			if checkForCopies(settings.admin_roles,r.id)then
				return"Unsuccessful! Role already in list!"
			end
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
			if checkForCopies(settings.co_owner_roles,r.id)then
				return"Unsuccessful! Role already in list!"
			end
			table.insert(settings.co_owner_roles,r.id)
			Database:Update(guild)
			return"Successfully added role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..name..")"
		end
	end,
	mod_log=function(value,message)
		local guild=message.guild
		local settings=Database:Get(guild).Settings
		if convertToBool(value)==nil then
			return"Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.mod_log=value
			Database:Update(guild)
			return"Set audit_log to "..value
		end
	end,
	mod_log_chan=function(name,message)
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
			settings.mod_log_chan=c.name
			Database:Update(guild)
			return"Successfully set audit log channel! ("..c.mentionString..")"
		else
			return"Unsuccessful! Channel does not exist! ("..name..")"
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
			if checkForCopies(settings.mod_roles,r.id)then
				return"Unsuccessful! Role already in list!"
			end
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
			settings.verify_role=r.id
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
	local id,guild=resolveGuild(guild)
	if Database.Cache[id]then
		local Cached=Database.Cache[id]
		if Cached[index]then
			return Cached[index]
		else
			return Cached
		end
	else
		local data,err=Database._conn.reql().db('electricity').table('guilds').get(tostring(id)).run()
		if err then
			print('GET',err)
		else
			local u
			if data==nil or data==json.null or data[1]==nil then
				data=table.deepcopy(Database.Default)
				data.id=id
				Database.Cache[id]=data
				u=true
			else
				local data=data[1]
				Database.Cache[id]=data
				Database.Cache[id]['id']=id
				for i,v in pairs(Database.Default)do
					if not data[i]then
						data[i]=v
						u=true
					end
				end
				for i,v in pairs(Database.Default.Settings)do
					if not data.Settings[i]then
						data.Settings[i]=v
						u=true
					end
				end
			end
			if u then
				Database:Update(id)
			end
			return data
		end
	end
end
function Database:Update(guild,query,index,value)
	if not guild then error"No ID/Guild/Message provided"end
	local id,guild=resolveGuild(guild)
	if Database.Cache[id]then
		if index then
			Database.Cache[id][index]=value
		end
		if not Database.Cache[id].id then
			Database.Cache[id].id=id
		end
		local data,err,edata=conn.reql().db('electricity').table('guilds').inOrRe(Database.Cache[id]).run()
		if err then
			print('UPDATE')
			print(err)
			p(edata)
		end
	else
		print"Fetch data before trying to update it. You fool."
	end
end
function Database:Delete(guild,index)
	if not guild then error"No ID/Guild/Message provided"end
	local id,guild=resolveGuild(guild)
	if Database.Cache[id]then
		local Cached=Database.Cache[id]
		if Cached[index]then
			Cached[index]=nil
		elseif Cached.Timers[index]then
			Cached.Timers[index]=nil
		elseif Cached.Roles[index]then
			Cached.Roles[index]=nil
		end
	end
	Database:Update(guild)
end
function Database:GetCached(guild)
	local id,guild=resolveGuild(guild)
	if Database.Cache[id]then
		return Database.Cache[id]
	end
end