local PlayerAssaultOptions <const> =
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
		Name	=	"Air - Strikeforce B-11",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"strikeforce",
	},
	{
		Name	=	"Air - Starling",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"starling",
	},
	{
		Name	=	"Air - Glider (Ultralight/Microlight)",
		Type	=	0,
		NPCs	=	{
						--"s_m_m_armoured_01",
						"s_m_m_armoured_02",
					},
		WEPN	=	"WEAPON_UNARMED",
		Veh		=	"microlight",
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
local PlayerAssaultOptionsNum <const> = #PlayerAssaultOptions



-- 4981308 = Ignore roads (Uses local pathing, only works within 200~ meters around the player)
-- 787004 = Same as above but use roads instead of local pathing and always works
local DrivingStyle <const> = 4981308
-- 0 - Stationary (Will just stand in place)  
-- 1 - Defensive (Will try to find cover and very likely to blind fire)  
-- 2 - Offensive (Will attempt to charge at enemy but take cover as well)  
-- 3 - Suicidal Offensive (Will try to flank enemy in a suicidal attack)
local CombatMovement <const> = 2
--[[local PedConfigFlags <const> =
{
	
}]]



local Player = Info.Player
local RequestEntityModel <const> = require'RequestEntityModel'

local SpawnVehicles <const> = function(VehicleHash, VehicleCoords, VehicleNum)
	local Vehicles, VehiclesNum = {}, 0
	if RequestEntityModel(VehicleHash, 45000) then
		local VehicleDimensions = v3.new() -- temp dimensions max
		local VehicleSpawnCoords = v3.new() -- temp dimensions min
		do
			GetModelDimensions(VehicleHash, VehicleSpawnCoords, VehicleDimensions)
			VehicleDimensions:sub(VehicleSpawnCoords)
			VehicleDimensions:mul(1.5)
		end
		local ItsAnAircraft = IsThisModelAPlane(VehicleHash) or IsThisModelAHeli(VehicleHash)
		for i=1, VehicleNum do
			local Vehicle
			if GetNthClosestVehicleNode(VehicleCoords, (9+i)*5, VehicleSpawnCoords, 1, 3.0, 0) then
				local VehicleHeading = VehicleSpawnCoords:lookAt(VehicleCoords):toDir():getHeading()
				if ItsAnAircraft then
					VehicleSpawnCoords.z = VehicleSpawnCoords.z + 500
				end
				Vehicle = CreateVehicle
				(
					VehicleHash,
					VehicleSpawnCoords,
					VehicleHeading,
					true,
					true
				)
			else
				VehicleSpawnCoords:set(VehicleCoords.x,VehicleCoords.y,VehicleCoords.z)
				for j=1,i do
					VehicleSpawnCoords:add(VehicleDimensions)
				end
				local VehicleHeading = VehicleSpawnCoords:lookAt(VehicleCoords):toDir():getHeading()
				if ItsAnAircraft then
					VehicleSpawnCoords.z = VehicleSpawnCoords.z + 500
				end
				Vehicle = CreateVehicle
				(
					VehicleHash,
					VehicleSpawnCoords,
					VehicleHeading,
					true,
					true
				)
			end
			if Vehicle ~= 0 then
				VehiclesNum+=1
				Vehicles[VehiclesNum] = Vehicle
			else
				for j=1, VehiclesNum do
					entities.delete_by_handle(Vehicles[j])
					Vehicles[j] = nil
				end
				VehiclesNum = 0
				print"Failed spawning vehicles, pool likely full"
				break
			end
		end
	end
	do
		local MemPtr = memory.alloc_int()
		for i=1, VehiclesNum do
			local Vehicle = Vehicles[i]
			
			SetNetworkIdExistsOnAllMachines(Vehicle, true)
			
			SetVehicleModKit(Vehicle, 0)
			for ModType=0,49 do
				local Max = GetNumVehicleMods(Vehicle, ModType) - 1
				SetVehicleMod(Vehicle, ModType, Max, true--[[CustomWheels]])
			end
			ToggleVehicleMod(Vehicle, 18, true) -- Turbo
			
			SetVehicleDoorsLocked(Vehicle, 4)
			SetVehicleDoorsLockedForAllPlayers(Vehicle, true) -- unlock for self? nah
			SetVehicleIsConsideredByPlayer(Vehicle, false)
			
			SetVehicleEngineOn(Vehicle, true, true, false)
			
			SetEntityCleanupByEngine(Vehicle, true)
			memory.write_int(MemPtr, Vehicle)
			SetEntityAsNoLongerNeeded(MemPtr)
			
			JM36.CreateThread(function()
				local VehNet = VehToNet(Veh)
				while DoesEntityExist(Veh) and VehNet == 0 do
					JM36.yield()
					VehNet = VehToNet(Veh)
				end
				if VehNet ~= 0 then
					SetNetworkIdExistsOnAllMachines(VehNet, true)
				end
			end)
		end
	end
	JM36.CreateThread(function()
		for i=1, VehiclesNum do
			local Vehicle = Vehicles[i]
			if GetHasRetractableWheels(Vehicle) then
				RaiseRetractableWheels(Vehicle)
			end
			if DoesVehicleHaveLandingGear(Vehicle) then
				ControlLandingGear(Vehicle, 4)
			end
			NetworkFadeInEntity(Vehicle, true, true)
		end
	end)
	return Vehicles, VehiclesNum
end

local SpawnPedsForVehicles <const> = function(PedHashArray, PedNum, PedHashArrayNum)
	local Peds, PedsNum = {}, 0
	
	local DummyCoords = v3.new()
	
	PedHashArrayNum = PedHashArrayNum or #PedHashArray
	for i=1, PedNum do
		for j=1, PedHashArrayNum do
			local PedHash = PedHashArray[j]
			if RequestEntityModel(PedHash, 45000) then
				local Ped = CreatePed
				(
					29,
					PedHash,
					DummyCoords,
					0.0,
					true,
					true
				)
				if Ped ~= 0 then
					PedsNum+=1
					Peds[PedsNum] = Ped
				else
					for j=1, PedsNum do
						entities.delete_by_handle(Peds[j])
						Peds[j] = nil
					end
					PedsNum = 0
					print"Failed spawning peds, pool likely full"
					break
				end
			end
		end
	end
	for i=1, PedsNum do
		local Ped = Peds[i]
		
		SetEntityCleanupByEngine(Ped, true)
		
		JM36.CreateThread(function()
			local PedNet = PedToNet(Ped)
			while DoesEntityExist(Ped) and PedNet == 0 do
				JM36.yield()
				PedNet = PedToNet(Ped)
			end
			if PedNet ~= 0 then
				SetNetworkIdExistsOnAllMachines(PedNet, true)
			end
		end)
	end
	return Peds, PedsNum
end

local SpawnAssault <const> = function(TargetPlayerId, Option, TotalNumber, Invincible)
	if not players.exists(TargetPlayerId) then return end
	Option = PlayerAssaultOptions[Option]
	
	local PlayerCoords = TargetPlayerId ~= Player.Id and NetworkGetPlayerCoords(TargetPlayerId) or Player.Coords
	
	local Vehicles, VehiclesNum = SpawnVehicles(Option.Veh, PlayerCoords, TotalNumber)
	if VehiclesNum == 0 then return end
	
	local Peds, PedsNum
	local NPCsNum
	do
		local NPCs = Option.NPCs
		NPCsNum = #NPCs
		Peds, PedsNum = SpawnPedsForVehicles(NPCs, TotalNumber, NPCsNum)
	end
	if PedsNum == 0 then return end
	
	local TargetPlayerPed = GetPlayerPed(TargetPlayerId)
	
	local TaskSequenceMem = memory.alloc_int()
	OpenSequenceTask(TaskSequenceMem)
	
	do
		--TaskSetBlockingOfNonTemporaryEvents(0, false)
		TaskCombatHatedTargetsAroundPed(0, 1000.0, 0)
		--TaskSetBlockingOfNonTemporaryEvents(0, true)
		AddVehicleSubtaskAttackPed(0, TargetPlayerPed)
		TaskCombatPed(0, TargetPlayerPed, 0, 16)
		TaskSetBlockingOfNonTemporaryEvents(0, false)
	end
	
	local TaskSequenceInt = memory.read_int(TaskSequenceMem)
	SetSequenceToRepeat(TaskSequenceInt, true)
	CloseSequenceTask(TaskSequenceInt)
	
	
	
	local WEPN = Option.WEPN
	
	
	
	local h = 0
	for i=1, VehiclesNum do
		local Vehicle = Vehicles[i]
		SetEntityInvincible(Vehicle, Invincible)
		
		for j=1, NPCsNum do
			h+=1
			local Ped = Peds[h]
			SetPedIntoVehicle(Ped, Vehicle, j-2)
			SetEntityLoadCollisionFlag(Ped, true)
			SetEntityInvincible(Ped, Invincible)
			SetPedRelationshipGroupHash(Ped, GetHashKey"cop")
			
			
			
			if type(WEPN)=='table' then
				for k=1, #WEPN do
					GiveWeaponToPed(Ped, WEPN[k], 9999, true, false)
				end
			else
				GiveWeaponToPed(Ped, WEPN, 9999, true, false)
			end
			
			
			
			SetDriveTaskDrivingStyle(Ped, DrivingStyle)
			--SetBlockingOfNonTemporaryEvents(Ped, true)
			SetBlockingOfNonTemporaryEvents(Ped, false)
			SetPedShootRate(Ped, 1000)
			SetPedAccuracy(Ped, 100)
			SetPedCombatRange(Ped, 2)
			SetPedCombatMovement(Ped, CombatMovement)
			
			SetPedCanRagdoll(Ped, false)
			SetPedCanRagdollFromPlayerImpact(Ped, false)
			
			SetRagdollBlockingFlags(Ped, 1)
			SetRagdollBlockingFlags(Ped, 2)
			SetRagdollBlockingFlags(Ped, 4)
			
			SetPedConfigFlag(Ped, 2, true) -- CPED_CONFIG_FLAG_NoCriticalHits
			SetPedConfigFlag(Ped, 7, true) -- CPED_CONFIG_FLAG_UpperBodyDamageAnimsOnly
			--SetPedConfigFlag(Ped, 33, false) -- CPED_CONFIG_FLAG_DieWhenRagdoll 
			SetPedConfigFlag(Ped, 42, true) -- CPED_CONFIG_FLAG_DontInfluenceWantedLevel
			SetPedConfigFlag(Ped, 43, true) -- CPED_CONFIG_FLAG_DisablePlayerLockon
--			SetPedConfigFlag(Ped, 48, true) -- CPED_CONFIG_FLAG_BlockWeaponSwitching
			--SetPedConfigFlag(Ped, 128, true) -- CPED_CONFIG_FLAG_CanBeAgitated
--			SetPedConfigFlag(Ped, 183, true) -- CPED_CONFIG_FLAG_IsAgitated
			SetPedConfigFlag(Ped, 229, true) -- CPED_CONFIG_FLAG_AvoidTearGas
			SetPedConfigFlag(Ped, 234, true) -- CPED_CONFIG_FLAG_DisableHomingMissileLockon
--			SetPedConfigFlag(Ped, 234, false) -- CPED_CONFIG_FLAG_CanBeIncapacitated
			
			
			
			TaskPerformSequence(Ped, TaskSequenceInt)
			SetPedKeepTask(Ped, true)
		end
	end
	
	ClearSequenceTask(TaskSequenceMem)
	
	--[[for i=1, VehiclesNum do
		local Vehicle = Vehicles[i]
		local TargetPlayerVeh = GetVehiclePedIsUsing(TargetPlayerPed)
		if TargetPlayerVeh ~= 0 then
			local PlayerVehVelocity <const> = GetEntityVelocity(TargetPlayerVeh)
			PlayerVehVelocity:mul(1.25)
			SetEntityVelocity(Vehicle, PlayerVehVelocity.x, PlayerVehVelocity.y, PlayerVehVelocity.z)
		else
			local PlayerPedVelocity_x <const>, PlayerPedVelocity_y <const>, PlayerPedVelocity_z <const> = v3.get(GetEntityVelocity(PlayerPed))
			if PlayerPedVelocity_x == 0 or PlayerPedVelocity_y == 0 or PlayerPedVelocity_z == 0 then
				ApplyForceToEntityCenterOfMass(Vehicle, 1, 0.0, 100.0/1.9438444924, 25.0/1.9438444924, false, true, true, true)
			else
				ApplyForceToEntityCenterOfMass(Vehicle, 1, PlayerPedVelocity_x, PlayerPedVelocity_y, PlayerPedVelocity_z, false, true, true, true)
			end
		end
	end]]
end

local SpawnedPeds = {}
JM36.CreateThread(function()
	while true do
		JM36.yield()
	end
end)
local DummyTable = {}
return{
	init	=	function()
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
				end,
	join	=	function(PlayerId)
					local MenuAssault = menu.list
					(
						menu.player_root(PlayerId),
						"Player Assault",
						DummyTable,
						""
						-- optional function
					)
					local SpawnInvincible = false
					for i=1, PlayerAssaultOptionsNum do
						menu.click_slider(MenuAssault, PlayerAssaultOptions[i].Name, DummyTable, "", 1, 50, 3, 1, function(value, click_type)
							if click_type == CLICK_MENU then
								SpawnAssault(PlayerId, i, value, SpawnInvincible)
							end
						end)
					end
				end,
}

-- SET_PED_COMBAT_RANGE SET_PED_SEEING_RANGE