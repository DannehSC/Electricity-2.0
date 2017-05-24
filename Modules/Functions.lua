mutex=discordia.Mutex()
http=require("coro-http")
json=require("json")
function timeStamp()
	return os.date("%I:%M:%S %p - %a, %b %d")
end
function sendLog(hook,title,description,color)
	if not hook then print"NO HOOK"return end
	local post
	if type(title)=='table'then
		title.color=color
		post={embeds={title}}
	else
		post={embeds={{title=title,description=description,color=color}}}
	end
	coroutine.wrap(function()
		mutex:lock()
		http.request("POST",hook,{{"Content-Type","application/json"}},json.encode(post))
		mutex:unlockAfter(1500)
	end)()
end
function checkArgs(types,vals)
	for i,v in pairs(types)do
		if type(v)=='table'then
			local t1=true
			if type(vals[i])~=v[1] then
				t1=false
			end
			if t1==false then
				if type(vals[i])~=v[2] then
					return false,v,i,type(vals[i])
				end
			end
		else
			if type(vals[i])~=v then
				return false,v,i,type(vals[i])
			end
		end
	end
	return true,'',#vals
end
function embed()
	--todo
end
function sendMessage(obj,con,emb)
	if emb then
		con={embed=con}
	end
	if obj.reply then
		obj:reply(con)
	elseif obj.sendMessage then
		obj:sendMessage(con)
	end
end