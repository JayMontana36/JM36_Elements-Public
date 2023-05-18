local yield = JM36.yield_once

local players_get_name = players.get_name

local GetPlayerPed = GetPlayerPedScriptIndex--GetPlayerPed

local Players = {[0]=false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false} -- 0-31
Info.Players = Players

JM36.CreateThread(function()
	while true do
		for i=0,31 do
			if Players[i] then
				Players[i].Ped = GetPlayerPed(i)
			end
		end
		yield()
	end
end)

players.add_command_hook(function(PlayerId,PlayerRoot)
	Players[PlayerId] = {Name=players_get_name(PlayerId),Root=PlayerRoot,Ped=GetPlayerPed(i)}
end)
players.on_leave(function(PlayerId)
	Players[PlayerId] = false
end)