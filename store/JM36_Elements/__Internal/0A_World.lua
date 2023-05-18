local World



local entities_get_all_vehicles_as_pointers	= entities.get_all_vehicles_as_pointers	;	entities.get_all_vehicles_as_pointers	= function()return World.PointersVehicles end
local entities_get_all_peds_as_pointers		= entities.get_all_peds_as_pointers		;	entities.get_all_peds_as_pointers		= function()return World.PointersPeds end
local entities_get_all_objects_as_pointers	= entities.get_all_objects_as_pointers	;	entities.get_all_objects_as_pointers	= function()return World.PointersObjects end
local entities_get_all_pickups_as_pointers	= entities.get_all_pickups_as_pointers	;	entities.get_all_pickups_as_pointers	= function()return World.PointersPickups end



World = setmetatable
(
	{
		PointersVehicles	=	0,
		PointersPeds		=	0,
		PointersObjects		=	0,
		PointersPickups		=	0,
	},
	{
		__index	=	function(Self,Key)
						local Value
						switch Key do
							case "PointersVehicles":
								Value = entities_get_all_vehicles_as_pointers()
								break
							case "PointersPeds":
								Value = entities_get_all_peds_as_pointers()
								break
							case "PointersObjects":
								Value = entities_get_all_objects_as_pointers()
								break
							case "PointersPickups":
								Value = entities_get_all_pickups_as_pointers()
								break
						end
						Self[Key] = Value
						return Value
					end
	}
)
Info.World = World



local yield = JM36.yield_once

JM36.CreateThread_HighPriority(function()
	while true do
		World.PointersVehicles = nil
		World.PointersPeds = nil
		World.PointersObjects = nil
		World.PointersPickups = nil
		yield()
	end
end)
