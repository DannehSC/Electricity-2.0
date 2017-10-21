local f=string.format
Timing={
	_callbacks={},
	_timers={},
}
function Timing:on(f)
	assert(type(f)=='function','Error: X3F - callback not function')
	table.insert(Timing._callbacks,f)
end
function Timing:fire(...)
	for i,cb in pairs(Timing._callbacks)do
		coroutine.wrap(cb)(...)
	end
end
function Timing:load(guild)
	local timers=Database:Get(guild).Timers or{}
	for id,timer in pairs(timers)do
		p(id,timer)
		if timer.endTime<os.time()then
			coroutine.wrap(function()print(Timing:delete(guild,id))end)()
			if timer.stopped==true then return end
			Timing:fire(timer.data)
		else
			Timing:newTimer(guild,timer.endTime-os.time(),timer.data,true)
		end
	end
end
function Timing:save(guild,id,timer)
	local timers=Database:Get(guild).Timers
	timers[id]=timer
	Database:Update(guild)
end
function Timing:delete(guild,id)
	return Database:Delete(guild,'Timers/'..id)
end
function Timing:newTimer(guild,secs,data,ign)
	if type(secs)~='number'then secs=5 end
	local ms=secs*1000
	assert(guild~=nil,'Error 9F2 - guild nil')
	assert(type(data)=='string','Error CXT - data not string')
	local id=ssl.base64(f('%s|%s|%s',ssl.random(20),ms,data),true):gsub('/','')
	timer.setTimeout(ms,function()
		coroutine.wrap(function()
			print(Timing:delete(guild,id))
			if not Timing._timers[id]then return end
			if Timing._timers[id].stopped then return end
			print(data)
			Timing:fire(data)
			print'ended'
		end)()
	end)
	local tab={duration=secs,endTime=os.time()+secs,stopped=false,data=data}
	Timing._timers[id]=tab
	if not ign then Timing:save(guild,id,tab)end
	return id
end
function Timing:endTimer(timerId)
	if self._timers[timerId]==nil then
		client:warning('Invalid timerId passed to Timer:endTimer')
	else
		self._timers[timerId].stopped=true
	end
end