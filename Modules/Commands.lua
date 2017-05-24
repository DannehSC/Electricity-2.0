Commands={}
function addCommand(name,desc,cmds,rank,multi_arg,server_only,func)
	local b,e,n,g=checkArgs({'string','string',{'table','string'},'number','boolean','boolean','function'},{name,desc,cmds,rank,multi_arg,server_only,func})
	--bool, expected, number, got
	if not b then
		error(string.format("Invalid argument #%s to addCommand, %s expected, got %s.",n,e,g))
	end
	Commands[name]={Name=name,Description=desc,Commands=(type(cmds)=='table'and cmds or{cmds}),Rank=rank,Multi=multi_arg,serverOnly=server_only,Function=func}
end
addCommand('Ping','Pings the bot.','ping',0,false,false,function(message,args)
	sendMessage(message,"Pong!")
end)