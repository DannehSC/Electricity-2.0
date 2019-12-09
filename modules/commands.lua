local ts = tostring

local timer = require('timer')

local operatingsystem = ts(require('ffi').os)
local cpu = require('uv').cpu_info()
local threads = ts(#cpu)
local cpumodel = cpu[1].model

local feedbackCooldowns = {}

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

commands:addCommand('Feedback', 'Send feedback to the Electricity staff.', { 'feedback','fb' }, 0, function(message, ...)
	local text = table.concat(..., " ") -- join the seperated args together to form the message
	local guildId = '284895856031956992'
	local channelId = '415731489926283267'
	local author, oGuild, oChannel = message.author, message.guild, message.channel
	
	-- TODO: maybe we should move the cooldown portion to
	-- database code to make it so it persists in something
	-- other than memory?
	if feedbackCooldowns[author.id] then
		return sendMessage(message, embed('FAILED', 'You may not submit feedback. You are still on cooldown.', colors.red))
	end

	if database._conn.reql().db('electricity').table('fbbans').get(author.id).run() then
		return sendMessage(message, embed('FAILED', 'You may not submit feedback. You are banned from submitting feedback. You may appeal this ban in the Electricity official server.', colors.red))
	end

	sendMessage(client:getGuild(guildId):getChannel(channelId),
		embed('Feedback [' .. author.username .. '#' .. author.discriminator .. ']', "**__FEEDBACK:__** " .. text, colors.bright_blue, {
			{name = 'Author ID', value = author.id, inline = true},
			{name = 'Guild ID', value = oGuild.id, inline = true},
			{name = 'Channel ID', value = oChannel.id, inline = true}
		}))
	
	sendMessage(message, embed('SUCCESS', 'Sent feedback. You are now on cooldown for 1 hour.', colors.green))
	feedbackCooldowns[author.id] = true
	timer.setTimeout(3600000, function()
		feedbackCooldowns[author.id] = nil
	end)
end)

commands:addCommand('Id Generator', 'Generates identification codes.', 'id', 0, function(message, text)
	sendMessage(message, idMaker:generate())
end)

commands:addCommand('Ping', 'Pings the bot.', 'ping', 0, function(message, args)
	sendMessage(message, embed(nil, "Pong!", colors.green))
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
		if (optn == 3 and num == 1) or (optn == 2 and num == 3) or (optn == 1 and num == 2) then
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

commands:addCommand('About', 'Reads you info about the bot.', { 'about', 'help', 'binfo' }, 0, function(message, args)
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
		{ name = 'OS:', value = operatingsystem },
		{ name = 'CPU Threads:', value = threads },
		{ name = 'CPU Model:', value = cpumodel },
		{ name = 'Memory usage:', value = ts(mem) .. ' MB' },
	}))
end)

commands:addCommand('User Info', 'Fetches info about a user', 'uinfo', 0, function(message)
	local u = message.mentionedUsers:iter()()
	if not u then
		u = message.author
	end
	local m = message.guild:getMember(u)
	if not m then
		return sendMessage(message, "[ERROR] Member not found. Please contact support through the `join` cmd or `join2` cmd.")
	end
	sendMessage(message, embed("User Info", nil, colors.yellow, {
		{ name = "Username", value = u.username, inline = true },
		{ name = "Discriminator", value = u.discriminator, inline = true },
		{ name = "Identification", value = u.id, inline = true },
		{ name = "User Rank", value = getRank(m), inline = true },
		{ name = "Joined guild at", value = convertJoinedAtToTime(m.joinedAt), inline = true },
		{ name = "Joined discord at", value = convertJoinedAtToTime(u.timestamp), inline = true },
	}))
end)

commands:addCommand('Uptime', 'Returns the time the bot has been loaded.', 'uptime', 0, function(message)
	local time = uptime:getTime():toTable()
	sendMessage(message, embed(nil, string.format("Week%s: %s\nDay%s: %s\nHour%s: %s\nMinute%s: %s\nSecond%s: %s",
		time.weeks ~= 1 and 's' or '', time.weeks,
		time.days ~= 1 and 's' or '', time.days,
		time.hours ~= 1 and 's' or '', time.hours,
		time.minutes ~= 1 and 's' or '', time.minutes,
		time.seconds ~= 1 and 's' or '', time.seconds
	), colors.blue))
end)

commands:addCommand('Bot invite', 'Sends you the bot invite links.', 'botinv', 0, function(message)
	sendMessage(message,embed('Links',
		"[Non administrative](https://discordapp.com/oauth2/authorize?client_id=284380758611591170&scope=bot)\n[Administrative](https://discordapp.com/oauth2/authorize?client_id=284380758611591170&scope=bot&permissions=8)",
	colors.yellow))
end)

commands:addCommand('Cat picture', 'Gets a cat picture', { 'cat', 'kitty', 'cpic' }, 0, function(message)
	local file, err = API.Misc:Cats()
	sendMessage(message, file or err)
end)

commands:addCommand('Coin flip!', 'Flips a coin!', { 'cflip', 'coinflip', 'flippy' } , 0, function(message)
	sendMessage(message, embed(nil, (math.random(1, 2) == 1 and "Tails" or "Heads"), colors.yellow))
end)

commands:addCommand('Roll the dice', 'Dice!', { 'rtdice', 'dice', 'roll' }, 0, function(message)
	sendMessage(message, embed(nil, "You rolled a " .. tostring(math.random(1, 6)), colors.yellow))
end)

commands:addCommand('Dog picture', 'Gets a dog picture', { 'dog', 'bork', 'dogpic' }, 0, function(message)
	local file, err = API.Misc:Dogs()
	sendMessage(message, file or err)
end)

commands:addCommand('Joke', 'Gets a joke', { 'joke', 'joker', 'batmansparents', 'dadjoke' }, 0, function(message)
	local joke = API.Misc:Joke()
	sendMessage(message, joke)
end)

commands:addCommand('Commands', 'Grabs the list of commands for your rank.', { 'cmds', 'commands' }, 0, function(message)
	local Rank = getRank(message.member) or 0
	local cmds = splitForDiscord(Rank)
	local msg = sendMessage(message.author, 'Sending commands')
	if msg then
		msg:delete()

		for _,cmd in pairs(cmds) do
			sendMessage(message.author, cmd)
		end

		if message.guild ~= nil then
			sendMessage(message, embed('Notification', 'Commands sent to DMs.', colors.yellow))
		end
	else
		sendMessage(message, embed("Commands", "__***Could not send commands via DM.***__\nPlease enable direct messages", colors.yellow))
	end
end)

commands:addCommand('Guild Data', 'Gathers data about the guild.', 'ginfo', 0, function(message, text)
	
end)

return commands