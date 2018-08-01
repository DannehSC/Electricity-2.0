local framework = {}

function framework.loadModule(name, file)
	local bool, mod = pcall(require, file)
	if bool then
		_G[name] = mod
	else
		error('Unable to load module. [' .. file .. '] Reason: ' .. mod)
	end
end

framework.loadModule('http', 'http')
framework.loadModule('timer', 'timer')
framework.loadModule('reql', 'luvit-reql')
framework.loadModule('discordia', 'discordia')

framework.events = {}

function framework.events.messageCreated(message)
	
end

function framework:run()
	database:run()
	stats:prepare()
	discordia:on('messageCreated', self.events.messageCreated)
	discordia:on('ready', function()
		timer:init()
		stats:init()
		for g in client.guilds do
			initGuild(g)
		end
	end)
	discordia:run(config.token)
end

return framework