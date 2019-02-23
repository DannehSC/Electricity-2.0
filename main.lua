_G.options = require('./options.lua')

local framework = require('./modules/framework.lua')

local order = {
	'functions',
	'database',
	'commands',
	'timer',
	'stats',
}

for i = 1, #order do
	local mod = order[i]
	framework.loadModule(mod, module.dir .. '/modules/' .. mod .. '.lua')
end

coroutine.wrap(function()
	framework:run()
end)()