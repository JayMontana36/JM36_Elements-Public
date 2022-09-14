return{
	join	=	function(PlayerId)
					local GetVehiclePedIsIn <const> = GetVehiclePedIsIn
					local GetPlayerPed <const> = GetPlayerPed
					local RequestEntityControl <const> = require'RequestEntityControl'
					local NetworkGetNetworkIdFromEntity <const> = NetworkGetNetworkIdFromEntity
					local GetEntityCoords <const> = GetEntityCoords
					local SetNetworkIdCanMigrate <const> = SetNetworkIdCanMigrate
					local DisableVehicleWorldCollision <const> = DisableVehicleWorldCollision
					menu.action(menu.player_root(PlayerId), "Phase Vehicle Through World Collision", {}, "", function()
						local Vehicle <const> = GetVehiclePedIsIn(GetPlayerPed(PlayerId), false)
						local Vehicle <const> = Vehicle ~= 0 and Vehicle
						if Vehicle and RequestEntityControl(Vehicle) then
							local _Vehicle <const> = NetworkGetNetworkIdFromEntity(Vehicle)
							local VehicleTargetZ <const> = GetEntityCoords(Vehicle, false).z - 5.0
							local yield <const> = util.yield
							while GetEntityCoords(Vehicle, false).z > VehicleTargetZ do
								SetNetworkIdCanMigrate(_Vehicle, false)
								DisableVehicleWorldCollision(Vehicle)
								yield()
							end
							SetNetworkIdCanMigrate(_Vehicle, true)
						end
					end)
				end
}