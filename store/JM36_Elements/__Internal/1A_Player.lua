local PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike = players.user or PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
local v3_new = v3.new
local GetModelDimensions = GetModelDimensions
local Player <const> = setmetatable
(
	{
		InfoKeyName	=	"Player",
		Id			=	 0,
		Ped			=	 0,
		Handle		=	 0,
		Coords		=	 0,
		Vehicle		=	{
							IsIn	   =	0,
							IsOp	   =	0,
							Id		   =	0,
							Handle	   =	0,
							NetId	   =	0,
							Model	   =	0,
							Name	   =	0,
							Coords	   =	0,
							Dimensions =	{Minimum=v3_new(),Maximum=v3_new(),Size=v3_new()},
							Type	   =	setmetatable({},{__index=function() return false end}),
						}
	},
	{
		__call	=	function(Self)
						Self.Id				= PlayerId()
						local Ped			= PlayerPedId() Self.Ped,Self.Handle=Ped,Ped
						Self.Coords			= GetEntityCoords(Ped, false)
						local IsIn			= IsPedInAnyVehicle(Ped, false) Self.Vehicle.IsIn = IsIn
						if IsIn then
							local Vehicle 	= Self.Vehicle
							local Veh	  	= GetVehiclePedIsIn(Ped, false)
							Vehicle.IsOp	= Veh ~= 0 and Ped == GetPedInVehicleSeat(Veh, -1)
							Vehicle.Coords	= GetEntityCoords(Veh~=0 and Veh or Vehicle.Id, false)
							
							if Veh == Vehicle.Id then return end
							
							Vehicle.Id,Vehicle.Handle=Veh,Veh
							Vehicle.NetId	= NetworkGetNetworkIdFromEntity(Veh)
							local VehModel	= GetEntityModel(Veh) Vehicle.Model = VehModel
							Vehicle.Name	= GetDisplayNameFromVehicleModel(VehModel)
							
							do
								local Vehicle_Type = Vehicle.Type
								Vehicle_Type.Bicycle			= IsThisModelABicycle(VehModel)
								Vehicle_Type.Bike				= IsThisModelABike(VehModel)
								Vehicle_Type.Boat				= IsThisModelABoat(VehModel)
								Vehicle_Type.Car				= IsThisModelACar(VehModel)
								Vehicle_Type.Heli				= IsThisModelAHeli(VehModel)
								Vehicle_Type.Jetski				= IsThisModelAJetski(VehModel)
								Vehicle_Type.Plane				= IsThisModelAPlane(VehModel)
								Vehicle_Type.Quadbike			= IsThisModelAQuadbike(VehModel)
								Vehicle_Type.Train				= IsThisModelATrain(VehModel)
								Vehicle_Type.AmphibiousCar		= IsThisModelAnAmphibiousCar(VehModel)
								Vehicle_Type.AmphibiousQuadbike = IsThisModelAnAmphibiousQuadbike(VehModel)
							end
							do
								local Dimensions = Vehicle.Dimensions
								local Minimum, Maximum, Size = Dimensions.Minimum, Dimensions.Maximum, Dimensions.Size
								GetModelDimensions(VehModel, Minimum, Maximum)
								Size:set(Maximum) Size:sub(Minimum)
							end
						end
					end
	}
)
return Player