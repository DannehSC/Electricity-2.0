Commands={}
function addCommand(name,desc,cmds,rank,multi_arg,func)
	Commands[name]={Name=name,Description=desc,Commands=(type(cmds)=='table'and cmds or{cmds}),Rank=rank,Multi=multi_arg,Function=func}
end