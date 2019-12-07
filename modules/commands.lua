commands = {
	cmds = {},
	count = 0
}

function commands:addCommand(name, desc, cmds, rank, func, opts)
	if type(cmds) ~= 'table' then cmds = {cmds} end
	self.cmds[name] = {name = name, desc = desc, cmds = cmds, rank = rank, func = func, options = opts or {}}
	self.count = self.count + 1
end

commands:addCommand('Guild Data', 'Gathers data about the guild.', 'ginfo', 0, function(message, text)
	
end)

commands:addCommand('Id Generator', 'Generates identification codes.', 'id', 0, function(message, text)
	sendMessage(message, idMaker:generate())
end)

commands:addCommand('Beep', 'Beep', 'beep', 0, function(message, text)
	sendMessage(message, 'Beep.')
end)

return commands