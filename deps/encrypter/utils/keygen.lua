local Randomizer=require("./randomizer.lua")
local function keygen()
	local txt=''
	for i=1,4 do
		txt=txt..Randomizer(50)
	end
	return txt
end
return keygen