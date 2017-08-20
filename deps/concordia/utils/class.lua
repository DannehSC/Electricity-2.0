local Class={
	Classes={},
}
local function copy(tab)
	local newtab={}
	for i,v in pairs(tab)do
		newtab[i]=v
	end
	return newtab
end
function Class:New(ClassName)
	local NewClass=self.Classes[ClassName]
	if NewClass then
		return copy(self.Classes[ClassName])
	else
		return copy(self.Classes['Base'])
	end
end
local Meta=setmetatable({},{
	__tostring=function(...)
		if self then
			if self['ClassName']then
				return"Instance of "..self.ClassName
			else
				return"Instance of nil"
			end
		else
			return"Instance of nil"
		end
	end,
})
function Class:NewClass(Name,BaseClass)
	local NewClass,Finished,Clone
	if not BaseClass or not self.Classes[BaseClass]then
		BaseClass='Base'
	end
	if Name~='Base'then
		Clone=copy(self.Classes[BaseClass])
	else
		Clone={}
	end
	NewClass={
		ClassName=Name,
		Parent=BaseClass,
	}
	for i,v in pairs(Clone)do
		if i~='ClassName'and i~='Parent'then
			NewClass[i]=v
		end
	end
	function Finished()
		self.Classes[Name]=NewClass
	end
	function NewClass:IsInstanceOf(thing)
		if thing=='Base'then return true end
		return self.ClassName==thing
	end
	NewClass.Is=NewClass.IsInstanceOf
	setmetatable(NewClass,{})
	function NewClass:__tostring(...)
		if self then
			if self['ClassName']then
				return"Instance of "..self.ClassName
			else
				return"Instance of nil"
			end
		else
			return"Instance of nil"
		end
	end
	return NewClass,Finished
end
local Base,Finished=Class:NewClass('Base')
Finished()
return Class