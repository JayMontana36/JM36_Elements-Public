local WorldTable <const> =
{
	InfoKeyName			=	"World",
	InfoKeyOnly			=	true,
	PointersVehicles	=	0,
	PointersPeds		=	0,
	PointersObjects		=	0,
	PointersPickups		=	0,
}

local entities_get_all_vehicles_as_pointers <const> = entities.get_all_vehicles_as_pointers
local entities_get_all_peds_as_pointers <const> = entities.get_all_peds_as_pointers
local entities_get_all_objects_as_pointers <const> = entities.get_all_objects_as_pointers
local entities_get_all_pickups_as_pointers <const> = entities.get_all_pickups_as_pointers
entities.get_all_vehicles_as_pointers = function()return WorldTable.PointersVehicles end
entities.get_all_peds_as_pointers = function()return WorldTable.PointersPeds end
entities.get_all_objects_as_pointers = function()return WorldTable.PointersObjects end
entities.get_all_pickups_as_pointers = function()return WorldTable.PointersPickups end

JM36.CreateThread_HighPriority(function()
	local yield <const> = JM36.yield
	while true do
		WorldTable.PointersVehicles = entities_get_all_vehicles_as_pointers()
		WorldTable.PointersPeds = entities_get_all_peds_as_pointers()
		WorldTable.PointersObjects = entities_get_all_objects_as_pointers()
		WorldTable.PointersPickups = entities_get_all_pickups_as_pointers()
		yield()
	end
end)

return WorldTable