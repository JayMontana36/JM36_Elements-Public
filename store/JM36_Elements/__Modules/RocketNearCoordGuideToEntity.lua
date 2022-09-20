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
			local __Rocket = entities.create_object(GetHashKey"w_lr_homing_rocket", CoordsRocket)
			if __Rocket ~= 0 then
				SetEntityVisible(_Rocket, false, false)
				SetEntityAsMissionEntity(__Rocket, true, true)
				SetEntityLoadCollisionFlag(__Rocket, true)
				SetEntityNoCollisionEntity(__Rocket, _Rocket, false)
				SetEntityNoCollisionEntity(_Rocket, __Rocket, false)
				do
					local Vehicle = Info.Player.Vehicle
					if Vehicle.IsIn then
						local Vehicle_Id = Vehicle.Id
						SetEntityNoCollisionEntity(__Rocket, Vehicle_Id, false)
						SetEntityNoCollisionEntity(Vehicle_Id, __Rocket, false)
					end
				end
				AttachEntityToEntity(__Rocket, _Rocket, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
				SetEntityCollision(__Rocket, false, false)
				SetEntityCompletelyDisableCollision(__Rocket, not true, false)
				NetworkFadeInEntity(__Rocket, true, false)
				CreateThread(function()
					while DoesEntityExist(_Rocket) do
						local __RocketNet = ObjToNet(__Rocket)
						if __RocketNet ~= 0 then
							SetNetworkIdExistsOnAllMachines(__RocketNet, true)
							NetworkUseHighPrecisionBlending(__RocketNet, true)
							SetNetworkIdCanMigrate(__RocketNet, false)
							break
						end
						yield()
					end
				end)
				CreateThread(function()
					local PtFx
					do
						local PtFxAssName <const> = "veh_impexp_rocket"	-- ParticleFX Asset Name
						local PtFxEffName <const> = "veh_rocket_boost"	-- ParticleFX Effect Name
						local Scale <const> = 1.0
						
						if not HasNamedPtfxAssetLoaded(PtFxAssName) then
							RequestNamedPtfxAsset(PtFxAssName)
							while not HasNamedPtfxAssetLoaded(PtFxAssName) do
								yield()
							end
						end
						
						local OffsetY
						do
							local min, max = v3.new(), v3.new()
							GetModelDimensions(GetHashKey"w_lr_homing_rocket", min, max)
							OffsetY = min.y
						end
						UseParticleFxAsset(PtFxAssName)
						PtFx = StartNetworkedParticleFxLoopedOnEntity(PtFxEffName, __Rocket, 0.0, OffsetY, 0.0, 0.0, 0.0, 0.0, Scale, false, false, false)
						SetParticleFxLoopedEvolution(PtFx, "boost", 1.0, true)
					end
					
					while DoesEntityExist(_Rocket) do
						--Set Coords and Rotation?
						yield()
					end
					StopParticleFxLooped(PtFx, false)
					RemoveParticleFx(PtFx, false)
					if DoesEntityExist(__Rocket) then
						entities.delete_by_handle(__Rocket)
					end
				end)
			end
			
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
					do
						local _CoordsTarget = GetEntityVelocity(_TargetEntity)
						_CoordsTarget:mul(v3.distance(CoordsRocket, CoordsTarget)*.01)
						CoordsTarget:add(_CoordsTarget)
					end
					
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
						SetVehicleHomingLockedontoState(_TargetEntity, 2)
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