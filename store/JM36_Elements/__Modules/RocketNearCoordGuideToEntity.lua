local RocketObjectHashes <const>, RocketObjectHashesNum <const> = require'HashesRockets_Array'()

local Info = Info
local JM36 = JM36
local CreateThread = JM36.CreateThread_HighPriority
local yield = JM36.yield

return function(CoordsRocket, CoordsRadius, _TargetEntity, UseRealisticPhysics, GuidanceAccuracy)
	CreateThread(function()
		local _Rocket = 0
		do
			local TimeTerm = Info.Time+1000
			while _Rocket == 0 and Info.Time <= TimeTerm do
				local RocketFound
				for i=1, RocketObjectHashesNum do
					_Rocket = GetClosestObjectOfType(CoordsRocket.x, CoordsRocket.y, CoordsRocket.z, CoordsRadius, RocketObjectHashes[i], false)
					RocketFound = _Rocket ~= 0 and GetEntitySpeed(_Rocket) > 1
					if RocketFound then break end
				end
				if not RocketFound then
					yield()
				end
			end
		end
		
		if _Rocket ~= 0 and DoesEntityExist(_TargetEntity) then
			local Rocket = ObjToNet(Rocket);Rocket = Rocket ~= 0 and Rocket ~= -1 and Rocket
			if Rocket then
				SetNetworkIdExistsOnAllMachines(Rocket, true)
				NetworkUseHighPrecisionBlending(Rocket, true)
				SetNetworkIdCanMigrate(Rocket, false)
			end
			SetEntityAsMissionEntity(_Rocket, true, true)
			SetEntityLoadCollisionFlag(_Rocket, true)
			SetEntityMaxSpeed(Rocket, 158.2) -- Max Recorded Speed = 158.10801696777
			
			local GuidanceAccuracy = (GuidanceAccuracy or 1) * 32
			
			local TargetEntityType = GetEntityType(_TargetEntity)
			local TargetEntityIsVehicle = TargetEntityType == 2
			local TargetEntity = (TargetEntityIsVehicle and VehToNet(_TargetEntity)) or (TargetEntityType==1 and PedToNet(_TargetEntity)) or (TargetEntityType==3 and ObjToNet(_TargetEntity)) or NetworkGetNetworkIdFromEntity(_TargetEntity);TargetEntity = TargetEntity ~= 0 and TargetEntity ~= -1 and TargetEntity
			if TargetEntity then
				SetNetworkIdAlwaysExistsForPlayer(TargetEntity, PlayerId(), true)
			end
			
			local CoordsRocket
			while (Rocket and NetworkDoesEntityExistWithNetworkId(Rocket) or DoesEntityExist(_Rocket)) and (TargetEntity and NetworkDoesEntityExistWithNetworkId(TargetEntity) or DoesEntityExist(_TargetEntity)) do
				if Rocket then _Rocket = NetToObj(Rocket) end
				if TargetEntity then
					_TargetEntity = (TargetEntityIsVehicle and NetToVeh(TargetEntity)) or (TargetEntityType==1 and NetToPed(TargetEntity)) or (TargetEntityType==3 and NetToObj(TargetEntity)) or NetworkGetEntityFromNetworkId(TargetEntity)
				end
				
				CoordsRocket = GetEntityCoords(_Rocket, false)
				local CoordsTarget <const> = GetEntityCoords(_TargetEntity, false)
				--if HasEntityClearLosToEntityInFront(_Rocket, _TargetEntity) then
					local Rotation = CoordsRocket:lookAt(CoordsTarget)
					
					SetEntityRotation(_Rocket, Rotation, 2, false)
					
					Rotation = Rotation:toDir()
					
					local ApplyForceToEntityCenterOfMass = ApplyForceToEntityCenterOfMass
					if UseRealisticPhysics then
						Rotation:mul(GuidanceAccuracy)
						ApplyForceToEntityCenterOfMass(_Rocket, 1, Rotation, false, false, true, true)
					else
						for i=1, GuidanceAccuracy do
							ApplyForceToEntityCenterOfMass(_Rocket, 1, Rotation, false, false, true, true)
						end
					end
					
					DrawLine(CoordsRocket, CoordsTarget, 255, 255, 255, 255)
					
					if TargetEntityIsVehicle then
						_0x407DC5E97DB1A4D3(_TargetEntity, 2)
					end
				--end
				yield()
			end
			if CoordsRocket and not DoesEntityExist(_Rocket) then
				AddOwnedExplosion(PlayerPedId(), CoordsRocket, --[[63]]--[[64]]--[[70]]64, 1.0, false, true, 10.0)
			end
			if TargetEntity and TargetEntityIsVehicle then
				--SetNetworkIdAlwaysExistsForPlayer(TargetEntity, PlayerId(), false)
			end
		end
	end)
end