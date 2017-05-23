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
	local a,b=pcall(coroutine.wrap(function()
		http.request("POST",hook,{{"Content-Type","application/json"}},json.encode(post))
	end))
	print(a,b)
end