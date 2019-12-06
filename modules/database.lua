local rData = options.database
local rEmitter = rethinkdb.emitter
local ts, fmt = tostring, string.format

database = {
	_db = rethinkdb
}

if rData.cache then
	database._cache = {}
end

local connect

function connect()
	local conn = rethinkdb.connect(data)
	database._conn = conn
end

rEmitter:on('quit', function()
	connect()
end)

function database:run()
	connect()
end

database.default = {
	Settings = {
		admin_roles = {},
		audit_log = 'false',
		audit_log_chan = 'default---channel',
		auto_bot_roles = {},
		auto_role = 'false',
		auto_roles = {},
		banned_phrases = {},
		bet = 'elec!',
		co_owner_roles = {},
		log_deleted = 'false',
		mod_log = 'false',
		mod_log_chan = 'default---channel',
		mod_roles = {},
		notification = 'false',
		notification_chan = 'default---channel',
		other_logs = 'default---channel',
		verify = 'false',
		verify_role = 'Member',
		verify_chan = 'default---channel',
		voting = 'false',
		voting_chan = 'default---channel',
	},
	Ignore = {},
	Cases = {},
	Roles = {},
	Votes = {},
	Timers = {},
}

s_pred = {
	admin_roles = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local r
		local this = getIdFromString(name)
		if this then
			r = guild:getRole(this)
		else
			r = guild.roles:find(function(r)
				return r.name == name
			end)
		end
		if r then
			if checkForCopies(settings.admin_roles, r.id)then
				return "Unsuccessful! Role already in list!"
			end
			table.insert(settings.admin_roles, r.id)
			database:Update(guild)
			return "Successfully added role! (" .. r.name .. ")"
		else
			return "Unsuccessful! Role does not exist! (" .. name .. ")"
		end
	end,
	audit_log = function(value, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.audit_log = value
			database:Update(guild)
			return "Set audit_log to " .. value
		end
	end,
	audit_log_chan = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local c
		local this = getIdFromString(name)
		if this then
			c = guild:getChannel(this)
		else
			c = guild.textChannels:find(function(c)
				return c.name == name
			end)
		end
		if c then
			settings.audit_log_chan = c.name
			database:Update(guild)
			return "Successfully set audit log channel! (" .. c.mentionString .. ")"
		else
			return "Unsuccessful! Channel does not exist! (" .. name .. ")"
		end
	end,
	auto_bot_roles = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local r
		local this = getIdFromString(name)
		if this then
			r = guild:getRole(this)
		else
			r = guild.roles:find(function(r)
				return r.name == name
			end)
		end
		if r then
			if checkForCopies(settings.auto_bot_roles, r.id)then
				return "Unsuccessful! Role already in list!"
			end
			table.insert(settings.auto_bot_roles, r.id)
			database:Update(guild)
			return "Successfully added role! (" .. r.name .. ")"
		else
			return "Unsuccessful! Role does not exist! (" .. name .. ")"
		end
	end,
	auto_role = function(value, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.auto_role = value
			database:Update(guild)
			return "Set auto_role to " .. value
		end
	end,
	auto_roles=function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local r
		local this = getIdFromString(name)
		if this then
			r = guild:getRole(this)
		else
			r = guild.roles:find(function(r)
				return r.name == name
			end)
		end
		if r then
			if checkForCopies(settings.auto_roles, r.id)then
				return "Unsuccessful! Role already in list!"
			end
			table.insert(settings.auto_roles, r.id)
			database:Update(guild)
			return "Successfully added role! (" .. r.name .. ")"
		else
			return "Unsuccessful! Role does not exist! (" .. name .. ")"
		end
	end,
	co_owner_roles = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local r
		local this = getIdFromString(name)
		if this then
			r = guild:getRole(this)
		else
			r = guild.roles:find(function(r)
				return r.name == name
			end)
		end
		if r then
			if checkForCopies(settings.co_owner_roles, r.id)then
				return "Unsuccessful! Role already in list!"
			end
			table.insert(settings.co_owner_roles, r.id)
			database:Update(guild)
			return "Successfully added role! (" .. r.name .. ")"
		else
			return "Unsuccessful! Role does not exist! (" .. name .. ")"
		end
	end,
	log_deleted = function(value, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.audit_log = value
			database:Update(guild)
			return "Set log_deleted to " .. value
		end
	end,
	mod_log = function(value, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.mod_log = value
			database:Update(guild)
			return "Set audit_log to " .. value
		end
	end,
	mod_log_chan = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local c
		local this = getIdFromString(name)
		if this then
			c = guild:getChannel(this)
		else
			c = guild.textChannels:find(function(c)
				return c.name == name
			end)
		end
		if c then
			settings.mod_log_chan = c.name
			database:Update(guild)
			return "Successfully set audit log channel! (" .. c.mentionString .. ")"
		else
			return "Unsuccessful! Channel does not exist! (" .. name .. ")"
		end
	end,
	mod_roles = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local r
		local this = getIdFromString(name)
		if this then
			r = guild:getRole(this)
		else
			r = guild.roles:find(function(r)
				return r.name == name
			end)
		end
		if r then
			if checkForCopies(settings.mod_roles, r.id)then
				return "Unsuccessful! Role already in list!"
			end
			table.insert(settings.mod_roles, r.id)
			database:Update(guild)
			return "Successfully added role! (" .. r.name .. ")"
		else
			return "Unsuccessful! Role does not exist! (" .. name .. ")"
		end
	end,
	notification = function(value, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.mod_log = value
			database:Update(guild)
			return "Set notifications to " .. value
		end
	end,
	notification_chan = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local c
		local this = getIdFromString(name)
		if this then
			c = guild:getChannel(this)
		else
			c = guild.textChannels:find(function(c)
				return c.name == name
			end)
		end
		if c then
			settings.mod_log_chan = c.name
			database:Update(guild)
			return "Successfully set notification channel! (" .. c.mentionString .. ")"
		else
			return "Unsuccessful! Channel does not exist! (" .. name .. ")"
		end
	end,
	other_logs = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local c
		local this = getIdFromString(name)
		if this then
			c = guild:getChannel(this)
		else
			c = guild.textChannels:find(function(c)
				return c.name == name
			end)
		end
		if c then
			settings.mod_log_chan = c.name
			database:Update(guild)
			return "Successfully set other logs channel! (" .. c.mentionString .. ")"
		else
			return "Unsuccessful! Channel does not exist! (" .. name .. ")"
		end
	end,
	verify_role = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local r
		local this = getIdFromString(name)
		if this then
			r = guild:getRole(this)
		else
			r = guild.roles:find(function(r)
				return r.name == name
			end)
		end
		if r then
			settings.verify_role = r.id
			database:Update(guild)
			return "Successfully set verify role! (" .. r.name .. ")"
		else
			return "Unsuccessful! Role does not exist! (" .. r.name .. ")"
		end
	end,
	verify_chan = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local c
		local this = getIdFromString(name)
		if this then
			c = guild:getChannel(this)
		else
			c = guild.textChannels:find(function(c)
				return c.name == name
			end)
		end
		if c then
			settings.verify_chan = c.name
			database:Update(guild)
			return "Successfully set verify channel! (" .. c.mentionString .. ")"
		else
			return "Unsuccessful! Channel does not exist! (" .. name .. ")"
		end
	end,
	verify = function(value,message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.verify = value
			database:Update(guild)
			return "Set verify to " .. value
		end
	end,
	voting = function(value, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		if convertToBool(value) == nil then
			return "Invalid value! Must be 'true' or 'yes' for yes. Must be 'false' or 'no' for no."
		else
			settings.voting = value
			database:Update(guild)
			return "Set voting to " .. value
		end
	end,
	voting_chan = function(name, message)
		local guild = message.guild
		local settings = database:Get(guild).Settings
		local c
		local this = getIdFromString(name)
		if this then
			c = guild:getChannel(this)
		else
			c = guild.textChannels:find(function(c)
				return c.name == name
			end)
		end
		if c then
			settings.voting_chan = c.name
			database:Update(guild)
			return "Successfully set voting channel! (" .. c.mentionString .. ")"
		else
			return "Unsuccessful! Channel does not exist! (" .. name .. ")"
		end
	end,
}

descriptions = {
	admin_roles = 'Roles that have admin (rank 2) access.',
	audit_log = 'Value defines whether the log service is running.',
	audit_log_chan = 'Log service channel to post to.',
	bet = 'What users say to start a command. Example: !cmds or :cmds',
	banned_phrases = 'Things users are not permitted to say.',
	mod_roles = 'Roles that have moderator (rank 1) access.',
	verify = 'Defines if the verification system is running or not.',
	verify_chan = 'Channel where users can verify.',
	verify_role = 'Role given to a member when verified using the verification system.',
}

local function getDBQuery(tab)
	if not database._conn then
		return false, 'FAILED, no connection found. [GETDBQUERY]'
	end
	return database._conn.reql().db(rData.db).table(tab or rData.table)
end

function database:otherGet(tab, val)
	local query, text = getDBQuery(tab)
	if query then
		return query.get(ts(val)).run()
	else
		return nil, text
	end
end

function database:get(id)
	local guild, id = resolver:guild(id)
	if not guild then return id end
	local function doQuery()
		local query, text = getDBQuery()
		if query then
			local u
			local data = query.get(ts(id)).run()
			if data == nil then
				local data = table.deepcopy(self.default)
				data[id] = id
				if rData.cache then
					self._cache[id] = data
				end
				u = true
			else
				for i,v in pairs(self.default) do
					if not data[i] then
						data[i] = v
						u = true
					end
				end
				for i,v in pairs(self.default.Settings) do
					if not data.Settings[i] then
						data.Settings[i] = v
						u = true
					end
				end
			end
			if u then
				self:update(id)
			end
			return data
		else
			return self.default, text
		end
	end
	if rData.cache then
		if self._cache[id] then
			return self._cache[id]
		else
			return doQuery()
		end
	else
		return doQuery()
	end
end

function database:getCached(id)
	local guild, id = resolver:guild(id)
	if not guild then return id end
	if rData.cache then
		if self._cache[id] then
			return self._cache[id]
		else
			return
		end
	else
		return
	end
end

function database:rawGet(id)
	local guild, id = resolver:guild(id)
	if not guild then return id end
	local query, text = getDBQuery()
	if query then
		local u
		local data = query.get(ts(id)).run()
		if data == nil then
			return table.deepcopy(self.default)
		else
			for i,v in pairs(self.default) do
				if not data[i] then
					data[i] = v
					u = true
				end
			end
			for i,v in pairs(self.default.Settings) do
				if not data.Settings[i] then
					data.Settings[i] = v
				end
			end
		end
		return data
	else
		return database.default, text
	end
end

function database:update(id, data)
	local guild, id = resolver:guild(id)
	if not guild then return id end
	if rData.cache then
		if self._cache[id] then
			if not self._cache[id].id then
				self._cache[id].id = id
			end
			local data, err, edata = getDBQuery().inOrRe(self._cache[id]).run()
			if err then
				print('DB UPDATE ERR -', tostring(err))
				p(edata)
			end
			return data, err, edata
		else
			return nil, "Fetch data before trying to update it."
		end
	else
		if not data then return nil, 'No data provided. [CACHE DISABLED]' end
		if not data[id] then
			data[id] = id
		end
		local data, err, edata = getDBQuery().inOrRe(data).run()
		if err then
			print('DB UPDATE ERR -', tostring(err))
			p(edata)
		end
		return data, err, edata
	end
	return nil, 'Something went wrong. [database:update()]'
end

function database:delete(id)
	local guild, id = resolver:guild(id)
	if not guild then return id end
	
end