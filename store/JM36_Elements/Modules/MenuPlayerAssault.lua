local PlayerAssaultOptions	=
{
	--[[{
		Name	=	"Air - Valkyrie - 4 Man",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"valkyrie",
	},]]
	{
		Name	=	"Air - Valkyrie - 2 Man",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"valkyrie",
	},
	{
		Name	=	"Air - Lazer",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"lazer",
	},
	{
		Name	=	"Air - Hydra",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"hydra",
	},
	{
		Name	=	"Ground - Cop Female",
		Type	=	1,
		NPCs	=	{
						"s_f_y_cop_01",
						"s_f_y_cop_01",
					},
		WEPN	=	{
						"weapon_militaryrifle",
						"weapon_machinepistol",
					},
		Veh		=	"police3",
	},
	{
		Name	=	"Ground - Tank",
		Type	=	1,
		NPCs	=	{
						--"u_m_y_juggernaut_01",
						"s_m_m_armoured_02",
					},
		WEPN	=	"weapon_militaryrifle",
		Veh		=	"rhino",
	},
	{
		Name	=	"Ground",
		Type	=	1,
		NPCs	=	{
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						"u_m_y_juggernaut_01",
						--[["s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",]]
					},
		WEPN	=	{
						"weapon_militaryrifle",
						"WEAPON_MINIGUN",
						--"weapon_combatmg",
						"weapon_machinepistol",
					},
		Veh		=	"insurgent3",
	},
}



local RotationToDirection = require'RotationToDirection'
local RequestEntityModel = require'RequestEntityModel'
local players = players
local players_exists = players.exists
local players_user = players.user
--local entities_create_ped = entities.create_ped
local type = type
local memory = memory
local memory_alloc = memory.alloc
local memory_read_vector3 = memory.read_vector3
local memory_read_float = memory.read_float
local memory_write_int = memory.write_int
local memory_free = memory.free
local PlayerAssaultTeamSpawn = setmetatable
(
	{
		[0] = function(PlayerId, Option, Number)
			local PlayerPed = GetPlayerPed(PlayerId)
			local PlayerCoords = GetEntityCoords(PlayerPed, true)
			local PlayerHeading = GetEntityPhysicsHeading(PlayerPed)
			local PlayerRotation = GetEntityRotation(PlayerPed)
			local PlayerDirection = RotationToDirection(PlayerRotation)
			PlayerDirection.x, PlayerDirection.y, PlayerDirection.z = -PlayerDirection.x, -PlayerDirection.y, -PlayerDirection.z
			local MemoryPointer = memory_alloc()
			
			for i=1, Number do -- 250 or 500 + 5 * i
				local VehicleHash = Option.Veh
				if RequestEntityModel(VehicleHash) then
					local Vehicle = CreateVehicle(
						VehicleHash,
						PlayerCoords.x + (PlayerDirection.x * (500 + (25 * i))),
						PlayerCoords.y + (PlayerDirection.y * (500 + (25 * i))),
						PlayerCoords.z + (PlayerDirection.z * (500 + (25 * i))) + 250,
						PlayerHeading,
						true,
						true
					)
					if Vehicle ~= 0 then
						--SetEntityRotation()
						SetVehicleDoorsLocked(Vehicle, 4)
						SetVehicleDoorsLockedForAllPlayers(Vehicle, true) -- unlock for self? nah
						SetVehicleIsConsideredByPlayer(Vehicle, false)
						if GetHasRetractableWheels(Vehicle) then
							RaiseRetractableWheels(Vehicle)
						end
						if DoesVehicleHaveLandingGear(Vehicle) or IsThisModelAPlane(VehicleHash) then
							ControlLandingGear(Vehicle, 4)
						end
						SetEntityCleanupByEngine(Vehicle, true)
						memory_write_int(MemoryPointer, Vehicle)
						SetEntityAsNoLongerNeeded(MemoryPointer)
						
						local NPCs = Option.NPCs
						local WEPN = Option.WEPN
						local _PlayerId = players_user()
						
						do
							local NumPeds = #entities.get_all_peds_as_pointers()
							if NumPeds >= 240 then -- 256 max, 240=128+64+32+16
								menu.trigger_command(Info.MenuOptionsCleanup[4])
							elseif NumPeds >= 224 then
								menu.trigger_command(Info.MenuOptionsCleanup[3])
							end
						end
						
						for i=1, #NPCs do
							local NPC = NPCs[i]
							if RequestEntityModel(NPC) then
								NPC = CreatePedInsideVehicle(Vehicle, 29, NPC, i-2, true, false)
								local SpawnFailed = NPC == 0
								if i == 1 and SpawnFailed then
									print"SpawnFailed :("
									return
								elseif not SpawnFailed then
									SetEntityCleanupByEngine(NPC, true)
									--memory_write_int(MemoryPointer, NPC)
									--SetEntityAsNoLongerNeeded(MemoryPointer)
									
									SetNetworkIdAlwaysExistsForPlayer(NetworkGetNetworkIdFromEntity(NPC), _PlayerId, true)
									SetNetworkIdAlwaysExistsForPlayer(NetworkGetNetworkIdFromEntity(NPC), PlayerId, true)
									--SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(NPC), true)
									
									if type(WEPN)=='table' then
										for i=1, #WEPN do
											GiveWeaponToPed(NPC, WEPN[i], 9999, true, false)
										end
									else
										GiveWeaponToPed(NPC, WEPN, 9999, true, false)
									end
									SetDriveTaskDrivingStyle(NPC, 4981308) -- Ignore roads (Uses local pathing, only works within 200~ meters around the player) - 787004 = false
									SetBlockingOfNonTemporaryEvents(NPC, true)
									--SetPedShootRate(NPC, 5)
									SetPedShootRate(NPC, 1000)
									SetPedAccuracy(NPC, 100)
									SetPedCombatRange(NPC, 2)
									SetPedCombatMovement(NPC, 2)
									TaskCombatHatedTargetsAroundPed(NPC, 1000.0, 0)
									TaskCombatPed(NPC, PlayerPed, 0, 16)
									SetPedKeepTask(NPC, true)
								end
							end
						end
					end
				end
			end
			
			memory_free(MemoryPointer)
		end,
		[1] = function(PlayerId, Option, Number)
			local PlayerPed = GetPlayerPed(PlayerId)
			local PlayerCoords = GetEntityCoords(PlayerPed, true)
			local PlayerHeading = GetEntityPhysicsHeading(PlayerPed)
			local PlayerRotation = GetEntityRotation(PlayerPed)
			local PlayerDirection = RotationToDirection(PlayerRotation)
			--PlayerDirection.x, PlayerDirection.y, PlayerDirection.z = -PlayerDirection.x, -PlayerDirection.y, -PlayerDirection.z
			local MemoryPointer = memory_alloc()
			local MemoryPointer2 = memory_alloc()
			
			for i=1, Number do -- 250 or 500 + 5 * i
				local VehicleHash = Option.Veh
				if RequestEntityModel(VehicleHash) then
					local Coords =
					{
						x	=	PlayerCoords.x + (PlayerDirection.x * (250 + (25 * i))),
						y	=	PlayerCoords.y + (PlayerDirection.y * (250 + (25 * i))),
						z	=	PlayerCoords.z + (PlayerDirection.z * (250 + (25 * i))),
					}
					if GetClosestVehicleNodeWithHeading(
						Coords.x,
						Coords.y,
						Coords.z,
						MemoryPointer,
						MemoryPointer2,
						1,
						3.0,
						0
					) then
						Coords = memory_read_vector3(MemoryPointer)
						--PlayerHeading = (PlayerHeading + memory_read_float(MemoryPointer2)) / 2
						PlayerHeading = memory_read_float(MemoryPointer2)
					end
					local Vehicle = CreateVehicle(
						VehicleHash,
						Coords.x,
						Coords.y,
						Coords.z,
						PlayerHeading,
						true,
						true
					)
					if Vehicle ~= 0 then
						--SetEntityRotation()
--						SetVehicleDoorsLocked(Vehicle, 4)
						SetVehicleDoorsLockedForAllPlayers(Vehicle, true) -- unlock for self? nah
						SetVehicleIsConsideredByPlayer(Vehicle, false)
						if GetHasRetractableWheels(Vehicle) then
							RaiseRetractableWheels(Vehicle)
						end
						if DoesVehicleHaveLandingGear(Vehicle) then
							ControlLandingGear(Vehicle, 4)
						end
						SetVehicleOnGroundProperly(Vehicle, 0.0)
						SetEntityCleanupByEngine(Vehicle, true)
						memory_write_int(MemoryPointer, Vehicle)
						SetEntityAsNoLongerNeeded(MemoryPointer)
						
						local NPCs = Option.NPCs
						local WEPN = Option.WEPN
						local _PlayerId = players_user()
						
						do
							local NumPeds = #entities.get_all_peds_as_pointers()
							if NumPeds >= 240 then -- 256 max, 240=128+64+32+16
								menu.trigger_command(Info.MenuOptionsCleanup[4])
							elseif NumPeds >= 224 then
								menu.trigger_command(Info.MenuOptionsCleanup[3])
							end
						end
						
						for i=1, #NPCs do
							local NPC = NPCs[i]
							if RequestEntityModel(NPC) then
								NPC = CreatePedInsideVehicle(Vehicle, 29, NPC, i-2, true, false)
								local SpawnFailed = NPC == 0
								if i == 1 and SpawnFailed then
									print"SpawnFailed :("
									return
								elseif not SpawnFailed then
									SetEntityCleanupByEngine(NPC, true)
									--memory_write_int(MemoryPointer, NPC)
									--SetEntityAsNoLongerNeeded(MemoryPointer)
									
									SetNetworkIdAlwaysExistsForPlayer(NetworkGetNetworkIdFromEntity(NPC), _PlayerId, true)
									SetNetworkIdAlwaysExistsForPlayer(NetworkGetNetworkIdFromEntity(NPC), PlayerId, true)
									--SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(NPC), true)
									
									if type(WEPN)=='table' then
										for i=1, #WEPN do
											GiveWeaponToPed(NPC, WEPN[i], 9999, true, false)
										end
									else
										GiveWeaponToPed(NPC, WEPN, 9999, true, false)
									end
									SetDriveTaskDrivingStyle(NPC, 4981308) -- 787004
									SetBlockingOfNonTemporaryEvents(NPC, true)
									--SetPedShootRate(NPC, 5)
									SetPedShootRate(NPC, 1000)
									SetPedAccuracy(NPC, 100)
									SetPedCombatRange(NPC, 2)
									SetPedCombatMovement(NPC, 2)
									TaskCombatHatedTargetsAroundPed(NPC, 1000.0, 0)
									TaskCombatPed(NPC, PlayerPed, 0, 16)
									SetPedKeepTask(NPC, true)
								end
							end
						end
					end
				end
			end
			
			memory_free(MemoryPointer)
			memory_free(MemoryPointer2)
		end,
	},
	{
		__call = function(Self, PlayerId, Option, Number)
			if not players_exists(PlayerId) then return end
			Option = PlayerAssaultOptions[Option]
			--Number = Number or 1
			Self[Option.Type](PlayerId, Option, Number)
		end
	}
)
local MenusPlayerRoot = {}
return{
	init	=	function()
					local PlayerAssaultOptions = PlayerAssaultOptions
					local PlayerAssaultOptionsNum = #PlayerAssaultOptions
					do
						local GetHashKey = require'GetHashKey'
						local type = type
						for i=1, PlayerAssaultOptionsNum do
							local PlayerAssaultOption = PlayerAssaultOptions[i]
							do
								local NPCs = PlayerAssaultOption.NPCs
								for j=1, #NPCs do
									NPCs[j] = GetHashKey(NPCs[j])
								end
								--PlayerAssaultOption.NPCs = NPCs
							end
							do
								local WEPN = PlayerAssaultOption.WEPN
								if type(WEPN) == 'table' then
									for j=1, #WEPN do
										WEPN[j] = GetHashKey(WEPN[j])
									end
								else
									--WEPN = GetHashKey(WEPN or "WEAPON_UNARMED")
									PlayerAssaultOption.WEPN = GetHashKey(WEPN or "WEAPON_UNARMED")
								end
								--PlayerAssaultOption.WEPN = WEPN
							end
							PlayerAssaultOption.Veh = GetHashKey(PlayerAssaultOption.Veh)
						end
					end
					
					--Stand Init
					local table_insert = table.insert
					local menu = menu
					local menu_player_root = menu.player_root
					local menu_divider = menu.divider
					local menu_action = menu.action
					local menu_click_slider = menu.click_slider
					players.on_join(function(PlayerId)
						local Menu = menu_player_root(PlayerId)
						local _MenusPlayerRoot = {} MenusPlayerRoot[PlayerId] = _MenusPlayerRoot
						table_insert(_MenusPlayerRoot,
							menu_divider(Menu, "Player Assault")
						)
						for i=1, PlayerAssaultOptionsNum do
							--[[table_insert(_MenusPlayerRoot,
								menu_action(Menu, PlayerAssaultOptions[i].Name, {}, "", function()
									PlayerAssaultTeamSpawn(PlayerId, i, 1)
								end)
							)]]
							table_insert(_MenusPlayerRoot,
								menu_click_slider(Menu, PlayerAssaultOptions[i].Name, {}, "", 1, 50, 3, 1, function(value, click_type)
									if click_type == CLICK_MENU then
										PlayerAssaultTeamSpawn(PlayerId, i, value)
									end
								end)
							)
						end
					end)
					players.dispatch_on_join()
				end,
}