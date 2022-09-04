local PtFxAssName <const> = "veh_impexp_rocket"	-- ParticleFX Asset Name
local PtFxEffName <const> = "veh_rocket_boost"	-- ParticleFX Effect Name
local Scale <const> = 1.0



local StopParticleFxLooped, RemoveParticleFx = StopParticleFxLooped, RemoveParticleFx

local AB_On = false
local AB_List <const> = {}
local AB_List_Num = 0
local AB_Stop <const> = function()
	for i = 1, AB_List_Num do
		local AB = AB_List[i]
		StopParticleFxLooped(AB, false)
		RemoveParticleFx(AB, false)
		AB_List[i] = nil
	end
	AB_On = false
	AB_List_Num = 0
end

local CreateThread = JM36.CreateThread
local yield = JM36.yield

local Enabled
CreateThread(function()
	local SetEntityProofs, GetIsVehicleEngineRunning, HasNamedPtfxAssetLoaded, RequestNamedPtfxAsset, GetEntityBoneIndexByName, UseParticleFxAsset, StartNetworkedParticleFxLoopedOnEntityBone, GetControlNormal, SetParticleFxLoopedEvolution
		= SetEntityProofs, GetIsVehicleEngineRunning, HasNamedPtfxAssetLoaded, RequestNamedPtfxAsset, GetEntityBoneIndexByName, UseParticleFxAsset, StartNetworkedParticleFxLoopedOnEntityBone, GetControlNormal, SetParticleFxLoopedEvolution
	
	local Info = Info
	local Player = Info.Player
	local Vehicle = Player.Vehicle
	local Type = Vehicle.Type
	
	local IsEligible, LastVehicle
	while true do
		if Enabled and Vehicle.IsIn then
			if Vehicle.Id ~= LastVehicle then
				AB_Stop()
				IsEligible = Type.Plane
				LastVehicle = Vehicle.Id
				if IsEligible and Vehicle.IsOp then
					SetEntityProofs(LastVehicle, false, true, false, false, true, true, true--[[unk p7]], true)
				end
			end
			if IsEligible and Vehicle.IsOp then
				local VehicleOperating = GetIsVehicleEngineRunning(LastVehicle)
				if VehicleOperating and not AB_On then
					CreateThread(function()
						if not HasNamedPtfxAssetLoaded(PtFxAssName) then
							RequestNamedPtfxAsset(PtFxAssName)
							while not HasNamedPtfxAssetLoaded(PtFxAssName) do
								yield()
							end
						end
						for i = 1, 16 do
							local EntityBoneIndex
							if i > 1 then
								EntityBoneIndex = GetEntityBoneIndexByName(LastVehicle, "exhaust_"..i)
							else
								EntityBoneIndex = GetEntityBoneIndexByName(LastVehicle, "exhaust")
								if EntityBoneIndex == -1 then
									EntityBoneIndex = GetEntityBoneIndexByName(LastVehicle, "engine")
								end
							end
							if EntityBoneIndex > -1 then
								UseParticleFxAsset(PtFxAssName)
								AB_List_Num = AB_List_Num + 1
								AB_List[AB_List_Num] = StartNetworkedParticleFxLoopedOnEntityBone(PtFxEffName, LastVehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, EntityBoneIndex, Scale, false, false, false)
							else
								return
							end
						end
					end)
					CreateThread(function()
						local NetworkNext = 0
						while AB_On do
							local NetworkNow
							do
								local Time = Info.Time
								NetworkNow = Time > NetworkNext
								if NetworkNow then
									NetworkNext = Time + 200
								end
							end
							local InputValueThrottleUp = GetControlNormal(25, 87)
							for i = 1, AB_List_Num do
								local AB = AB_List[i]
								SetParticleFxLoopedEvolution(AB, "boost", InputValueThrottleUp, NetworkNow)
								SetParticleFxLoopedEvolution(AB, "damage", 0.0, NetworkNow)
							end
							yield()
						end
					end)
					AB_On = true
				elseif AB_On and not VehicleOperating then
					AB_Stop()
				end
			end
		elseif AB_On or AB_List_Num ~= 0 then
			AB_Stop()
		end
		yield()
	end
end)

local Menu, Config
return{
	init	=	function()
					Config = configFileRead("AircraftAfterburners.ini")
					Enabled = Config.Enabled
					Menu = menu.toggle(require'Menu_Vehicle', "Custom Aircraft Afterburners", {}, "Planes only (for now), not all planes work well or look good with this.", function(on)Enabled=on Config.Enabled=on end, Enabled)
				end,
	stop	=	function()
					AB_Stop()
					configFileWrite("AircraftAfterburners.ini", Config)
					menu.delete(Menu)
				end,
}