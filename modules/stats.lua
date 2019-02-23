local second = 1000
local minute = second * 60
local hour   = minute * 60

stats = {
	data = options.API,
	conf = options.API.stats,
}

function stats:update()
	
end

function stats:prepare()
	if self.conf.NG then
		client:on('guildCreated', function()
			stats:update()
		end)
	end
	if self.conf.Time then
		timer.setInterval(hour, function()
			coroutine.wrap(function()
				stats:update()
			end)()
		end)
	end
end

function stats:init()
	
end