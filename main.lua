local config = require('./options.lua')
local framework = require('./modules/framework.lua')

_G.config = config

local order = {
	'logger',
	'functions',
	'database',
	'timer',
	'stats',
	'commands',
}

for i = 1, #order do
	local mod = order[i]
	framework.loadModule(mod, './modules/' .. mod .. '.lua')
end

framework:run()