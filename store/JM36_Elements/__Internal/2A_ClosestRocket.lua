local RocketTable <const> =
{
	InfoKeyName	=	"Rockets",
	InfoKeyOnly	=	true,
	Closest		=	0,
	ClosestDist	=	0,
}

local RocketObjectHashes = {
	[GetHashKey'w_lr_rpg_rocket']			=	true,
	[GetHashKey'w_lr_homing_rocket']		=	true,
	[GetHashKey'w_lr_firework_rocket']		=	true,
	[GetHashKey'w_battle_airmissile_01']	=	true,
	[GetHashKey'w_smug_airmissile_01b']		=	true,
	[GetHashKey'w_ex_vehiclemissile_3']		=	true,
	[GetHashKey'w_ex_vehiclemissile_1']		=	true,
	[GetHashKey'w_ex_vehiclemissile_2']		=	true,
	[GetHashKey'w_ex_vehiclemissile_4']		=	true,
	[GetHashKey'w_smug_airmissile_02']		=	true,
	[GetHashKey'torpedo']					=	true,
}
local RocketObjectHashesNum = #RocketObjectHashes

JM36.CreateThread_HighPriority(function()
	local table_sort <const> = table.sort
	local RocketTableSortDist <const> = function(inputA,inputB)
		return inputA[2] < inputB[2]
	end
	
	local entities_get_all_objects_as_pointers <const> = entities.get_all_objects_as_pointers
	local entities_get_model_hash <const> = entities.get_model_hash
	local entities_pointer_to_handle <const> = entities.pointer_to_handle
	local GetEntityCoords <const> = GetEntityCoords
	local v3_distance <const> = v3.distance
	
	local Player = Info.Player
	
	local yield <const> = JM36.yield
	
	while true do
		local AllObjects <const> = entities_get_all_objects_as_pointers()
		local Count = 0
		for i=1, #AllObjects do
			local Object <const> = AllObjects[i]
			if RocketObjectHashes[entities_get_model_hash(Object)] then
				Count += 1
				local _RocketTable = RocketTable[Count]
				if not _RocketTable then
					_RocketTable = {0,0,0}
					RocketTable[Count] = _RocketTable
				end
				_RocketTable[1] = entities_pointer_to_handle(Object)
			end
		end
		for i=Count+1, #RocketTable do
			RocketTable[i] = nil
		end
		if Count ~= 0 then
			local Player_Coords <const> = Player.Coords
			local Closest, Range = 0, 16384
			for i=1, Count do
				local _RocketTable <const> = RocketTable[i]
				local Rocket <const> = _RocketTable[1]
				local RocketCoords <const> = GetEntityCoords(Rocket, false)
				_RocketTable[3] = RocketCoords
				local Dist <const> = v3_distance(Player_Coords, RocketCoords)
				_RocketTable[2] = Dist
				if Dist < Range then Closest, Range = Rocket, Dist end
			end
			RocketTable.Closest = Closest
			RocketTable.ClosestDist = Range
			
			table_sort(RocketTable, RocketTableSortDist)
		else
			RocketTable.Closest = 0
			RocketTable.ClosestDist = 0
		end
		yield()
	end
end)

return RocketTable