fs = require('fs')
http = require('coro-http')
discordia = require('discordia')
rethinkdb = require('luvit-reql')

framework = {}

function framework.loadModule(name, file)
	local bool, mod = pcall(function()
		return fs.readFileSync(file)
	end)
	
	if bool then
		local syn, err = loadstring(mod, name)
		if syn then
			setfenv(syn, getfenv())
			local run, err = pcall(syn)
			if run then
				rethinkdb.logger:info('Module loaded. [' .. name .. ']')
			else
				error('Unable to load module [' .. name .. '] Reason: [RUNTIME]: ' .. err)
			end
		else
			error('Unable to load module [' .. name .. '] Reason: [SYNTAX]: ' .. err)
		end
	else
		error('Unable to load module. [' .. file .. '] Reason: ' .. mod)
	end
end

client = discordia.Client()
uptime = discordia.Stopwatch()

discordia.extensions()

framework.events = {}

function framework.events.messageCreated(message)
    local a, b = pcall(function()
        local guild = message.guild
        local content = message.content
        local data
        
        if message.author.bot then return end
        if guild then
            data = database:get(guild)
        end    
        if not data then
            data = database.default
        end
        
        if type(content) ~= 'string' then
            return
        end
        
        local bet = data.Settings.bet
        if message.mentionedUsers.first == client.user then
            return sendMessage(message, ('My name is Electricity!\nTo learn more about me, say `%sbinfo`\nTo learn more commands, say `%scmds`'):format(bet, bet))
        end
        
        content = content:lower()
		if content:sub(1, #bet) == bet then
			local betPos = #bet + 1
            for i, v in pairs(commands.cmds) do
				for ii, vv in pairs(v.cmds) do
					if content:sub(betPos, (betPos + #vv) - 1) == vv:lower() then
						local args = {}
						for word in (content:sub(#bet + #vv + 1)):gmatch("%w+") do table.insert(args, word) end
						v.func(message, #args > 0 and unpack(args)) -- only call unpack() on args if it is bigger than zero
                    end
                end
            end
        end
    end)
    
    if not a then
        rethinkdb.logger:warn('Error processing message by `' .. tostring(message.author.name) .. '` | Content: ' .. tostring(message.content) .. ' | Error: ' .. tostring(b))
    end
end

function framework:run()
	database:run()
	stats:prepare()
	client:on('messageCreate', self.events.messageCreated)
	client:once('ready', function()
		timer:init()
		stats:init()
		for g in client.guilds:iter() do
			initGuild(g)
		end
	end)
	client:run('Bot ' .. options.token)
end

return framework