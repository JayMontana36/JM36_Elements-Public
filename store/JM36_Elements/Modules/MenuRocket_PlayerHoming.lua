local RocketObjectHashes = require'HashesRockets_Array'()

local WeaponHashes
do
	local GetHashKey = GetHashKey
	WeaponHashes =
	{
		[GetHashKey("weapon_hominglauncher")] = true,
		[GetHashKey("weapon_rpg")] = true,
		[GetHashKey("weapon_firework")] = true,
	}
end

local MenuList

local config

local Accuracy, Realistic

local RocketNearCoordGuideToEntity = require'RocketNearCoordGuideToEntity'
local util_create_thread, util_yield
do
	local util = util
	util_create_thread = util.create_thread
	util_yield = util.yield
end

local CreateThread <const> = JM36.CreateThread
CreateThread(function()
	local memory_read_int <const> = memory.read_int
	local MemPtr = require'Memory_SharedIntegerPointerSingle'
	
	local Info <const> = Info
	local Player <const> = Info.Player
	local Vehicle <const> = Player.Vehicle
	local TargetTable <const> = Info.Target
	local Rockets <const> = Info.Rockets
	
	--local Radius <const> = 1.5
	local Radius <const> = 5.0
	local GuidanceAccuracy <const> = 1
	local UseRealisticPhysics <const> = true
	
	local yield <const> = JM36.yield
	while true do
		if not Vehicle.IsIn then
			local Player_Ped = Player.Ped
			if WeaponHashes[GetSelectedPedWeapon(Player_Ped)] then
				--HideHudComponentThisFrame(14)
				
				local Target = TargetTable.CollisionA and TargetTable.EntityHitA or TargetTable.CollisionB and TargetTable.EntityHitB
				
				local Player_Id <const> = Player.Id
				--SetPlayerHomingRocketDisabled(Player_Id, true)
				
				if IsPlayerFreeAiming(Player_Id) and Target and Target ~= 0 then
					local CamRot <const> = GetFinalRenderedCamRot(2)
					local Coords <const> = GetEntityCoords(Target, true)
					DrawMarker(3,Coords.x,Coords.y,Coords.z,0.0,0.0,0.0,CamRot.x,CamRot.y,0.0,5.0,5.0,5.0,255,255,0,255,false,true,0,false,"helicopterhud","hud_dest",false)
				end
				if IsPedShooting(Player_Ped) then
					CreateThread(function()
						local Rocket
						for i=1, #Rockets do
							local RocketTable <const> = Rockets[i]
							if RocketTable[2] < Radius and not IsEntityAMissionEntity(RocketTable[1]) then
								Rocket = RocketTable
								break
							end
						end
						
						if Rocket then
							local _Rocket <const> = Rocket[1]
							while DoesEntityExist(_Rocket) and (not Target or Target == 0) do
								yield()
								Target = TargetTable.CollisionA and TargetTable.EntityHitA or TargetTable.CollisionB and TargetTable.EntityHitB
								if (not Target or Target == 0) and GetPlayerTargetEntity(Player_Id, MemPtr) then
									Target = memory_read_int(MemPtr)
								end
							end
							if DoesEntityExist(_Rocket) and (Target and Target ~= 0) then
								RocketNearCoordGuideToEntity(Rocket[3], Radius, Target, UseRealisticPhysics, GuidanceAccuracy)
							end
						end
					end)
				end
			end
		end
		yield()
	end
end)

return{
	init	=	function()
					local Menu = require'Menu_Rocket'
					local menu = menu
					MenuList = menu.list(Menu, "Player Rocket Tuning", {}, "")
					local MenuList = MenuList
					
					do
						config = configFileRead("RocketGuidance_Player.ini")
						local config = config
						Accuracy = tonumber(config.Accuracy or 2)
						if config.Realistic == nil then
							Realistic = true
						else
							Realistic = toboolean(config.Realistic)
						end
					end
					
					menu.slider(MenuList, "Guidance Accuracy Multiplier", {}, "Rocket Guidance Accuracy Multiplier For Player Rockets", 1, 10, Accuracy, 1, function(value, prev_value, click_type) 
						Accuracy = value
						config.Accuracy = value
					end)
					menu.toggle(MenuList, "Guidance Uses Realistic Physics", {}, "Rocket Guidance Uses Realistic Physics For Player Rockets", function(state)
						Realistic = state
						config.Realistic = state
					end, Realistic)
				end,
	stop	=	function()
					configFileWrite("RocketGuidance_Player.ini", config)
					menu.delete(MenuList)
				end,
}