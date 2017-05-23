local token=require('./token')
timer=require('timer')
fs=require('fs')
discordia=require('discordia')
client=discordia.Client({fetchMembers=true})
function loadModule(name)
	name=name..'.lua'
	local data,others=fs.readFileSync('Modules/'..name)
	if data then
		local a,b=loadstring(data)
		if not a then 
			print("<SYNTAX> ERROR LOADING "..name.."\nERROR:"..b)
			return false
		else
			setfenv(a,getfenv())
			local c,d=pcall(a)
			if not c then
				print("<RUNTIME> ERROR LOADING "..name.."\nERROR:"..d)
				return false
			end
		end
	else
		print("<LOADING DATA> ERROR LOADING "..name.."\nERROR:"..tostring(data),tostring(others))
		return false
	end
end
loadModule('Functions')
loadModule('Commands')
loadModule('Database')
loadModule('Events')