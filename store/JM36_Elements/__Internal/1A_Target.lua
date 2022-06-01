--local Distance = 1250.0
local Distance <const> = 2500.0
local Radius <const> = 1.25



local TargetTable <const> =
{
	InfoKeyName	=	"Target",
	InfoKeyOnly	=	true,
	CollisionA	=	0,
	EndCoordsA	=	0,
	EntityHitA	=	0,
	EntOffsetA	=	0,
	CollisionB	=	0,
	EndCoordsB	=	0,
	EntityHitB	=	0,
	EntOffsetB	=	0,
}

local util <const> = util
local util_create_thread <const> = util.create_thread
util_create_thread(function()
	local memory <const> = memory
	local memory_alloc <const> = memory.alloc
	local memory_read_byte <const> = memory.read_byte
	local memory_read_vector3 <const> = memory.read_vector3
	local memory_read_int <const> = memory.read_int
	
	local util_yield <const> = util.yield
	local util_rot_to_dir <const> = util.rot_to_dir
	
	local HitA <const>, EndCoordsA <const>, SurfaceNormalA <const>, EntityHitA <const> = memory_alloc(), memory_alloc(), memory_alloc(), memory_alloc()
	local ShapeTestLosProbe <const> = function(StartCoords, EndCoords, EntityToIgnore)
		local shapeTestHandle <const> = StartExpensiveSynchronousShapeTestLosProbe(StartCoords.x, StartCoords.y, StartCoords.z, EndCoords.x, EndCoords.y, EndCoords.z, 14--[[15]], EntityToIgnore, 0)
		while GetShapeTestResult(shapeTestHandle, HitA, EndCoordsA, SurfaceNormalA, EntityHitA) ~= 2 do
			util_yield()
		end
		local TargetTable <const> = TargetTable
		local CollisionA <const> = memory_read_byte(HitA) == 1
		if CollisionA then
			TargetTable.EndCoordsA = memory_read_vector3(EndCoordsA)
			TargetTable.EntOffsetA = memory_read_vector3(SurfaceNormalA)
		else
			TargetTable.EndCoordsA = EndCoords
			TargetTable.EntOffsetA = EndCoords
		end
		TargetTable.CollisionA = CollisionA
		TargetTable.EntityHitA = memory_read_int(EntityHitA)
	end
	
	local HitB <const>, EndCoordsB <const>, SurfaceNormalB <const>, EntityHitB <const> = memory_alloc(), memory_alloc(), memory_alloc(), memory_alloc()
	local ShapeTestCapsule <const> = function(StartCoords, EndCoords, EntityToIgnore)
		local shapeTestHandle <const> = StartShapeTestCapsule(StartCoords.x, StartCoords.y, StartCoords.z, EndCoords.x, EndCoords.y, EndCoords.z, Radius, 14--[[15]], EntityToIgnore, 0)
		while GetShapeTestResult(shapeTestHandle, HitB, EndCoordsB, SurfaceNormalB, EntityHitB) ~= 2 do
			util_yield()
		end
		local TargetTable <const> = TargetTable
		local CollisionB <const> = memory_read_byte(HitB) == 1
		if CollisionB then
			TargetTable.EndCoordsB = memory_read_vector3(EndCoordsB)
			TargetTable.EntOffsetB = memory_read_vector3(SurfaceNormalB)
		else
			TargetTable.EndCoordsB = EndCoords
			TargetTable.EntOffsetB = EndCoords
		end
		TargetTable.CollisionB = CollisionB
		TargetTable.EntityHitB = memory_read_int(EntityHitB)
	end
	while true do
		local Entity
		do
			local PlayerPed <const> = PlayerPedId()
			local PlayerVeh <const> = GetVehiclePedIsIn(PlayerPed, false)
			if PlayerVeh ~= 0 then
				Entity = PlayerVeh
			else
				Entity = PlayerPed
			end
		end
		
		local StartCoords <const> = --[[GetGameplayCamCoord()]]GetFinalRenderedCamCoord()
		local EndCoords
		do
			local VectorForward = util_rot_to_dir(--[[GetGameplayCamRot(2)]]GetFinalRenderedCamRot(2))
			VectorForward.x, VectorForward.y, VectorForward.z = VectorForward.x*Distance, VectorForward.y*Distance, VectorForward.z*Distance
			
			EndCoords =
			{
				x=StartCoords.x+VectorForward.x,
				y=StartCoords.y+VectorForward.y,
				z=StartCoords.z+VectorForward.z,
			}
		end
		
		ShapeTestLosProbe(StartCoords, EndCoords, Entity)
		util_create_thread(ShapeTestCapsule, StartCoords, EndCoords, Entity)
		
		util_yield()
	end
end)

return TargetTable