local PtFxAssName <const> = "weap_xs_vehicle_weapons"				-- ParticleFX Asset Name
local PtFxEffName <const> = "muz_xs_turret_flamethrower_looping_sf"	-- ParticleFX Effect Name
local Scale <const> = 1.0

local RocketObjectHashes <const>, RocketObjectHashesNum <const> = require'HashesRockets_Array'()

local util_yield <const> = util.yield
return function(CoordsRocket, CoordsRadius, TargetEntity, UseRealisticPhysics, GuidanceAccuracy)
	local Rocket = 0
	do
		local TimeTerm <const> = Info.Time+1000
		while Rocket == 0 and Info.Time <= TimeTerm do
			local RocketFound
			for i=1, RocketObjectHashesNum do
				Rocket = GetClosestObjectOfType(CoordsRocket.x, CoordsRocket.y, CoordsRocket.z, CoordsRadius, RocketObjectHashes[i], false)
				RocketFound = Rocket ~= 0 and GetEntitySpeed(Rocket) > 1
				if RocketFound then break end
			end
			if not RocketFound then
				util_yield()
			end
		end
	end
	
	if Rocket ~= 0 then
		SetEntityAsMissionEntity(Rocket, true, true)
		
		SetEntityLoadCollisionFlag(Rocket, true)
		
		local SpeedInit
		local GuidanceAccuracy <const> = (GuidanceAccuracy or 1) * 32
		local TargetEntityIsVehicle <const> = GetEntityType(TargetEntity) == 2
		--CreateThread(function()
		--	NetworkUnregisterNetworkedEntity(Rocket)
		--	NetworkRegisterEntityAsNetworked(Rocket)
		--end)
		do
			local NetId = ObjToNet(Rocket)
			if NetId == 0 or NetId == -1 then
				NetworkRegisterEntityAsNetworked(Rocket)
				NetId = ObjToNet(Rocket)
			end
			SetNetworkIdExistsOnAllMachines(NetId, true)
			NetworkUseHighPrecisionBlending(NetId, true)
		end
		if not HasNamedPtfxAssetLoaded(PtFxAssName) then
			RequestNamedPtfxAsset(PtFxAssName)
			while not HasNamedPtfxAssetLoaded(PtFxAssName) do
				util.yield()
			end
		end
		UseParticleFxAsset(PtFxAssName)
		--local ptfx = StartNetworkedParticleFxLoopedOnEntityBone(PtFxEffName, Rocket, 0.0, 0.0, 0.0, -0.0, -0.0, 180.0, EntityBoneIndex, Scale, false, false, false)
--		local ptfx = StartNetworkedParticleFxLoopedOnEntity(PtFxEffName, Rocket, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, Scale, false, false, false)
--		SetParticleFxLoopedColour(ptfx, 255, 0, 0, false)
		local CoordsRocket
		while DoesEntityExist(Rocket) and DoesEntityExist(TargetEntity) do
			NetworkRequestControlOfEntity(Rocket)
			
			CoordsRocket = GetEntityCoords(Rocket, false)
			local CoordsTarget <const> = GetEntityCoords(TargetEntity, false)
	--		if HasEntityClearLosToEntityInFront(Rocket, TargetEntity) then
				local Rotation = util.v3_look_at(CoordsRocket, CoordsTarget)
				
				SetEntityRotation(Rocket, Rotation.x, Rotation.y, Rotation.z, 2, false)
				
				if not SpeedInit then
					SetEntityMaxSpeed(Rocket, 158.2) -- Max Recorded Speed = 158.10801696777
					SpeedInit = 1
				end
				
				Rotation = util.rot_to_dir(Rotation)
				
				local ApplyForceToEntityCenterOfMass <const> = ApplyForceToEntityCenterOfMass
				if UseRealisticPhysics then
					ApplyForceToEntityCenterOfMass(Rocket, 1, Rotation.x*GuidanceAccuracy, Rotation.y*GuidanceAccuracy, Rotation.z*GuidanceAccuracy, false, false, true, true)
				else
					for i=1, GuidanceAccuracy do
						ApplyForceToEntityCenterOfMass(Rocket, 1, Rotation.x, Rotation.y, Rotation.z, false, false, true, true)
					end
				end
				
				--[[do
					UseParticleFxAsset(PtFxAssName)
					SetParticleFxNonLoopedColour(1.0, 0, 0)
					StartNetworkedParticleFxNonLoopedOnEntity(PtFxEffName, Rocket, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, Scale, false, false, false)
				end]]
				
				DrawLine(CoordsRocket.x, CoordsRocket.y, CoordsRocket.z, CoordsTarget.x, CoordsTarget.y, CoordsTarget.z, 255, 255, 255, 255)
				
				if TargetEntityIsVehicle then
					_0x407DC5E97DB1A4D3(TargetEntity, 2)
				end
				
				
	--		end
			
			util_yield()
			
--			StopParticleFxLooped(ptfx, false)
--			RemoveParticleFx(ptfx, false)
			
			if CoordsRocket and not DoesEntityExist(Rocket) then
				AddOwnedExplosion(PlayerPedId(), CoordsRocket.x, CoordsRocket.y, CoordsRocket.z, --[[63]]--[[64]]--[[70]]64, 1.0, false, true, 10.0)
			end
		end
	end
end