local Radius = 1.5

local RocketNearCoordGuideToEntity = require'RocketNearCoordGuideToEntity'

local RocketObjectHashes = {
	--<Model>
	--tampa3
	"w_lr_rpg_rocket",
	"w_lr_homing_rocket",
	"w_lr_firework_rocket",
--	"w_battle_airmissile_01",--b-11 strikeforce
--	"w_smug_airmissile_01b",--b-11 strikeforce barrage
--	"w_ex_vehiclemissile_3",--oppressor & oppressor2
--	"w_ex_vehiclemissile_1",--"hacker"
--	"w_ex_vehiclemissile_2",--"pounder2 & apc"
--	"w_ex_vehiclemissile_4",--"chernobog"
--	"w_smug_airmissile_02",--"hunter"
}
local RocketObjectHashesNum = #RocketObjectHashes

local GetHashKey = GetHashKey
local WeaponHashes = {
	[GetHashKey("weapon_hominglauncher")] = true,
	[GetHashKey("weapon_rpg")] = true,
	[GetHashKey("weapon_firework")] = true,
}
local WeaponHashesNum = #WeaponHashes

local MenuMissileSAM

local GuidanceAccuracy = 2
local UseRealisticPhysics = true

local util_create_thread = util.create_thread
local util_yield = util.yield

return{
	init	=	function()
					local GetHashKey = GetHashKey
					for i=1, RocketObjectHashesNum do
						RocketObjectHashes[i] = GetHashKey(RocketObjectHashes[i])
					end
					
					local menu = menu
					MenuMissileSAM = menu.list(menu.my_root(), "SAM", {}, "")
					menu.slider(MenuMissileSAM, "SAM Missile Accuracy Multiplier", {}, "SAM Accuracy Multiplier", 1, 10, GuidanceAccuracy, 1, function(value, prev_value, click_type) 
						GuidanceAccuracy = value
					end)
					menu.toggle(MenuMissileSAM, "SAM Missile Uses Realistic Physics", {}, "SAM Uses Realistic Physics", function(state)
						UseRealisticPhysics = state
					end, UseRealisticPhysics)
				end,
	stop	=	function()
					menu.delete(MenuMissileSAM)
				end,
	loop	=	function(Info)
					local Player = Info.Player
					local Vehicle = Player.Vehicle
					if not Vehicle.IsIn then
						local Player_Ped = Player.Ped
						if WeaponHashes[GetSelectedPedWeapon(Player_Ped)] then
							HideHudComponentThisFrame(14)
							
							local TargetTable = Info.Target
							local Target = TargetTable.CollisionA and TargetTable.EntityHitA or TargetTable.CollisionB and TargetTable.EntityHitB
							
							local Player_Id = Player.Id
							SetPlayerHomingRocketDisabled(Player_Id, true)
							
							if IsPlayerFreeAiming(Player_Id) then
								if Target and Target ~= 0 then
									local CamRot = GetFinalRenderedCamRot(2)
									local Coords = GetEntityCoords(Target, true)
									DrawMarker(3,Coords.x,Coords.y,Coords.z,0.0,0.0,0.0,CamRot.x,CamRot.y,0.0,5.0,5.0,5.0,255,255,0,255,false,true,0,false,"helicopterhud","hud_dest",false)
								end
							end
							if IsPedShooting(Player_Ped) then
								util_create_thread(function()
									local PlayerCoords = GetEntityCoords(Player_Ped, false)
									local Rocket = 0
									for i=1, RocketObjectHashesNum do
										Rocket = GetClosestObjectOfType(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Radius, RocketObjectHashes[i], false)
										if Rocket ~= 0 then break end
									end
									
									while DoesEntityExist(Rocket) and (not Target or Target == 0) do
										Target = TargetTable.CollisionA and TargetTable.EntityHitA or TargetTable.CollisionB and TargetTable.EntityHitB
										
										if not Target or Target == 0 then
											util_yield()
										end
									end
									
									if DoesEntityExist(Rocket) and (Target and Target ~= 0) then
										--RocketNearCoordGuideToEntity(GetEntityCoords(Rocket, false), Radius, Target, true, 1)
										RocketNearCoordGuideToEntity(GetEntityCoords(Rocket, false), Radius, Target, UseRealisticPhysics, GuidanceAccuracy)
									end
								end)
							end
						end
					end
				end,
}