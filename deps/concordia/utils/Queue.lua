local Encrypt=require('encrypter')
local Emitter=require('./Emitter')
local Queue={}
function Queue:New()
	local NewQueue=setmetatable({
		Current='null',
		Previous='null',
		Queue={},
		Emits={},
		EName=('Queue'..Encrypt.Randomizer(75)),
	},{
		__tostring="Queue",
	})
	function NewQueue:New(...)
		local t={...}
		for i,v in pairs(t)do
			table.insert(NewQueue.Queue,tostring(v))
		end
	end
	function NewQueue:Next()
		local self=NewQueue
		local cur=self.Queue[1]
		table.remove(self.Queue,1)
		if self.Queue[1]then
			self.Current=self.Queue[1]
		else	
			print'<Queue> Queue ended.'
			self.Current='null'
		end
		if cur then
			self.Previous=cur
		else
			self.Previous='null'
		end
	end
	function NewQueue:On(callback)
		local self=NewQueue
		if not callback or type(callback)~='function'then return"Invalid type to argument 1 (callback)"end
		local Emit=Emitter:New(self.EName,callback)
		if tostring(Emit):lower():sub(1,4)=='lack'then return tostring(Emit)end
		table.insert(self.Emits,Emit)
	end
	function NewQueue:Fire(...)
		Emitter:Fire(NewQueue.EName,...)
	end
	function NewQueue:Clear()
		self.Queue={}
	end
	return NewQueue
end
return Queue