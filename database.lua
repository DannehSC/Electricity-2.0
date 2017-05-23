local function timeStamp()
	return os.date("%I:%M:%S %p - %a, %b %d")
end
return{
	Databases={},
	Default={
		['Settings']={
		
		},
		['Ignore']=function(guild)
			if not guild then return end
			if guild['guild']then
				guild=guild.guild
			end
			local e,ret=pcall(function()
				local tab={}
				for textChannel in guild.textChannels do
					tab[textChannel.name]=false
				end
				return tab
			end)
			if not e then
				print("[IGNORE DEFAULT] ERROR | "..tostring(ret).." | GUILD NAME: "..tostring(guild.name).." | GUILD ID: "..tostring(guild.id))
				return{}
			else
				return ret
			end
		end,
		['Bans']={['000000']='test#0000'},
		['Cases']={['Case: 0']={Time=tostring(timeStamp()),Moderator='test#0000',ModeratorId='000000',Reason='Setting up the case database.',Case='Mute'}},
		['Roles']={['default']={name='Default',id='00000000'}},
		['Votes']={},
		['Mutes']={},
	},
}