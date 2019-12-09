local json = require('json')

local f=string.format
API={
	Data = options.API,
	Endpoints = {
		['DBots_Stats'] = 'https://bots.discord.pw/api/bots/%s/stats',
		['DBotsOrg_Stats'] = 'https://bots.discord.pw/api/bots/%s/stats',
		['Meow'] = 'https://aws.random.cat/meow',
		['Bork'] = 'https://dog.ceo/api/breeds/image/random',
		['Urban'] = 'https://api.urbandictionary.com/v0/define?term=%s',
		['Carbon'] = 'https://www.carbonitex.net/discord/data/botdata.php',
		['dadjoke'] = 'https://icanhazdadjoke.com/',
		['Bing'] = 'https://api.cognitive.microsoft.com/bing/v7.0/search?q=%s',
		['Youtube'] = 'https://www.googleapis.com/youtube/v3/search?key=%s&part=snippet&maxResults=5&q=%s',
	},
	Carbon = {},
	D_Bots = {},
	DBotsOrg = {},
	Misc = {},
	Search = {},
	Stats = {}
}

function API:Post(End,Fmt,...)
	local point
	local p=API.Endpoints[End]
	if p then
		if Fmt then
			point=f(p,table.unpack(Fmt))
		else
			point=p
		end
	end
	return http.request('POST',point,...)
end
function API:Get(End,Fmt,...)
	local point
	local p=API.Endpoints[End]
	if p then
		if Fmt then
			point=f(p,table.unpack(Fmt))
		else
			point=p
		end
	end
	return http.request('GET',point,...)
end
function API.D_Bots:Stats_Update()
	local info={
		server_count=#client.guilds,
	}
	return API:Post('DBots_Stats',{client.user.id},{{"Content-Type","application/json"},{"Authorization",API.Data.DBots_Auth}},json.encode(info))
end
function API.DBotsOrg:Stats_Update()
	local info={
		server_count=#client.guilds,
	}
	return API:Post('DBotsOrg_Stats',{client.user.id},{{"Content-Type","application/json"},{"Authorization",API.Data.DBotsOrg_Auth}},json.encode(info))
end
function API.Carbon:Stats_Update()
	local key=API.Data.Carbon_Key
	if not key then return end
	local info={
		key=key,
		servercount=#client.guilds
	}
	return API:Post('Carbon',nil,{{"Content-Type","application/json"}},json.encode(info))
end
function API.Misc:Cats()
	local requestdata,request=API:Get('Meow')
	if not json.decode(request)then
		return nil,'ERROR: Unable to decode JSON [API.Misc:Cats]'
	end
	return json.decode(request).file
end
function API.Misc:Dogs()
	local requestdata,request=API:Get('Bork')
	if not json.decode(request)then
		return nil,'ERROR: Unable to decode JSON [API.Misc:Dogs]'
	end
	return json.decode(request).message
end
function API.Misc:Joke()
	local request,data=API:Get('dadjoke',nil,{{'User-Agent','luvit'},{'Accept','text/plain'}})
	return data
end
function API.Misc:Urban(input,d)
	if d then
		input=input:sub(1,input:find'/d'-1)
	else
		d=2
	end
	local request=query.urlencode(input)
	if request then
		local technical,data=API:Get('Urban',{request})
		local jdata=json.decode(data)
		if jdata then
			local t=f('Results for: %s\n',input)
			if jdata.list[1]then
				if d then
					local def=0
					for i=1,d do
						if jdata.list[i]then
							t=t..f('**Definition %d:** %s\n',i,jdata.list[i].definition)
							def=i
						end
					end
					t=t..f('**Definitions found: %s**',def)
				end
			else
				t=t..'No definitions found.'
			end
			return t
		else
			return nil,"ERROR: unable to json decode"
		end
	else
		return nil,"ERROR: unable to urlencode"
	end
end
function API.Search:Bing(q)
	if not API.Data.Bing_Key then
		return'No bing search key'
	end
	local request=query.urlencode(q)
	local technical,data=API:Get('Bing',{request},{
		{'Content-Type','application/json'},
		{'Ocp-Apim-Subscription-Key',API.Data.Bing_Key}
	})
	local jsonData=json.decode(data)
	local tx=''
	local n=0
	for i,v in pairs(jsonData.webPages)do
		if n>9 then break end
		tx=tx..f('**Name:** %s\n**URL:** %s\n',tostring(v.name),tostring(v.url))
		n=n+1
	end
	sendMessage(message,{file={'loal.txt',data}})
end
function API.Search:Youtube(q)
	local request=query.urlencode(q)
	local technical,data=API:Get('Youtube',{API.Data.Youtube_Key,request},{
		{'Content-Type','application/json'}
	})
	local jsonData=json.decode(data)
	local tx=''
	
end
function API.Stats:Post()
	local Data=API.Data.Stats
	if Data.Carbon then
		API.Carbon:Stats_Update()
	end
	if Data.D_Bots then
		API.D_Bots:Stats_Update()
	end
	if Data.DBotsOrg then
		API.DBotsOrg:Stats_Update()
	end
end
