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
	
end

function framework:run()
	database:run()
	stats:prepare()
	client:on('messageCreated', self.events.messageCreated)
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