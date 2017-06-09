--Database.lua
local firebase=require('luvit-firebase')
local DBData=require('./database.lua')
Database={}
Database.Cache={}
Database.Databases={}
Database.Defaults={
	['Settings']={
		admin_roles={},
		bet='-',
		mod_roles={},
		verify='true',--'false',
		verify_role='Member',
		verify_chan='default---channel',
	},
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
s_preds={
	admin_roles=function(name,message)
		local guild=message.guild
		local settings=Database:Get('Settings',guild)
		local r=guild:getRole('name',name)
		if r then
			table.insert(settings.admin_roles,r.name)
			Database:Update('Settings',guild)
			return"Successfully added role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..r.name..")"
		end
	end,
	mod_roles=function(name,message)
		local guild=message.guild
		local settings=Database:Get('Settings',guild)
		local r=guild:getRole('name',name)
		if r then
			table.insert(settings.mod_roles,r.name)
			Database:Update('Settings',guild)
			return"Successfully added role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..r.name..")"
		end
	end,
	verify_role=function(name,message)
		local guild=message.guild
		local settings=Database:Get('Settings',guild)
		local r=guild:getRole('name',name)
		if r then
			Database:Update('Settings',guild,'verify_role',r.name)
			return"Successfully set verify role! ("..r.name..")"
		else
			return"Unsuccessful! Role does not exist! ("..r.name..")"
		end
	end,
	verify_chan=function(name,message)
		local guild=message.guild
		local settings=Database:Get('Settings',guild)
		local c=guild:getChannel('name',name)
		if r then
			Database:Update('Settings',guild,'verify_chan',r.name)
			return"Successfully set verify channel! ("..r.name..")"
		else
			return"Unsuccessful! Channel does not exist! ("..r.name..")"
		end
	end,
	verify=function(value,message)
		local guild=message.guild
		local settings=Database:Get('Settings',guild)
		if convertToBool(value)==nil then
			return"Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			Database:Update('Settings',guild,'verify',value)
			return"Set verify to "..value
		end
	end,
}
descriptions={
	
}
for i,v in pairs(DBData.Databases)do
	local data=firebase(v[1],v[2])
	Database.Databases[i]=data
	Database.Cache[i]={}
	print(string.format("Made Database [%s]",tostring(i)))
end
function Database:Get(data_b,guild,ind)
	local ts,fmt=tostring,string.format
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
	if Database.Cache[data_b]then
		if Database.Cache[data_b][id]then
			return Database.Cache[data_b][id]
		else
			local function callback(e,ret)
				if e then
					print(fmt("ERROR IN DATABASE:\n\tDATABASE: %s\n\tGUILD NAME: %s\n\tGUILD ID: %s\n\tREQUEST: %s",ts(data_b),ts(guild.name),ts(id),ts(ind)))
				else
					if ret=='null'or ret==nil then
						if Database.Defaults[data_b]then
							local t=Database.Defaults[data_b]
							if type(t)=='function'then
								t=t(guild)
							end
							Database.Cache[data_b][id]=t
							return t
						else
							Database.Cache[data_b][id]={}
							return{}
						end
					else
						local data=type(ret)=='table'and ret or json.decode(ret)
						local update=false
						if Database.Defaults[data_b]then
							local t=Data.Defaults[data_b]
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
						Database.Cache[data_b][id]=data
						if update then
							Database:Update(data_b,id)
						end
					end
				end
			end
			local e,ret=Database.Databases[data_b]:get(id,callback)
			callback(e,ret)
		end
	else
		print(fmt("Database does not exist.\nDatabase: %s\nGuild: %s\nGuild id: %s",ts(data_b),ts(guild.name),ts(guild.id)))
		if Database.Defaults[data_b]then
			return Database.Defaults[data_b]
		else
			return{}
		end
	end
end
function Database:Update(data_b,guild,ind,val)
	local ts,fmt=tostring,string.format
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
	local Db=Database.Databases[data_b]
	local cache=Database.Cache[data_b]
	local function cb(e,ret)
		if e then
			print(("ERROR IN DATABASE:\n\tDATABASE: %s\n\tGUILD NAME: %s\n\tGUILD ID: %s\n\tREQUEST: %s"):format(ts(data_b),ts(guild.name),ts(id),'Update'))
		end
	end
	if Db then
		if id then
			if cache[id]then
				if ind then
					Database.Cache[data_b][id][ind]=val
				end
				local e,ret=Db:set(id,json.encode(Database.Cache[data_b][id]),cb)
				if e then
					cb(e,ret)
				end
			else
				local Default=Database.Defaults[data_b]
				if type(Default)=='function'then Default=Default(guild)end
				if Default then
					local e,ret=Db:set(id,json.encode(Default),cb)
					if e then
						cb(e,ret)
					end
				end
			end
		else
			if not Database.Cache[data_b]then return end
			local data={}
			for i,v in pairs(Database.Cache[data_b])do
				print(i)
				local e,ret=Db:set(i,json.encode(v),cb)
				if e then
					cb(e,ret)
				end
			end
		end
	else
		print(fmt("Database does not exist.\nDatabase: %s\nGuild: %s\nGuild id: %s",ts(data_b),ts(guild.name),ts(guild.id)))
	end
end