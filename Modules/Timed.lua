local fmt = string.format

Timer = {
	_callbacks = {},
	_timers = {},
}

function Timer:on(func)
	assert(type(func) == 'function', 'Error: X3F - callback not function')
	table.insert(self._callbacks, func)
end

function Timer:fire(...)
	for _, callback in pairs(self._callbacks) do
		coroutine.wrap(callback)(...)
	end
end

function Timer:load(guild)
	local timers = database:get(guild).Timers or{}
	for id, timer in pairs(timers) do
		if timer.ended < os.time() then
			coroutine.wrap(function()
				self:delete(guild, id)
				if timer.stopped == true then return end
				timer.data = timer.data .. '||' .. (os.time() - timer.ended)
				self:fire(timer.data)
			end)()
		else
			self:new(guild, timer.ended - os.time(), timer.data, true)
		end
	end
end

function Timer:save(guild, id, timer)
	local timers = database:get(guild).Timers
	timers[id] = timer
	database:update(guild)
end

function Timer:delete(guild, id)
	self._timers[id] = nil
	return database:delete(guild, id)
end

function Timer:new(guild, secs, data, ign)
	if type(secs) ~= 'number' then secs = 5 end
	local ms = secs * 1000
	assert(guild ~= nil, 'Error 9F2 - Guild Nonexistant')
	assert(type(data) == 'string', 'Error CXT - data not string')
	local id = ssl.base64(fmt('%s|%s|%s', ssl.random(20), ms, data), true):gsub('/','')
	timer.setTimeout(ms,function()
		coroutine.wrap(function()
			if not self._timers[id] then return end
			if self._timers[id].stopped then return end
			data = data .. '||' .. (os.time() - self._timers[id].ended)
			self:fire(data)
			self:delete(guild,id)
		end)()
	end)
	local tab = {duration = secs, ended = os.time() + secs, stopped = false, data = data}
	self._timers[id] = tab
	if not ign then self:save(guild, id, tab) end
	return id
end

function Timer:end(id)
	if self._timers[id] == nil then
		client:warning('Invalid id passed to Timer:end')
	else
		self._timers[id].stopped = true
	end
end

function Timer:get(data)
	local ret = {}
	for id, v in pairs(self._timers) do
		if v.data:find(data) then
			ret[id] = v
		end
	end
	return ret
end