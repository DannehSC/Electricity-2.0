local uv = require('uv')
local operatingsystem = require('ffi').os
local cpu = uv.cpu_info()
local threads = #cpu
local cpumodel = cpu[1].model

local ts = tostring

commands = {
	cmds = {},
	count = 0
}

function commands:addCommand(name, desc, cmds, rank, func, opts)
	if type(cmds) ~= 'table' then cmds = {cmds} end
	self.cmds[name] = {name = name, desc = desc, cmds = cmds, rank = rank, func = func, options = opts or {}}
	self.count = self.count + 1
end

commands:addCommand('Join', 'Sends a link to join the official Electricity guild!', 'join', 0, function(message)
	sendMessage(message, embed(nil, "[Invite](https://discordapp.com/invite/KCMxtK8)", colors.yellow))
end)

commands:addCommand('Join2', 'Sends a raw link to join the official Electricity guild!', 'join2', 0, function(message)
	sendMessage(message, "https://discordapp.com/invite/KCMxtK8")
end)

commands:addCommand('Id Generator', 'Generates identification codes.', 'id', 0, function(message, text)
	sendMessage(message, idMaker:generate())
end)

commands:addCommand('Beep', 'Beep', 'beep', 0, function(message, text)
	sendMessage(message, 'Beep.')
end)

commands:addCommand('Rock Paper Scissors', 'The name says it all.', 'rps', 0, function(message, text)
	local rand = math.random(1,99)
	local options, optionNumbers = { 'rock', 'paper', 'scissors' }, { ['rock'] = 1, ['paper'] = 2, ['scissors'] = 3 }
	local opt, optn
	if rand > 66 then
		opt = options[3]
		optn = 3
	elseif rand > 32 and rand < 66 then
		opt = options[2]
		optn = 2
	elseif rand < 33 then
		opt = options[1]
		optn = 1
	end

	local num = optionNumbers[text and text:lower() or nil]
	if num then
		if (optn == 1 and num == 3) or (optn == 3 and num == 2) or (optn == 2 and num == 1) then
			sendMessage(message, embed('Rock Paper Scissors', string.format("Your choice: **%s**\nBot choice: **%s**\nYou win!", text, opt), colors.yellow))
		elseif optn == num then
			sendMessage(message, embed('Rock Paper Scissors', string.format("Your choice: **%s**\nBot choice: **%s**\nTie!", text, opt), colors.yellow))
		else
			sendMessage(message, embed('Rock Paper Scissors', string.format("Your choice: **%s**\nBot choice: **%s**\nYou lose!", text, opt), colors.yellow))
		end
	else
		sendMessage(message, embed('Rock Paper Scissors', 'Unknown option. Valid:\nRock, paper, scissors', colors.yellow))
	end
end)

commands:addCommand('About', 'Reads you info about the bot.', { 'about', 'help', 'binfo'}, 0, function(message, args)
	local tx, count, owner = '', 0, client.owner
	local dbSettings = database:get(message).Settings
	local bet = dbSettings and dbSettings.bet or database.default.Settings.bet
	local function append(ntx, fin)
		fin = fin or false
		tx = tx .. ntx .. (fin == false and '\n\n' or '')
	end
	
	for g in client.guilds:iter() do	
		count = count + g.totalMemberCount
	end
	
	append("I am the bot known as Electricity (3.0)")
	append("I was created by %s#%d (DannehSC on Github)")
	append("To see the commands list: Please say `%scmds` or `%scommands`")
	append("To see nerd info: Please say `%sninfo`")
	append("To see uptime: Please say `%suptime`")
	append("To see the settings: Please say `%ssettings /l`")
	append("To join the support server: `%sjoin` or `%sjoin2`")
	append("If you are in a guild, you can see info about the guild. Please say `%sginfo`")
	append("Thank you for using Electricity!", true)
	sendMessage(message, embed("Info", (tx):format(owner.username, owner.discriminator, bet, bet, bet, bet, bet, bet, bet, bet), colors.brightBlue, {
		{ name = "Guild count", value = #client.guilds, inline = true },
		{ name = "Shard count", value = client.shardCount, inline = true },
		{ name = "Member count", value = count, inline = true },
	}))
end)

commands:addCommand('Nerdy info', 'Info for nerds.', 'ninfo', 0, function(message)
	local mem = math.floor(collectgarbage('count') / 1000)
	sendMessage(message, embed('Nerdy Info', nil, colors.yellow, {
		{ name = 'OS:', value = ts(operatingsystem) },
		{ name = 'CPU Threads:', value = ts(threads) },
		{ name = 'CPU Model:', value = ts(cpumodel) },
		{ name = 'Memory usage:', value = ts(mem) .. ' MB' },
	}))
end)

commands:addCommand('Guild Data', 'Gathers data about the guild.', 'ginfo', 0, function(message, text)
	
end)

return commands