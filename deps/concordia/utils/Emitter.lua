local Encrypt=require('encrypter')
local Emitter={
	Emitters={},
}
function Emitter:New(EventName,Callback)
	if not EventName then return"Lack of EventName argument (1st argument)"end
	if not EventName then return"Lack of Callback argument (2nd argument)"end
	local Id=Encrypt.Randomizer(20)
	local function CheckId()
		for i,v in pairs(Emitter.Emitters)do
			if v.EmitId==Id then
				return true
			end
		end
		return false
	end
	repeat 
		if CheckId()==true then
			Id=Encrypt.Randomizer(20)
		end
	until not CheckId()
	table.insert(Emitter.Emitters,{
		EventName=EventName,
		Callback=Callback,
		EmitId=Id,
	})
	return Id
end
function Emitter:Rem(EmitId)
	if not EmitId then return"Lack of Emitter ID argument (1st argument)"end
	for i,v in pairs(Emitter.Emitters)do
		if v.EmitId==EmitId then
			table.remove(Emitter.Emitters,i)
		end
	end
end
function Emitter:Fire(EventName,...)
	if not EventName then return"Lack of EventName argument (1st argument)"end
	for i,v in pairs(Emitter.Emitters)do
		if v.EventName==EventName then
			coroutine.wrap(v.Callback)(...)
		end
	end
end
return Emitter