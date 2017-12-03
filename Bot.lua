local fs = require('fs')
local discordia = require('discordia')
local options = require('./options')
local token = options.Token
local hooks = options.Hooks
local enums = discordia.enums
local client = discordia.Client()
local uptime = discordia.Stopwatch()

function FFB(str)
	if beta == true then
		return str .. '_B'
	else
		return str
	end
end

function loadModule(name)
	name = name .. '.lua'
	local data, others = fs.readFileSync('./modules/' .. name)
	if data then
		local func, syntax_err = loadstring(data, name)
		if not a then
			print('[Syntax Error] while loading ' .. name .. '\nError:' .. err)
			if sendLog then
				sendLog(hooks[FFB('Errors')], 'Syntax Error', string.format('Name: %s\nError: %s', name, tostring(syntax_err)))
			end
			return false
		else
			setfenv(func, getfenv())
			local ret, runtime_err = pcall(func)
			if not ret then
				print('[Runtime Error] while loading ' .. name .. '\nError:' .. ret)
				if sendLog then
					sendLog(hooks[FFB('Errors')], 'Runtime Error', string.format('Name: %s\nError: %s', name, tostring(runtime_err)))
				end
				return false
			else
				client:info('Module Online: '..name)
			end
		end
	else
		print('[Loading Error] in '..name..'\nError:'..tostring(data), tostring(others))
		if sendLog then
			sendLog(hooks[FFB('Errors')], 'Loading Error', string.format('Name: %s\nERROR: %s\n%s', name, tostring(data), tostring(others)))
		end
		return false
	end
end

coroutine.wrap(function()
	loadModule('utilities')
	loadModule('functions')
	loadModule('database')
	loadModule('commands')
	loadModule('events')
	loadModule('timed')
	loadModule('API')
	client:on('messageCreate', Events.messageCreate)
	client:on('messageUpdate', Events.messageUpdate)
	client:on('messageDelete', Events.messageDelete)
	client:on('guildCreate', Events.guildCreate)
	client:on('guildDelete', Events.guildDelete)
	client:once('ready', Events.ready)
	client:run(token)
end)()