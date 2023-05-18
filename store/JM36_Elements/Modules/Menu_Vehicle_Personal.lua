local DummyCmdTbl = _G2.DummyCmdTbl
local Menu = Info.MenuLayout.Vehicle:list("Personal Vehicle Options", DummyCmdTbl, "")

local CreateThread = JM36.CreateThread
local yield = JM36.yield
local Player = Info.Player
local Vehicle = Player.Vehicle

local setmetatable = setmetatable

local util_spoof_script = util.spoof_script
local memory_alloc = memory.alloc
local memory_write_int = memory.write_int

local DoesEntityExist = DoesEntityExist
local NETWORK_IS_ACTIVITY_SESSION = NETWORK_IS_ACTIVITY_SESSION
local IS_ENTITY_A_MISSION_ENTITY = IS_ENTITY_A_MISSION_ENTITY
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local LockDoorsWhenNoLongerNeeded = LockDoorsWhenNoLongerNeeded
local DecorRemove = DecorRemove
local NetworkHashFromPlayerHandle = NetworkHashFromPlayerHandle
local DecorSetInt = DecorSetInt
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local DoesBlipExist = DoesBlipExist
local SetEntityAsNoLongerNeeded = SetEntityAsNoLongerNeeded
local RemoveBlip = RemoveBlip
local SetVehicleExclusiveDriver = SetVehicleExclusiveDriver
local SET_VEHICLE_AI_CAN_USE_EXCLUSIVE_SEATS = SET_VEHICLE_AI_CAN_USE_EXCLUSIVE_SEATS
local SetVehicleDoorsLocked = SetVehicleDoorsLocked
local SET_VEHICLE_KEEP_ENGINE_ON_WHEN_ABANDONED = SET_VEHICLE_KEEP_ENGINE_ON_WHEN_ABANDONED
local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local SetVehicleEngineOn = SetVehicleEngineOn
local GetBlipFromEntity = GetBlipFromEntity
local AddBlipForEntity = AddBlipForEntity
local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
local EndTextCommandSetBlipName = EndTextCommandSetBlipName
local SetBlipSprite = SetBlipSprite
local ShowHeadingIndicatorOnBlip = ShowHeadingIndicatorOnBlip
local SetBlipAsMinimalOnEdge = SetBlipAsMinimalOnEdge

local BlipNameLabel = util.register_label"Elements Personal Vehicle"

local VehicleSettings =
{
	ExclusiveDriver = true,
	EngineAlawysOn = false,
	DoorsLocked = false,
	BlipVehicle = true,
}
local VehiclePersonal;VehiclePersonal =
{
	New						=	function(Self,HandleScript)
									if DoesEntityExist(HandleScript) then -- if RequestEntityControl(HandleScript) then
										if not (NETWORK_IS_ACTIVITY_SESSION() and IS_ENTITY_A_MISSION_ENTITY(HandleScript)) then
											util_spoof_script("main_persistent",function()
												SetEntityAsMissionEntity(HandleScript,false,true)
												--LockDoorsWhenNoLongerNeeded(HandleScript)
												DecorRemove(HandleScript,"Previous_Owner")
												
												local _NetworkHashFromPlayerHandle = NetworkHashFromPlayerHandle(Player.Id)
												DecorSetInt(HandleScript, "Player_Vehicle", _NetworkHashFromPlayerHandle)
												DecorSetInt(HandleScript, "PYV_Owner", _NetworkHashFromPlayerHandle)
												DecorSetInt(HandleScript, "PYV_Vehicle", _NetworkHashFromPlayerHandle)
												DecorSetInt(HandleScript, "Veh_Modded_By_Player", _NetworkHashFromPlayerHandle)
											end)
										end
										return setmetatable
										(
											{
												HandleScript	=	HandleScript,
												HandleNetwork	=	NetworkGetNetworkIdFromEntity(HandleScript),
												HandleBlip		=	0,
											},
											Self
										)
									end
								end,
	__gc					=	function(Self)
									local ExistsEntity, ExistsBlip = DoesEntityExist(Self.HandleScript), DoesBlipExist(Self.HandleBlip)
									if ExistsEntity or ExistsBlip then
										util_spoof_script("main_persistent",function()
											local MemPtr = memory_alloc(8)
											if ExistsEntity then
												memory_write_int(MemPtr,Self.HandleScript)
												SetEntityAsNoLongerNeeded(MemPtr)
											end
											if ExistsBlip then
												memory_write_int(MemPtr,Self.HandleBlip)
												RemoveBlip(MemPtr)
											end
										end)
									end
								end,
	__index					=	function(Self,Key)
									return VehiclePersonal[Key]
								end,
	SetAsExclusiveDriver	=	function(Self,Bool)
									SetVehicleExclusiveDriver(Self.HandleScript, Bool ? Player.Ped : 0, 0)
									SET_VEHICLE_AI_CAN_USE_EXCLUSIVE_SEATS(Self.HandleScript, not Bool)
								end,
	LockDoors				=	function(Self,Bool)
									SetVehicleDoorsLocked(Self.HandleScript, Bool ? 2 : 1)
								end,
	SetEngineOn				=	function(Self,Bool,Keep,Init)
									SET_VEHICLE_KEEP_ENGINE_ON_WHEN_ABANDONED(Self.HandleScript, Bool)
									if Init and not Bool and GetIsVehicleEngineRunning(Self.HandleScript) then return end
									SetVehicleEngineOn(Self.HandleScript, Bool, false, Keep)
								end,
	Blip					=	function(Self,Bool,Init)
									if Bool then
										local Blip = GetBlipFromEntity(Self.HandleScript);if Blip == 0 then Blip = AddBlipForEntity(Self.HandleScript) end
										BeginTextCommandSetBlipName(BlipNameLabel)
										EndTextCommandSetBlipName(Blip)
										SetBlipSprite(Blip, 794)
										ShowHeadingIndicatorOnBlip(Blip, true)
										SetBlipAsMinimalOnEdge(Blip, true)
										Self.HandleBlip = Blip
										return
									end
									if Init then return end
									if DoesBlipExist(Self.HandleBlip) then
										RemoveBlip(Self.HandleBlip)
										Self.HandleBlip = nil
									end
								end,
	--[[SetAsNotNeeded			=	function(Self,MemPtr)
									MemPtr = MemPtr or memory_alloc(8)
									memory_write_int(MemPtr,Self.HandleScript)
									SetEntityAsNoLongerNeeded(MemPtr)
								end,]]
}
setmetatable(VehiclePersonal,VehicleSettings)



local LastPersonalVehicle



do
	local DummyCmdTbl = DummyCmdTbl
	--local Settings = Menu:list("Settings", DummyCmdTbl, "")
	Menu:action("Set Vehicle", DummyCmdTbl, "Sets your current vehicle as your personal vehicle. If you already have a personal vehicle set then this will override your selection.", function()
		local Vehicle_IsUsing = Vehicle.IsUsing
		if LastPersonalVehicle and LastPersonalVehicle.HandleScript == Vehicle_IsUsing then return end
		if LastPersonalVehicle and not Vehicle.IsIn then LastPersonalVehicle = nil end
		if Vehicle_IsUsing ~= 0 then
			LastPersonalVehicle = VehiclePersonal:New(Vehicle_IsUsing)
			if LastPersonalVehicle then
				LastPersonalVehicle:SetAsExclusiveDriver(VehicleSettings.ExclusiveDriver)
				LastPersonalVehicle:LockDoors(VehicleSettings.DoorsLocked)
				LastPersonalVehicle:SetEngineOn(VehicleSettings.EngineAlawysOn,false,true)
				LastPersonalVehicle:Blip(VehicleSettings.BlipVehicle,true)
			end
		end
	end)
	
	Menu:toggle("Engine On", DummyCmdTbl, "Sets your engines on/off.", function(State)
		VehicleSettings.EngineAlawysOn = State
		if LastPersonalVehicle then
			LastPersonalVehicle:SetEngineOn(State,true,false)
		end
	end, true) -- Leave Default True
	
	Menu:toggle("Only(I)Drives", DummyCmdTbl, "OnlyDrives: Makes it so that only you can drive; stupid naming, I know.", function(State)
		VehicleSettings.ExclusiveDriver = State
		if LastPersonalVehicle then
			LastPersonalVehicle:SetAsExclusiveDriver(State)
		end
	end, VehicleSettings.ExclusiveDriver)
	
	Menu:toggle("Entry Allowed", DummyCmdTbl, "Allows others on/in.", function(State)
		VehicleSettings.DoorsLocked = not State
		if LastPersonalVehicle then
			LastPersonalVehicle:LockDoors(not State)
		end
	end, not VehicleSettings.DoorsLocked)
	
	Menu:toggle("Enable Tracking", DummyCmdTbl, "Marks (Blips) on map.", function(State)
		VehicleSettings.BlipVehicle = State
		if LastPersonalVehicle then
			LastPersonalVehicle:Blip(State)
		end
	end, VehicleSettings.BlipVehicle)
	
	-- Add "Respawn" Option
	
	-- Add Booby Trap Option | Bait/Kill
	
	-- Add Lights Option
	
	-- Add Windows Option
	
	-- Add Kick Passengers Option
	
	-- Add Sound Horn Option
	
	-- Add Trigger Alarm Option
	
	-- Add Random Drive Option
end



