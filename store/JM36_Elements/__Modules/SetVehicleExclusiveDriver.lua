local Player <const> = Info.Player
local SetNetworkIdCanMigrate <const> = SetNetworkIdCanMigrate
local SetVehicleExclusiveDriver <const> = SetVehicleExclusiveDriver
local _0x41062318F23ED854 <const> = _0x41062318F23ED854

return function(HandleVehEnt, HandleVehNet, State, Ped)
	SetNetworkIdCanMigrate(HandleVehNet, not State)
	SetVehicleExclusiveDriver(HandleVehEnt, State and (Ped or Player.Ped) or 0, 1)
	_0x41062318F23ED854(HandleVehEnt, State)
end