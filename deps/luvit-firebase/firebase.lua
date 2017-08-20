local firebase = {}
firebase.__index = firebase

local json = require("json")
local http = require("coro-http")
local timer = require("timer")

setmetatable(firebase,{
    __call = function(self,root,auth)
    return setmetatable({
      root = root,
      auth = auth
    },self)
end})

local function checkThread()
    return pcall(timer.sleep,1)
end

function firebase:request(node,method,callback,content)
    local root = self.root
    root = root:gsub("https://","")
    root = root:gsub("http://","")
    root = root:gsub("www.","")
    local url = "https://"..root..".firebaseio.com/"..node..".json?auth="..self.auth
    local headers,body = http.request(method,url,{{"Content-Type","application/json"}},content)
    if checkThread() then
        return headers.code ~= 200 and body,json.parse(body)
    else
        coroutine.wrap(function()
            if callback then
                callback(headers.code ~= 200 and body,body)
            end
        end)()
    end
end

function firebase:get(node,callback)
    return self:request(node,"GET",callback)
end

function firebase:set(node,content,callback)
    content = type(content) == "table" and json.encode(content) or content
    return self:request(node,"PUT",callback,content)
end

function firebase:update(node,content,callback)
    content = type(content) == "table" and json.encode(content) or content
    return self:request(node,"PATCH",callback,content)
end

function firebase:push(node,content,callback)
    content = type(content) == "table" and json.encode(content) or content
    return self:request(node,"POST",callback,content)
end

function firebase:delete(node,callback)
    return self:request(node,"DELETE",callback)
end

return firebase