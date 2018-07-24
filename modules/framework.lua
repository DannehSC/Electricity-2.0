local http = require('coro-http')
local reql = require('luvit-reql')
local discordia = require('discordia')

local framework = {}

function framework.registerModule(name, mod)
	_G[name] = mod
end

framework.registerModule('http', http)
framework.registerModule('reql', reql)
framework.registerModule('discordia', discordia)

function framework.loadModule(name, file)
	local bool, mod = pcall(require, file)
	if bool then
		framework.registerModule(name, mod)
	else
		error('Unable to load module. [' .. file .. '] Reason: ' .. mod)
	end
end

function framework.run()
	stats:prepare()
	discordia:on('ready', function()
		event:fire('ready')
		timer:init()
		stats:init()
	end)
	discordia:run(config.token)
end

return framework