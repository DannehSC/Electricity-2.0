API={
	Data={},
	Endpoints={
		['DBots_Stats']='https://bots.discord.pw/api/bots/%s/stats',
		['Meow']='http://random.cat/meow',
		['Bork']='https://dog.ceo/api/breeds/image/random',
		['Urban']='https://api.urbandictionary.com/v0/define?term=%s',
		['Carbon']='https://www.carbonitex.net/discord/data/botdata.php',
	},
	Carbon={},
	DBots={},
	Misc={},
}
pcall(function()
	API.Data=require('./apidata.lua')
end)
function API:Post(End,Fmt,...)
	local point
	local p=API.Endpoints[End]
	if p then
		if Fmt then
			point=p:format(table.unpack(Fmt))
		else
			point=p
		end
	end
	return http.request('POST',point,...)
end
function API:Get(End,Fmt)
	local point
	local p=API.Endpoints[End]
	if p then
		if Fmt then
			point=p:format(table.unpack(Fmt))
		else
			point=p
		end
	end
	return http.request('GET',point)
end
function API.DBots:Stats_Update(info)
	return API:Post('DBots_Stats',{client.user.id},{{"Content-Type","application/json"},{"Authorization",API.Data.DBots_Auth}},json.encode(info))
end
function API.Carbon:Stats_Update(info)
	local key=Data.Carbon_Key
	if not key then return end
	info.key=key
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
function API.Misc:Urban(input,d)
	if d then
		input=input:sub(1,input:find'/d'-1)
	else
		d=2
	end
	local fmt=string.format
	local request=query.urlencode(input)
	if request then
		local technical,data=API:Get('Urban',{request})
		local jdata=json.decode(data)
		if jdata then
			local t=fmt('Results for: %s\n',input)
			if jdata.list[1]then
				if d then
					local def=0
					for i=1,d do
						if jdata.list[i]then
							t=t..fmt('**Definition %d:** %s\n',i,jdata.list[i].definition)
							def=i
						end
					end
					t=t..fmt('**Definitions found: %s**',def)
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