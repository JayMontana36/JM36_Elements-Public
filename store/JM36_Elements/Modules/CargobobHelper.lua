local Info = Info

local Player = Info.Player
local Vehicle = Player.Vehicle

local memory_alloc = memory.alloc
local entities_create_vehicle = entities.create_vehicle
local memory_read_float = memory.read_float

local SetHeliCanPickupEntityThatHasPickUpDisabled = SetHeliCanPickupEntityThatHasPickUpDisabled
local DoesCargobobHavePickUpRope = DoesCargobobHavePickUpRope
local DoesCargobobHavePickupMagnet = DoesCargobobHavePickupMagnet
local GetVehicleAttachedToCargobob = GetVehicleAttachedToCargobob
local SetVehicleCheatPowerIncrease = SetVehicleCheatPowerIncrease
local SetCargobobPickupMagnetSetAmbientMode = SetCargobobPickupMagnetSetAmbientMode
local SetCargobobPickupRopeType = SetCargobobPickupRopeType
local SetPickupRopeLengthWithoutCreatingRopeForCargobob = SetPickupRopeLengthWithoutCreatingRopeForCargobob
local SetVehicleStrong = SetVehicleStrong
local SetVehicleExplodesOnHighExplosionDamage = SetVehicleExplodesOnHighExplosionDamage
local IsEntityInAir = IsEntityInAir
local GetModelDimensions = GetModelDimensions
local GetClosestVehicleNodeWithHeading = GetClosestVehicleNodeWithHeading
local IsSphereVisible = IsSphereVisible
local IsSphereVisibleToAnotherMachine = IsSphereVisibleToAnotherMachine
local GetNthClosestVehicleNodeWithHeading = GetNthClosestVehicleNodeWithHeading
local SetNewWaypoint = SetNewWaypoint

local RequestEntityModel = require'RequestEntityModel'
local RegisterEntityNetworked = require'RegisterEntityNetworked'

local yield = JM36.yield_once

local math_huge = math.huge
local math_max = math.max

local Cargobobs =
{
	[GetHashKey"cargobob"]	= true,
	[GetHashKey"cargobob2"]	= true,
	[GetHashKey"cargobob3"]	= true,
	[GetHashKey"cargobob4"]	= true,
}
local HashCargobob = GetHashKey"cargobob2"

local Enabled

JM36.CreateThread(function()
	while true do
		if Enabled and Cargobobs[Vehicle.Model] and Vehicle.IsIn and Vehicle.IsOp then
			local Cargobob = Vehicle.HandleScript
			SetHeliCanPickupEntityThatHasPickUpDisabled(Cargobob,true)
			
			--SET_CARGOBOB_FORCE_DONT_DETACH_VEHICLE
			
			--GET_ATTACHED_PICK_UP_HOOK_POSITION
			
			--SetCargobobPickupMagnetActive(Cargobob, true)
			--SetCargobobPickupMagnetPullStrength(Cargobob, math.huge) -- Set how strongly the magnet pulls itself towards the nearest entity.
			--SetCargobobPickupMagnetSetTargetedMode(Cargobob,0) -- Set the magnet to only affect the given entity.
			
			local UsingHook, UsingMagnet = DoesCargobobHavePickUpRope(Cargobob), DoesCargobobHavePickupMagnet(Cargobob)
			if UsingHook or UsingMagnet then
				local VehicleAttached = GetVehicleAttachedToCargobob(Cargobob)
				if UsingMagnet then
					--SetCargobobPickupMagnetEnsurePickupEntityUpright(Cargobob,true) -- Set whether an entity that is picked up by the magnet will always blend to an upright position after getting attached. -- fucks everything up in regards to detaching
					--SetPickupRopeLengthForCargobob(25.0,50.0,false) -- detach,attach,instant -- doesn't work
					--SetCargobobPickupRopeDampingMultiplier(Cargobob, math_huge) -- Specifiy a multiplier that modifies the strength of the damping force applied to the entity attached to the pick-up rope. -- too high and it fucks with the magnet/rope
					--SetCargobobPickupMagnetStrength(Cargobob, 8.0) -- Set the overall strength of the magnet force that is applied to the entity that is being picked up. -- too high and it's bad
					if VehicleAttached ~= 0 then
						--print("CB Ent:", VehicleAttached)
						SetVehicleCheatPowerIncrease(Cargobob, 100.0)
						--StabiliseEntityAttachedToHeli(Cargobob,VehicleAttached,10.0) -- fucks everything up in regards to detaching
						--SET_VEHICLE_GRAVITY(Cargobob,false) -- fucks up movements
					else
						SetVehicleCheatPowerIncrease(Cargobob, 1.0)
						SetCargobobPickupMagnetSetAmbientMode(Cargobob,true,true) -- Set the magnet to affect all vehicles and/or objects.
					end
				end
			else
				--SetPickupRopeLengthWithoutCreatingRopeForCargobob(Cargobob,25.0,50.0) -- detach,attach -- doesn't work
				--[[if IsEntityInAir(Cargobob) and GetEntityHeightAboveGround(Cargobob) >= 10.0 then
					CreatePickUpRopeForCargobob(Cargobob,1) -- 1=Magnet,0=Hook
					SetPickupRopeLengthForCargobob(2.5,5.0,false) -- detach,attach,instant -- doesn't work
				end]]
				SetCargobobPickupRopeType(Cargobob,1) -- 1=Magnet,0=Hook
				SetPickupRopeLengthWithoutCreatingRopeForCargobob(Cargobob,1.0,10.0) -- detach,attach -- doesn't work but might be required to use for magnet
				--SetPickupRopeLengthWithoutCreatingRopeForCargobob(Cargobob,25.0,50.0) -- detach,attach -- doesn't work
				SetVehicleStrong(Cargobob, true)
				SetVehicleExplodesOnHighExplosionDamage(Cargobob, false)
			end
		end
		yield()
	end
end)

local DummyCmdTbl = _G2.DummyCmdTbl
local Menu = Info.MenuLayout.Vehicle:list("Cargobob - Magnet", DummyCmdTbl, "")
Menu:toggle("Enable (Magnetic) Cargobob Helper", DummyCmdTbl, "Makes all new unused cargobobs you operate both magnetic and less deadly.", function(on)
	Enabled = on
end)
Menu:action("Create Magnetized Cargobob - Safe", DummyCmdTbl, "Nullsub - Currently does nothing.", function()
	--FIND_SPAWN_COORDINATES_FOR_HELI
end)
Menu:action("Create Magnetized Cargobob - Nearby", DummyCmdTbl, "", function()
	if RequestEntityModel(HashCargobob) then
		local Coords = Player.Coords
		
		local IsInAir = IsEntityInAir(Player.Ped)
		local Coords_Z = IsInAir ? -100.0 : Coords.z
		local p6 = IsInAir ? 0.0 : 3.0
		
		local SpawnRadius, SpawnCoords, SpawnHeading = GetModelDimensions(HashCargobob)
		SpawnHeading:sub(SpawnCoords)
		SpawnRadius = math_max(SpawnHeading.x, SpawnHeading.y, SpawnHeading.z)
		
		if not (GetClosestVehicleNodeWithHeading(Coords.x, Coords.y, Coords_Z, SpawnCoords, SpawnHeading, 1, p6, 0.0) and not (IsSphereVisible(SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, SpawnRadius) or IsSphereVisibleToAnotherMachine(SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, SpawnRadius))) then
			local _ = memory_alloc(8)
			for i=5, 500, 10 do
				if GetNthClosestVehicleNodeWithHeading(Coords.x, Coords.y, Coords_Z, i, SpawnCoords, SpawnHeading, _, 1, p6, 0.0) and not (IsSphereVisible(SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, SpawnRadius) or IsSphereVisibleToAnotherMachine(SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, SpawnRadius))) then break end
			end
		end
		
		local Cargobob = entities_create_vehicle(HashCargobob, SpawnCoords, memory_read_float(SpawnHeading))
		if Cargobob ~= 0 then
			RegisterEntityNetworked(Cargobob, true, true, false, true, false, true)
			SetHeliCanPickupEntityThatHasPickUpDisabled(Cargobob,true)
			SetVehicleCheatPowerIncrease(Cargobob, 100.0)
			SetCargobobPickupRopeType(Cargobob,1) -- 1=Magnet,0=Hook
			SetPickupRopeLengthWithoutCreatingRopeForCargobob(Cargobob,1.0,10.0) -- detach,attach -- doesn't work but might be required to use for magnet
			SetVehicleStrong(Cargobob, true)
			SetVehicleExplodesOnHighExplosionDamage(Cargobob, false)
			SetNewWaypoint(SpawnCoords.x, SpawnCoords.y)
		end
	end
end)
