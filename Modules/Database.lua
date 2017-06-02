local firebase=require('luvit-firebase')
local DBData=require('./database.lua')
Database={}
Database.Cache={}
Database.Databases={}
Database.Defaults={}
for i,v in pairs(DBData.Databases)do
	local data=firebase(v[1],v[2])
	Database.Databases[i]=data
	Database.Cache[i]={}
	print(string.format("Made Database [%s]",tostring(i)))
end
for i,v in pairs(DBData.Default)do
	Database.Defaults[i]=v
end
function Database:Get(data_b,guild,ind)
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
	if Database.Cache[data_b]then
		if Database.Cache[data_b][id]then
			return Database.Cache[data_b][id]
		else
			local function callback(e,ret)
				if e then
					print(("ERROR IN DATABASE:\n\tDATABASE: %s\n\tGUILD NAME: %s\n\tGUILD ID: %s\n\tREQUEST: %s"):format(ts(data_b),ts(guild.name),ts(id),ts(ind)))
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
		print("Database does not exist. ["..tostring(data_b).."]")
	end
end
function Database:Update(data_b,guild,ind,val)
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
		print("Database does not exist. ["..tostring(data_b).."]")
	end
end