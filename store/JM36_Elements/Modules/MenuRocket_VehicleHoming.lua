local JM36 <const> = JM36
local yield <const> = JM36.yield
local CreateThread <const> = JM36.CreateThread

local config
CreateThread(function()
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
			if Vehicle.IsIn then
				local Vehicle_Id <const> = Vehicle.Id
				if IsPedShooting(Player.Ped) and GetVehicleLockOnTarget(Vehicle_Id, PtrMem) then
					CreateThread(RocketNearCoordGuideToEntity, GetEntityCoords(Vehicle_Id, false), 25.0, memory_read_int(PtrMem), config.Realistic, config.Accuracy)
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