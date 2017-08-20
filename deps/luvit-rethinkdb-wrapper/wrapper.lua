local http,json=require('coro-http'),require('json')
local rethink={}
local fmt=string.format
local function checkCoroutine()
	local thread,bool=coroutine.running()
	return bool==false and true
end
function rethink:post(query,data,callback)
	if data==nil then error('[WRAPPER] no data provided')end
	if checkCoroutine()then
		local js=(type(data)=='table'and json.encode(data))or data
		if js then
			local res,data=http.request('POST',fmt("%s://%s:5000/%s?key=%s",self.method,self.ip,query,self.key),{{"Content-Type","application/json"}},js)
			if data=='null'then
				return'null',nil
			end
			local tab=json.decode(data)or{error="[WRAPPER] JSON decoding error"}
			if tab.error or tab.first_error then
				local err=(tab.error or tab.first_error)
				if self.print then print(err)end
				return nil,err
			else
				return tab,nil
			end
		else
			if self.print then print("[WRAPPER] JSON encoding error")end
			return nil,'JSON encoding error'
		end
	else
		coroutine.wrap(function()
			callback=callback or function()end
			local js=json.encode(data)
			if js then
				local res,data=http.request('POST',fmt("%s://%s:5000/%s?key=%s",self.method,self.ip,query,self.key),{{"Content-Type","application/json"}},js)
				if data=='null'then
					return callback('null',nil)
				end
				local tab=json.decode(data)or{error="[WRAPPER] JSON decoding error"}
				if tab.error or tab.first_error then
					local err=(tab.error or tab.first_error)
					if self.print then print(err)end
					callback(nil,err)
				else
					callback(tab,nil)
				end
			else
				if self.print then print("[WRAPPER] JSON encoding error")end
				callback(nil,"JSON encoding error")
			end
		end)()
	end
end
function rethink:get(query,callback)
	if checkCoroutine()then
		local res,data=http.request('GET',fmt("%s://%s:5000/%s?key=%s",self.method,self.ip,query,self.key))
		if data=='null'then
			return'null',nil
		end
		local tab=json.decode(data)or{error="[WRAPPER] JSON decoding error"}
		if tab.error or tab.first_error then
			local err=(tab.error or tab.first_error)
			if self.print then print(err)end
			return nil,err
		else
			return tab,nil
		end
	else
		coroutine.wrap(function()
			callback=callback or function()end
			local res,data=http.request('GET',fmt("%s://%s:5000/%s?key=%s",self.method,self.ip,query,self.key))
			if data=='null'then
				return callback('null',nil)
			end
			local tab=json.decode(data)or{error="[WRAPPER] JSON decoding error"}
			if tab.error or tab.first_error then
				local err=(tab.error or tab.first_error)
				if self.print then print(err)end
				callback(nil,err)
			else
				callback(tab,nil)
			end
		end)()
	end
end
function rethink:delete(query,callback)
	if checkCoroutine()then
		local res,data=http.request('DELETE',fmt("%s://%s:5000/%s?key=%s",self.method,self.ip,query,self.key))
		if data=='null'then
			return'null',nil
		end
		local tab=json.decode(data)or{error="JSON decoding error"}
		if tab.error or tab.first_error then
			local err=(tab.error or tab.first_error)
			if self.print then print(err)end
			return nil,err
		else
			return tab,nil
		end
	else
		coroutine.wrap(function()
			callback=callback or function()end
			local res,data=http.request('DELETE',fmt("%s://%s:5000/%s?key=%s",self.method,self.ip,query,self.key))
			if data=='null'then
				return callback('null',nil)
			end
			local tab=json.decode(data)or{error="JSON decoding error"}
			if tab.error or tab.first_error then
				local err=(tab.error or tab.first_error)
				if self.print then print(err)end
				callback(nil,err)
			else
				callback(tab,nil)
			end
		end)()
	end
end
return function(ip,secure,key,prin)
	rethink.ip=ip
	rethink.key=key or"KEY_HERE"
	rethink.method=secure and"https"or"http"
	rethink.print=prin or false
	return rethink
end