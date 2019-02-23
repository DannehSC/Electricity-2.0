local ts, tn, fmt = tostring, tonumber, string.format

function getIdFromStr(str)
	if not str then return end
	local fs = str:find('<')
	local fe = str:find('>')
	if not fs or not fe then return end
	return str:sub(fs + 2, fe - 1)
end

resolver = {}

function resolver:guild(var)
	if not var then
		return nil, 'No ID/name/message provided. Cannot resolve guild.'
	end
	var = ts(var)
	local guild
	if type(var) == 'table' then
		if g.guild then
			guild = g.guild
		elseif g.getRole then
			guild = g
		end
	else
		local g = client:getGuild(var)
		if g then
			guild = g
		end
	end
	if g then
		return g, var
	else
		return nil, 'Guild could not be resolved.'
	end
end

function resolver:channel(guild, name)
	local guild, text = self:guild(guild)
	if not guild then
		return nil, text
	end
	local c = getIdFromStr(name)
	local voice, chan = false
	if c then
		chan = guild:getChannel(name)
	else
		chan = guild.textChannels:find(function(ch)
			return ch.name == name or ch.id == name
		end)
	end
	if chan then
		return chan
	else
		return nil, 'Role could not be resolved.'
	end
end

function resolver:role(guild, name)
	local guild, text = self:guild(guild)
	if not guild then
		return nil, text
	end
	local r = getIdFromStr(name)
	local role
	if r then
		role = guild:getRole(name)
	else
		role = guild.roles:find(function(ro)
			return ro.name == name or ro.id == name
		end)
	end
	if role then
		return role
	else
		return nil, 'Role could not be resolved.'
	end
end

idMaker = {}

function idMaker:generate()
	local id = ''
	local rands = {
		ssl.base64(ssl.random(6)),
		ssl.base64(ssl.random(4)),
		ssl.base64(ssl.random(8))
	}
	return rands[1] .. '-' .. rands[2] .. '-' .. rands[3]
end

function initGuild(guild)
	
end