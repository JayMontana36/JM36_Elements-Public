local Menu = require'Menu_Vehicle'
local RequestEntityControl = require'RequestEntityControl'

local outPosition, outHeading, PtrMem
local HashCargobob = GetHashKey'cargobob2'
local MenuButton, Cargobob
return{
	init	=	function()
					outPosition, outHeading, PtrMem = memory.alloc(), memory.alloc(), memory.alloc()
					
					local RequestEntityModel = require'RequestEntityModel'
					local Player = Info.Player
					MenuButton = menu.action(Menu, "Create Magnetized Cargobob", {}, "", function()
						local Coords = Player.Coords
						if GetClosestVehicleNodeWithHeading(Coords.x, Coords.y, Coords.z, outPosition, outHeading, 1 or 0 or 8 or 12, 3.0, 0) then
							if RequestEntityModel(HashCargobob) then
								Cargobob = entities.create_vehicle(HashCargobob, memory.read_vector3(outPosition), memory.read_float(outHeading))
								SetVehicleOnGroundProperly(Cargobob, 0.0)
								_0x279D50DE5652D935(Cargobob, true)
								CreatePickUpRopeForCargobob(Cargobob, 1)
								if not DoesCargobobHavePickUpRope(Cargobob) then
									memory.write_int(PtrMem, Cargobob)
									DeleteEntity(PtrMem)
									print'RAGE failed to perform a simple task, try again later elsewhere.'
									return
								end
								SetCargobobPickupMagnetActive(Cargobob, true)
								--SetCargobobPickupMagnetPullRopeLength(Cargobob, 0.0) -- Not As Advertised
								--SetPickupRopeLengthForCargobob(Cargobob, 100.0, 100.0, true) -- Glitchy And Shrinks After Some Time
								--SetCargobobPickupMagnetEffectRadius(Cargobob, 12.5)
								SetCargobobPickupMagnetEffectRadius(Cargobob, 6.25)
								--SetCargobobPickupMagnetPullStrength(Cargobob, 25.0) -- Probably Remove Because Too Much Suction
								--SetCargobobPickupMagnetStrength(Cargobob, 250.0) -- Too Much Suction
								SetCargobobPickupRopeDampingMultiplier(Cargobob, 1000000.0) -- Try To Prevent Collisions
								SetEntityCleanupByEngine(Cargobob, true)
								memory.write_int(PtrMem, Cargobob)
								SetEntityAsNoLongerNeeded(PtrMem)
								SetNewWaypoint(Coords.x, Coords.y)
							end
						end
					end)
				end,
	loop	=	function(Info)
					local Vehicle = Info.Player.Vehicle
					if Vehicle.IsIn and Vehicle.IsOp and Vehicle.Id == Cargobob then
						RequestEntityControl(GetVehicleAttachedToCargobob(Cargobob))
					end
				end,
	stop	=	function()
					local memory_free = memory.free
					memory_free(outPosition) memory_free(outHeading) memory_free(PtrMem)
					outPosition, outHeading, PtrMem = nil, nil, nil
					menu.delete(MenuButton)
				end,
}