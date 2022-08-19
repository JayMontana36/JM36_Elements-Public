local Distance <const> = 2500.0
local Radius <const> = 1.25



local v3 <const> = v3



local TargetTable
do
	local v3_new <const> = v3.new
	TargetTable =
	{
		InfoKeyName	=	"Target",
		InfoKeyOnly	=	true,
		CollisionA	=	false,
		EndCoordsA	=	v3_new(),
		EntityHitA	=	0,
		EntOffsetA	=	v3_new(),
		CollisionB	=	false,
		EndCoordsB	=	v3_new(),
		EntityHitB	=	0,
		EntOffsetB	=	v3_new(),
	}
end
local TargetTable <const> = TargetTable

local JM36 <const> = JM36
JM36.CreateThread_HighPriority(function()
	local CreateThread <const> = util.create_thread
	local yield <const> = util.yield
	local ShapeTestLosProbe, ShapeTestCapsule
	do
		local memory <const> = memory
		local memory_alloc_int <const> = memory.alloc_int
		local memory_read_byte <const> = memory.read_byte
		local memory_read_int <const> = memory.read_int
		local v3_get <const> = v3.get
		local v3_set <const> = v3.set
		local TargetTable <const> = TargetTable
		local GetShapeTestResult <const> = GetShapeTestResult
		do
			local StartExpensiveSynchronousShapeTestLosProbe <const> = StartExpensiveSynchronousShapeTestLosProbe
			local HitA <const>, EndCoordsA <const>, SurfaceNormalA <const>, EntityHitA <const> = memory_alloc_int(), TargetTable.EndCoordsA, TargetTable.EntOffsetA, memory_alloc_int()
			ShapeTestLosProbe = function(StartCoords, EndCoords, EntityToIgnore)
				local StartCoords <const>, EndCoords <const> = StartCoords, EndCoords
				local EndCoords_x <const>, EndCoords_y <const>, EndCoords_z <const> = v3_get(EndCoords)
				local shapeTestHandle <const> = StartExpensiveSynchronousShapeTestLosProbe(StartCoords.x, StartCoords.y, StartCoords.z, EndCoords_x, EndCoords_y, EndCoords_z, 14--[[15]], EntityToIgnore, 0)
				while GetShapeTestResult(shapeTestHandle, HitA, EndCoordsA, SurfaceNormalA, EntityHitA) ~= 2 do
					yield()
				end
				local CollisionA <const> = memory_read_byte(HitA) == 1
				if not CollisionA then
					v3_set(EndCoordsA, EndCoords_x, EndCoords_y, EndCoords_z)
				end
				TargetTable.CollisionA = CollisionA
				TargetTable.EntityHitA = memory_read_int(EntityHitA)
			end
		end
		do
			local StartShapeTestCapsule <const> = StartShapeTestCapsule
			local HitB <const>, EndCoordsB <const>, SurfaceNormalB <const>, EntityHitB <const> = memory_alloc_int(), TargetTable.EndCoordsB, TargetTable.EntOffsetB, memory_alloc_int()
			ShapeTestCapsule = function(StartCoords, EndCoords, EntityToIgnore)
				local StartCoords <const>, EndCoords <const> = StartCoords, EndCoords
				local EndCoords_x <const>, EndCoords_y <const>, EndCoords_z <const> = v3_get(EndCoords)
				local shapeTestHandle <const> = StartShapeTestCapsule(StartCoords.x, StartCoords.y, StartCoords.z, EndCoords_x, EndCoords_y, EndCoords_z, Radius, 14--[[15]], EntityToIgnore, 0)
				while GetShapeTestResult(shapeTestHandle, HitB, EndCoordsB, SurfaceNormalB, EntityHitB) ~= 2 do
					yield()
				end
				local CollisionB <const> = memory_read_byte(HitB) == 1
				if not CollisionB then
					v3_set(EndCoordsB, EndCoords_x, EndCoords_y, EndCoords_z)
				end
				TargetTable.CollisionB = CollisionB
				TargetTable.EntityHitB = memory_read_int(EntityHitB)
			end
		end
	end
	
	local v3_toDir <const> = v3.toDir
	local v3_mul <const> = v3.mul
	local v3_add <const> = v3.add
	local Player <const> = Info.Player
	local Vehicle <const> = Player.Vehicle
	local GetFinalRenderedCamCoord <const> = GetFinalRenderedCamCoord
	local GetFinalRenderedCamRot <const> = GetFinalRenderedCamRot
	local ShapeTestLosProbe <const>, ShapeTestCapsule <const> = ShapeTestLosProbe, ShapeTestCapsule
	while true do
		local Entity <const> = Vehicle.IsIn and Vehicle.Id or Player.Ped
		local StartCoords <const> = GetFinalRenderedCamCoord()
		local EndCoords <const> = v3_toDir(GetFinalRenderedCamRot(2));v3_mul(EndCoords, Distance);v3_add(EndCoords, StartCoords)
		
		ShapeTestLosProbe(StartCoords, EndCoords, Entity)
		CreateThread(ShapeTestCapsule, StartCoords, EndCoords, Entity)
		
		yield()
	end
end)

return TargetTable