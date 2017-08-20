local http=require('coro-http')
local dhttp={}
local retries={}
function dhttp.request(...)
	local tab={...}
	local data,err=pcall(function()
		return{http.request(unpack(tab))}
	end)
	if not data then
		local dat=tostring(tab[2])
		if not retries[dat]then
			retries[dat]=1
		else
			retries[dat]=retries[dat]+1
		end
		local inf=retries[dat]
		if inf==5 then
			print("[DHTTP Error] Error in request:\nRetry limit exceeded.\nError:\n"..err)
			retries[dat]=0
			return{reason=err}
		else
			print("[DHTTP Error] Error in request:\n"..err.."\nRetrying. ["..tostring(inf).."]")
			return dhttp.request(...)
		end
	else
		return err[1],err[2]
	end
end
function dhttp.parseUrl(...)
	local data,err=pcall(http.parseUrl,...)
	if not data then
		print("[DHTTP Error] Error in parseUrl:\n"..err)
	else
		return err
	end
end
function dhttp.getConnection(...)
	local data,err=pcall(http.getConnection,...)
	if not data then
		print("[DHTTP Error] Error in getConnection:\n"..err)
		return dhttp.getConnection(...)
	else
		return err
	end
end
function dhttp.saveConnection(...)
	local data,err=pcall(http.saveConnection,...)
	if not data then
		print("[DHTTP Error] Error in saveConnection:\n"..err)
		return dhttp.saveConnection(...)
	else
		return err
	end
end
function dhttp.createServer(...)
	local data,err=pcall(http.createServer,...)
	if not data then
		print("[DHTTP Error] Error in createServer:\n"..err)
		return dhttp.createServer(...)
	else
		return data
	end
end
return dhttp
