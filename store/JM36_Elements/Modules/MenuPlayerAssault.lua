local PlayerAssaultOptions <const> =
{
	{
		Name	=	"Air - Valkyrie - 2 Man",
		Type	=	0,
		NPCs	=	{
						"s_m_m_armoured_02",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"valkyrie",
	},
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
		Name	=	"Air - Lazer",
		Type	=	0,
		NPCs	=	{
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"lazer",
	},
	{
		Name	=	"Air - Hydra",
		Type	=	0,
		NPCs	=	{
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"hydra",
	},
	{
		Name	=	"Air - Strikeforce B-11",
		Type	=	0,
		NPCs	=	{
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"strikeforce",
	},
	{
		Name	=	"Air - Starling",
		Type	=	0,
		NPCs	=	{
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"starling",
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
						"s_m_m_armoured_02",
					},
		WEPN	=	"weapon_militaryrifle",
		Veh		=	"rhino",
	},
	--[[{
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
					},
		WEPN	=	{
						"weapon_militaryrifle",
						"WEAPON_MINIGUN",
						"weapon_machinepistol",
					},
		Veh		=	"insurgent3",
	},]]
}
local PlayerAssaultOptionsNum <const> = #PlayerAssaultOptions



local DummyV3 = require'DummyV3'
local RotationToDirection = require'RotationToDirection'
local RequestEntityModel = require'RequestEntityModel'
local players = players
local players_exists = players.exists
local players_user = players.user
--local entities_create_ped = entities.create_ped
local type = type
local memory = memory
--local memory_alloc = memory.alloc
local memory_alloc = memory.alloc_int
local memory_read_vector3 = memory.read_vector3
local memory_read_float = memory.read_float
local memory_write_int = memory.write_int
local memory_free = memory.free

local SpawnedPeds <const> = {}

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
						
						SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Vehicle), true)
						
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
						
						local MemPtr <const> = memory_alloc()
						OpenSequenceTask(MemPtr)
						TaskCombatHatedTargetsAroundPed(0, 1000.0, 0)
						AddVehicleSubtaskAttackPed(0, PlayerPed)
						TaskCombatPed(0, PlayerPed, 0, 16)
						local _MemPtr <const> = memory.read_int(MemPtr)
						SetSequenceToRepeat(_MemPtr, true)
						CloseSequenceTask(_MemPtr)
						
						for i=1, #NPCs do
							local NPC = NPCs[i]
							if RequestEntityModel(NPC) then
								--NPC = CreatePedInsideVehicle(Vehicle, 29, NPC, i-2, true, false)
								NPC = entities.create_ped(29, NPC, DummyV3, 0.0)
								SetPedIntoVehicle(NPC, Vehicle, i-2)
								--TaskWarpPedIntoVehicle(NPC, Vehicle, i-2)
								local SpawnFailed = NPC == 0
								if i == 1 and SpawnFailed then
									print"SpawnFailed :("
									return
								elseif not SpawnFailed then
									do
										local EntityNetworkHandle <const> = NetworkGetNetworkIdFromEntity(NPC)
										if NetworkDoesNetworkIdExist(EntityNetworkHandle) then
											SpawnedPeds[#SpawnedPeds+1] = {EntityNetworkHandle,true,PlayerId}
										else
											SpawnedPeds[#SpawnedPeds+1] = {NPC,false,PlayerId}
										end
									end
									
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
--									SetPedCombatMovement(NPC, 2)
									SetPedCombatMovement(NPC, 3)
--									TaskCombatHatedTargetsAroundPed(NPC, 1000.0, 0)
--									TaskCombatPed(NPC, PlayerPed, 0, 16)
--									SetPedKeepTask(NPC, true)
--									SetPedCanRagdoll(NPC, false)
--									SetPedCanRagdollFromPlayerImpact(NPC, false)
									SetRagdollBlockingFlags(NPC, 7)
									SetPedConfigFlag(NPC, 2, true) -- CPED_CONFIG_FLAG_NoCriticalHits
									SetPedConfigFlag(NPC, 7, true) -- CPED_CONFIG_FLAG_UpperBodyDamageAnimsOnly
								--	SetPedConfigFlag(NPC, 33, false) -- CPED_CONFIG_FLAG_DieWhenRagdoll 
									SetPedConfigFlag(NPC, 42, true) -- CPED_CONFIG_FLAG_DontInfluenceWantedLevel
									SetPedConfigFlag(NPC, 43, true) -- CPED_CONFIG_FLAG_DisablePlayerLockon
--									SetPedConfigFlag(NPC, 48, true) -- CPED_CONFIG_FLAG_BlockWeaponSwitching
								--	SetPedConfigFlag(NPC, 128, true) -- CPED_CONFIG_FLAG_CanBeAgitated
--									SetPedConfigFlag(NPC, 183, true) -- CPED_CONFIG_FLAG_IsAgitated
									SetPedConfigFlag(NPC, 229, true) -- CPED_CONFIG_FLAG_AvoidTearGas
									SetPedConfigFlag(NPC, 234, true) -- CPED_CONFIG_FLAG_DisableHomingMissileLockon
--									SetPedConfigFlag(NPC, 234, false) -- CPED_CONFIG_FLAG_CanBeIncapacitated
									TaskPerformSequence(NPC, _MemPtr)
								end
							end
						end
						ClearSequenceTask(MemPtr)
						--SetEntityVelocity(Vehicle, 0.0, 100.0/1.9438444924, 0.0)
						ApplyForceToEntityCenterOfMass(Vehicle, 1, 0.0, 100.0/1.9438444924, 25.0/1.9438444924, false, true, true, true)
						if GetHasRetractableWheels(Vehicle) then
							RaiseRetractableWheels(Vehicle)
						end
						if DoesVehicleHaveLandingGear(Vehicle) or IsThisModelAPlane(VehicleHash) then
							ControlLandingGear(Vehicle, 4)
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
						
						SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Vehicle), true)
						
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
						
						local MemPtr <const> = memory_alloc()
						OpenSequenceTask(MemPtr)
						TaskCombatHatedTargetsAroundPed(0, 1000.0, 0)
						AddVehicleSubtaskAttackPed(0, PlayerPed)
						TaskCombatPed(0, PlayerPed, 0, 16)
						local _MemPtr <const> = memory.read_int(MemPtr)
						SetSequenceToRepeat(_MemPtr, true)
						CloseSequenceTask(_MemPtr)
						
						for i=1, #NPCs do
							local NPC = NPCs[i]
							if RequestEntityModel(NPC) then
								--NPC = CreatePedInsideVehicle(Vehicle, 29, NPC, i-2, true, false)
								NPC = entities.create_ped(29, NPC, DummyV3, 0.0)
								SetPedIntoVehicle(NPC, Vehicle, i-2)
								--TaskWarpPedIntoVehicle(NPC, Vehicle, i-2)
								local SpawnFailed = NPC == 0
								if i == 1 and SpawnFailed then
									print"SpawnFailed :("
									return
								elseif not SpawnFailed then
									do
										local EntityNetworkHandle <const> = NetworkGetNetworkIdFromEntity(NPC)
										if NetworkDoesNetworkIdExist(EntityNetworkHandle) then
											SpawnedPeds[#SpawnedPeds+1] = {EntityNetworkHandle,true,PlayerId}
										else
											SpawnedPeds[#SpawnedPeds+1] = {NPC,false,PlayerId}
										end
									end
									
									
									
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
--									TaskCombatHatedTargetsAroundPed(NPC, 1000.0, 0)
--									TaskCombatPed(NPC, PlayerPed, 0, 16)
--									SetPedKeepTask(NPC, true)
--									SetPedCanRagdoll(NPC, false)
--									SetPedCanRagdollFromPlayerImpact(NPC, false)
									SetRagdollBlockingFlags(NPC, 7)
									SetPedConfigFlag(NPC, 2, true) -- CPED_CONFIG_FLAG_NoCriticalHits
									SetPedConfigFlag(NPC, 7, true) -- CPED_CONFIG_FLAG_UpperBodyDamageAnimsOnly
								--	SetPedConfigFlag(NPC, 33, false) -- CPED_CONFIG_FLAG_DieWhenRagdoll 
									SetPedConfigFlag(NPC, 42, true) -- CPED_CONFIG_FLAG_DontInfluenceWantedLevel
									SetPedConfigFlag(NPC, 43, true) -- CPED_CONFIG_FLAG_DisablePlayerLockon
--									SetPedConfigFlag(NPC, 48, true) -- CPED_CONFIG_FLAG_BlockWeaponSwitching
								--	SetPedConfigFlag(NPC, 128, true) -- CPED_CONFIG_FLAG_CanBeAgitated
--									SetPedConfigFlag(NPC, 183, true) -- CPED_CONFIG_FLAG_IsAgitated
									SetPedConfigFlag(NPC, 229, true) -- CPED_CONFIG_FLAG_AvoidTearGas
									SetPedConfigFlag(NPC, 234, true) -- CPED_CONFIG_FLAG_DisableHomingMissileLockon
--									SetPedConfigFlag(NPC, 234, false) -- CPED_CONFIG_FLAG_CanBeIncapacitated
									TaskPerformSequence(NPC, _MemPtr)
								end
							end
						end
						ClearSequenceTask(MemPtr)
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

local Join
do
	
	--Stand Init
					local table_insert = table.insert
					local menu = menu
					local menu_player_root = menu.player_root
					local menu_divider = menu.divider
					local menu_action = menu.action
					local menu_click_slider = menu.click_slider
					Join = function(PlayerId)
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
					end
end

local DoesEntityExist <const> = require'DoesEntityExist'
return{
	init	=	function()
					local PlayerAssaultOptions = PlayerAssaultOptions
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
				end,
	join	=	Join,
	loop	=	function()
					local j, n <const> = 1, #SpawnedPeds
					for i=1,n do
						local SpawnedPedTable <const> = SpawnedPeds[i]
						local SpawnedPed <const>, SpawnedPedIsNetId <const>, SpawnedPedTarget <const> = SpawnedPedTable[1], SpawnedPedTable[2], players_exists(SpawnedPedTable[3])
						
						local ShouldKeep = 
							(
								SpawnedPedIsNetId and NetworkDoesNetworkIdExist(SpawnedPed)
							)
							or
							(
								not SpawnedPedIsNetId and DoesEntityExist(SpawnedPed)
							)
						if ShouldKeep and SpawnedPedIsNetId and NetworkDoesEntityExistWithNetworkId(SpawnedPed) then
							ShouldKeep = not IsEntityDead(NetworkGetEntityFromNetworkId(SpawnedPed))
						end
						
						
						
						if ShouldKeep then
							if SpawnedPedIsNetId then
								SetNetworkIdCanMigrate(SpawnedPed, false)
							end
							if i ~= j then
								SpawnedPeds[j] = SpawnedPeds[i]
								SpawnedPeds[i] = nil
							end
							j = j + 1
						else
							SpawnedPeds[i] = nil
							util.create_thread(function()
								if SpawnedPedIsNetId then
									while NetworkDoesNetworkIdExist(SpawnedPed) and not NetworkDoesEntityExistWithNetworkId(SpawnedPed) do
										NetworkRequestControlOfNetworkId(SpawnedPed)
										util.yield()
									end
									if NetworkDoesNetworkIdExist(SpawnedPed) and NetworkDoesEntityExistWithNetworkId(SpawnedPed) and NetworkRequestControlOfNetworkId(SpawnedPed) then
										SetNetworkIdCanMigrate(SpawnedPed, false)
										local SpawnedPed <const> = NetworkGetEntityFromNetworkId(SpawnedPed)
										--entities.delete_by_handle(SpawnedPed)
										local MemoryPointer <const> = memory_alloc()
										memory_write_int(MemoryPointer, SpawnedPed)
										SetEntityAsNoLongerNeeded(MemoryPointer)
										--RemovePedElegantly(MemoryPointer)
									end
								else
									if DoesEntityExist(SpawnedPed) then
										local MemoryPointer <const> = memory_alloc()
										memory_write_int(MemoryPointer, SpawnedPed)
										RemovePedElegantly(MemoryPointer)
									end
								end
							end)
						end
					end
				end,
}