local JM36 <const> = JM36
local yield <const> = JM36.yield
local CreateThread <const> = JM36.CreateThread

local GuidanceAccuracyMultiplierForVehicles <const> = setmetatable
(
	{
		--[GetHashKey"rhino"] = 10.0
	},
	{
		__index = function() return 1.0 end
	}
)

local config
CreateThread(function()
	
	local RocketObjectHashes <const> = {
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
	local RocketObjectHashesNum <const> = #RocketObjectHashes
	local TargetTable <const> = Info.Target
	local Radius <const> = 25.0
	local GuidanceAccuracy <const> = 1
	local UseRealisticPhysics <const> = true
	
--	local Vehicle_Id_WeaponBones <const> = {}
--	local Vehicle_Id_Last
	
	local RocketNearCoordGuideToEntity <const> = require'RocketNearCoordGuideToEntity'
	local PtrMem <const> = require'Memory_SharedIntegerPointerSingle'
	local memory_read_int <const> = memory.read_int
	local CreateThread <const> = util.create_thread
	local IsPedShooting <const> = IsPedShooting
	local GetVehicleLockOnTarget <const> = GetVehicleLockOnTarget
	local GetEntityCoords <const> = GetEntityCoords
	local config <const> = config
	local Info <const> = Info
	local Player <const> = Info.Player
	local Vehicle <const> = Player.Vehicle
	local yield <const> = yield
	while true do
		if Info.RocketGuidanceEnabled then
			local Player_Ped <const> = Player.Ped
			if Vehicle.IsIn and IsPedShooting(Player_Ped) then
				local Vehicle_Id <const> = Vehicle.Id
--				if Vehicle_Id ~= Vehicle_Id_Last then
--					Vehicle_Id_Last = Vehicle_Id
--					
--				end
				if GetVehicleLockOnTarget(Vehicle_Id, PtrMem) then
					CreateThread(RocketNearCoordGuideToEntity, GetEntityCoords(Vehicle_Id, false), 25.0, memory_read_int(PtrMem), config.Realistic, config.Accuracy)
				elseif GetCurrentPedVehicleWeapon(Player_Ped, PtrMem) then
					local Weapon <const> = memory_read_int(PtrMem)
					if GetWeaponDamageType(Weapon) == 5 then -- explosive (RPG, Railgun, grenade)
						local TimeTerm <const> = Info.Time+1000
						util.create_thread(function()
							local Rockets <const> = Info.Rockets
							
							local Rocket
							while not Rocket and Info.Time <= TimeTerm do
								for i=1, #Rockets do
									local RocketTable <const> = Rockets[i]
									if RocketTable[2] < Radius and not IsEntityAMissionEntity(RocketTable[1]) then
										Rocket = RocketTable
										break
									end
								end
								if not Rocket then
									util.yield()
								end
							end
							
--							print("RocketFound: ", Rocket)
							
							if Rocket then
								local _Rocket <const> = Rocket[1]
								local Target = 0
								while DoesEntityExist(_Rocket) and Target == 0 do
									Target = TargetTable.CollisionA and TargetTable.EntityHitA or TargetTable.CollisionB and TargetTable.EntityHitB
									if not Target or Target == 0 then
										util.yield()
									end
								end
								
								if DoesEntityExist(_Rocket) and (Target and Target ~= 0) then
									RocketNearCoordGuideToEntity(Rocket[3], Radius, Target, UseRealisticPhysics, GuidanceAccuracy*GuidanceAccuracyMultiplierForVehicles[Vehicle.Model])
								end
							end
						end)
					end
				end
			end
		end
		yield()
	end
end)

local Menu
return
{
	init	=	function()
					local menu <const> = menu
					
					Menu = menu.list(require'Menu_Rocket', "Vehicle Homing Rocket Tuning", {}, "")
					local Menu <const> = Menu
					
					do
						config = configFileRead("RocketGuidance_VehicleHoming.ini") local config <const> = config
						config.Accuracy = tonumber(config.Accuracy or 1)
						if config.Realistic == nil then
							config.Realistic = true
						else
							config.Realistic = toboolean(config.Realistic)
						end
					end
					
					menu.slider(Menu, "Guidance Accuracy Multiplier", {}, "Rocket Guidance Accuracy Multiplier For Vehicle Homing Rockets", 1, 10, config.Accuracy, 1, function(value, prev_value, click_type)
						config.Accuracy = value
					end)
					menu.toggle(Menu, "Guidance Uses Realistic Physics", {}, "Rocket Guidance Uses Realistic Physics For Vehicle Homing Rockets", function(state)
						config.Realistic = state
					end, config.Realistic)
				end,
	stop	=	function()
					configFileWrite("RocketGuidance_VehicleHoming.ini", config)
					menu.delete(Menu)
				end,
}