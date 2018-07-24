local event = {
	events = {},
}

function event:on(name, func)
	local id
	repeat
		id = math.random(100000, 999999)
	until not self.events[id]
	self.events[id] = {e = name, func = func}
	return id
end

function event:ignore(id)
	if not self.events[id] then
		return false
	else
		self.events[id] = nil
		return true
	end
end

function event:once(name, func)
	local e
	e = event:on(name, function(...)
		event:ignore(e)
		func(...)
	end)
	return e
end

function event.initialize()
	
end