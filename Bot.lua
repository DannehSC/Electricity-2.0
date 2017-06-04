token=''
hooks={}
pcall(function()
	token=require('./token')
	hooks=require('./hooks')
end)
fs=require('fs')
discordia=require('discordia')
client=discordia.Client({fetchMembers=true})
uptime=discordia.Stopwatch()
function FFB(t)--format for beta
	if beta==true then
		return t..'_B'
	else
		return t
	end
end
function loadModule(name)
	name=name..'.lua'
	local data,others=fs.readFileSync('Modules/'..name)
	if data then
		local a,b=loadstring(data)
		if not a then
			print("<SYNTAX> ERROR LOADING "..name.."\nERROR:"..b)
			if sendLog then
				sendLog(hooks[FFB('Errors')],"MODULE SYNTAX",string.format("MODULE NAME: %s\nERROR: %s",name,tostring(b)))
			end
			return false
		else
			setfenv(a,getfenv())
			local c,d=pcall(a)
			if not c then
				print("<RUNTIME> ERROR LOADING "..name.."\nERROR:"..d)
				if sendLog then
					sendLog(hooks[FFB('Errors')],"MODULE RUNTIME",string.format("MODULE NAME: %s\nERROR: %s",name,tostring(d)))
				end
				return false
			end
		end
	else
		print("<LOADING> ERROR LOADING "..name.."\nERROR:"..tostring(data),tostring(others))
		if sendLog then
			sendLog(hooks[FFB('Errors')],"MODULE LOADING",string.format("MODULE NAME: %s\nERROR: %s",name,tostring(data)..'\n'..tostring(others)))
		end
		return false
	end
end
loadModule('Functions')
loadModule('Database')
loadModule('Commands')
loadModule('Events')
loadModule('API')
client:on('messageCreate',Events.messageCreate)
client:on('ready',Events.ready)
client:run(token)