local Alphabet={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
local function Randomize(length)
	length=tonumber(length)
	if not length or not type(length)=='number'then length=25 print('Length must be number.')end
	local txt=''
	for i=1,length do
		local num=math.random(1,2)==1 and true or false
		if num then
			txt=txt..tostring(math.random(0,9))
		else
			local up=math.random(1,2)==1 and true or false
			if up then
				txt=txt..tostring(Alphabet[math.random(1,#Alphabet)])
			else
				txt=txt..tostring((Alphabet[math.random(1,#Alphabet)]):lower())
			end
		end
	end
	return txt
end
return Randomize