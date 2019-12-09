local ssl = require('openssl')

local color = discordia.Color.fromRGB
local ts, tn, fmt = tostring, tonumber, string.format
local classType = discordia.class.type
colors = {
	red = color(255,0,0).value,
	blue = color(0,0,255).value,
	green = color(0,255,0).value,
	orange = color(255,160,0).value,
	yellow = color(255,255,0).value,
	brightBlue = color(0,200,255).value,
}

function getIdFromStr(str)
	if not str then return end
	local fs = str:find('<')
	local fe = str:find('>')
	if not fs or not fe then return end
	return str:sub(fs + 2, fe - 1)
end

resolver = {}

function resolver:guild(var)
	local guild
	if not var then
		return nil, 'No ID/channel/message provided. Cannot resolve guild.'
	end
	if type(var) == 'table' then
		if classType(var) == 'Guild' then
			guild = var
		elseif classType(g) == 'Channel' or classType(g) == 'Message' then
			guild = var.guild
		end
	else
		guild = client:getGuild(ts(var))
	end
	if guild then
		return guild, guild.id
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
		return nil, 'Channel could not be resolved.'
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
	local rands = {
		ssl.base64(ssl.random(6)),
		ssl.base64(ssl.random(4)),
		ssl.base64(ssl.random(8))
	}
	return rands[1] .. '-' .. rands[2] .. '-' .. rands[3]
end

function getRank(member)
	if not member then
		return 0
	end
	local guild = member.guild
	local rank = 0
	if server then
		--[[
			TODO: We seriously could make this more efficient by not using a ton of loops
			and making the database index like a table upon returning "Settings"
		--]]
		local settings = database:get(member.guild).Settings
		for i, v in pairs(settings.mod_roles) do
			local o = member.guild:getRole(v)
			if o then
				if member:hasRole(o) then
					rank = 1
				end
			end
		end
		for i, v in pairs(settings.admin_roles) do
			local o=member.guild:getRole(v)
			if o then
				if member:hasRole(o)then
					rank=2
				end
			end
		end
		for i, v in pairs(settings.co_owner_roles) do
			local o = member.guild:getRole(v)
			if o then
				if member:hasRole(o) then
					rank=3
				end
			end
		end
		local owner = member.guild:getMember(member.guild.ownerId)
		if owner and member.id == owner.id then
			rank = 3
		end
	end
	if member.id == client.user.id then
		rank = 3
	end
	if member.id == client.owner.id then
		rank = 4
	end
	return rank
end

function initGuild(guild)
	if database._cache then
		database:get(guild) -- pre-caching
	end
end

function embed(title, description, color, fields, other)
	local emb = {}
	emb['title'] = title or nil
	emb['description'] = description or nil
	emb['color'] = color or nil
	emb['fields'] = fields or nil

	if other then
		for index, value in pairs(other) do
			emb[index] = value
		end
	end

	return { embed = emb }
end

function sendMessage(obj, content)
	local continue, newContent, msg
	if type(content) == 'string' then
		if #content >= 1999 then
			continue = true
			newContent = content:sub(1983)
			content = content:sub(1, 1982) .. ' [CONTINUED]'
		end
	end
	
	if classType(obj) == 'Message' then
		msg = obj:reply(content)
	elseif classType(obj) == 'PrivateChannel' then
		msg = obj:send(content)
	elseif classType(obj) == 'GuildTextChannel' then
		msg = obj:send(content)
	end
	
	if continue then
		sendMessage(obj, newContent)
	end
	
	return msg
end

local function split(msg, bet)
	local f = msg:find(bet)
	if f then
		return msg:sub(1, f - 1), msg:sub(f + 1)
	else
		return msg
	end
end

function convertJoinedAtToTime(tim)
	if not tim then return "<NULL>" end
	local Date, Rest = split(tim, 'T')
	local Time1, Time2 = split(Rest, ':')
	Time1 = tonumber(Time1)
	local M = Time1 > 12 and "PM" or "AM"
	Time1 = Time1 > 12 and Time1 - 12 or Time1
	
	return (Time1 .. ':' .. Time2:sub(1,5) .. " " .. M .. " - " .. Date)
end