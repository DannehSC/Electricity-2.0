commands = {
	cmds = {},
	count = 0
}

function commands:addCommand(name, desc, cmds, rank, func, opts)
	if type(cmds) ~= 'table' then cmds = {cmds} end
	self.cmds[name] = {name = name, desc = desc, cmds = cmds, rank = rank, func = func, options = opts or {}}
	self.count = self.count + 1
end

commands:addCommand('Id Generator', 'Generates identification codes.', 'id', 0, function(message, text)
	message:reply(idMaker:generate())--sendMessage(message, idMaker:generate())
end)

return commands