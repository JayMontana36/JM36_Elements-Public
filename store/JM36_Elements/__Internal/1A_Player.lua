local Player = 
{
	Id			=	0,
	Ped			=	0,
	Coords		=	0,
	Vehicle		=	0
}
Info.Player = Player

local Vehicle =
{
	IsIn			=	0,
	IsOp			=	0,
	IsUsing			=	0,
	HandleScript	=	0,
	HandleNetwork	=	0,
	Model			=	0,
	--Name			=	0,
	--Coords			=	0,
	Dimensions		=	0,
	Type			=	setmetatable({},{__index=function()return false end}),
}
Player.Vehicle = Vehicle

local Vehicle_Dimensions = {Minimum=0,Maximum=0,Size=0,SizeMax=0};Vehicle.Dimensions=Vehicle_Dimensions
local Vehicle_Dimensions_Minimum = v3();Vehicle_Dimensions.Minimum=Vehicle_Dimensions_Minimum
local Vehicle_Dimensions_Maximum = v3();Vehicle_Dimensions.Maximum=Vehicle_Dimensions_Maximum
local Vehicle_Dimensions_Size = v3();Vehicle_Dimensions.Size=Vehicle_Dimensions_Size

local Vehicle_Type = Vehicle.Type



local math_max = math.max



local PlayerId = PlayerId
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetVehiclePedIsUsing = GetVehiclePedIsUsing
local IsPedSittingInVehicle = IsPedSittingInVehicle
local GetPedInVehicleSeat = GetPedInVehicleSeat
local NetworkHasControlOfEntity = NetworkHasControlOfEntity
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local GetEntityModel = GetEntityModel
--local GetDisplayNameFromVehicleModel = GetDisplayNameFromVehicleModel
local IsThisModelABicycle = IsThisModelABicycle
local IsThisModelABike = IsThisModelABike
local IsThisModelABoat = IsThisModelABoat
local IsThisModelACar = IsThisModelACar
local IsThisModelAHeli = IsThisModelAHeli
local IsThisModelAJetski = IsThisModelAJetski
local IsThisModelAPlane = IsThisModelAPlane
local IsThisModelAQuadbike = IsThisModelAQuadbike
local IsThisModelATrain = IsThisModelATrain
local IsThisModelAnAmphibiousCar = IsThisModelAnAmphibiousCar
local IsThisModelAnAmphibiousQuadbike = IsThisModelAnAmphibiousQuadbike
local GetModelDimensions = GetModelDimensions

local yield = JM36.yield_once

JM36.CreateThread_HighPriority(function()
	while true do
		Player.Id = PlayerId()
		local Ped = PlayerPedId();Player.Ped=Ped
		Player.Coords = GetEntityCoords(Ped,false)
		local IsUsing = GetVehiclePedIsUsing(Ped);Vehicle.IsUsing=IsUsing
		local IsIn = IsPedSittingInVehicle(Ped,IsUsing) and IsUsing;Vehicle.IsIn=IsIn
		if IsIn then
			Vehicle.IsOp = (Ped == GetPedInVehicleSeat(IsIn,-1)) and NetworkHasControlOfEntity(IsIn)
			if IsIn ~= Vehicle.HandleScript then
				Vehicle.HandleScript = IsIn
				Vehicle.HandleNetwork = NetworkGetNetworkIdFromEntity(IsIn)
				
				local Model = GetEntityModel(IsIn);Vehicle.Model=Model
				Vehicle_Type.Bicycle			= IsThisModelABicycle(Model)
				Vehicle_Type.Bike				= IsThisModelABike(Model)
				Vehicle_Type.Boat				= IsThisModelABoat(Model)
				Vehicle_Type.Car				= IsThisModelACar(Model)
				Vehicle_Type.Heli				= IsThisModelAHeli(Model)
				Vehicle_Type.Jetski				= IsThisModelAJetski(Model)
				Vehicle_Type.Plane				= IsThisModelAPlane(Model)
				Vehicle_Type.Quadbike			= IsThisModelAQuadbike(Model)
				Vehicle_Type.Train				= IsThisModelATrain(Model)
				Vehicle_Type.AmphibiousCar		= IsThisModelAnAmphibiousCar(Model)
				Vehicle_Type.AmphibiousQuadbike	= IsThisModelAnAmphibiousQuadbike(Model)
				
				GetModelDimensions(Model, Vehicle_Dimensions_Minimum, Vehicle_Dimensions_Maximum)
				Vehicle_Dimensions_Size:set(Vehicle_Dimensions_Maximum);Vehicle_Dimensions_Size:sub(Vehicle_Dimensions_Minimum)
				Vehicle_Dimensions.SizeMax = math_max(Vehicle_Dimensions_Size.x, Vehicle_Dimensions_Size.z)--Vehicle_Dimensions.SizeMax = math_max(Vehicle_Dimensions_Size.x, Vehicle_Dimensions_Size.y, Vehicle_Dimensions_Size.z)
			end
		end
		yield()
	end
end)