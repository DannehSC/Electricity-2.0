API={
	Data={},
	Endpoints={
		['DBots_Stats']={E='https://bots.discord.pw/api/bots/%s/stats',F=true},
	},
}
pcall(function()
	API.Data=require('./apidata.lua')
end)
function API:Post(End,...)
	local point
	local p=API.Endpoints[End]
	if p then
		if p.F then
			point=p.E:format(client.user.id)
		else
			point=p.E
		end
	end
	http.request('POST',point,...)
end
API.DBots={}
function API.DBots:Stats_Update(info)
	
end