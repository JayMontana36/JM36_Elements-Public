local Player = Info.Player

local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local SetNetworkIdCanMigrate = SetNetworkIdCanMigrate
local SetNetworkIdExistsOnAllMachines = SetNetworkIdExistsOnAllMachines
local SetNetworkIdAlwaysExistsForPlayer = SetNetworkIdAlwaysExistsForPlayer
--local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked
local NetworkRegisterEntityAsNetworked = NetworkRegisterEntityAsNetworked
local NetworkHasEntityBeenRegisteredWithThisThread = NetworkHasEntityBeenRegisteredWithThisThread
local SetEntityAsMissionEntity = SetEntityAsMissionEntity

local entities_set_can_migrate = entities.set_can_migrate
local entities_handle_to_pointer = entities.handle_to_pointer

local SetPropertiesForEntityNetworkId = function(Entity, CanMigrate, AlwaysExistsForSelf, AlwaysExistsForAll, ExistsOnAll)
	local NetId = NetworkGetNetworkIdFromEntity(Entity);NetId=NetId~=0 and NetId
	if NetId then
		SetNetworkIdCanMigrate(NetId, CanMigrate)
		SetNetworkIdExistsOnAllMachines(NetId, ExistsOnAll)
		SetNetworkIdAlwaysExistsForPlayer(NetId, Player.Id, AlwaysExistsForSelf)
		if AlwaysExistsForAll then
			for i=0,31 do
				SetNetworkIdAlwaysExistsForPlayer(NetId, i, true)
			end
		end
	end
	entities_set_can_migrate(entities_handle_to_pointer(Entity), CanMigrate)
	return NetId
end

return function(Entity, CanMigrate, AlwaysExistsForSelf, AlwaysExistsForAll, ExistsOnAll, ExistsOnAllPersistent, HijackFromOtherScripts)
--	if not NetworkGetEntityIsNetworked(Entity) then
--		NetworkRegisterEntityAsNetworked(Entity) -- doesnt appear to be necessary with set as mission entity
--	end
	if not NetworkHasEntityBeenRegisteredWithThisThread(Entity) then
		SetEntityAsMissionEntity(Entity, ExistsOnAllPersistent, HijackFromOtherScripts)
		NetworkRegisterEntityAsNetworked(Entity) -- doesnt appear to be necessary with set as mission entity
	end
	return SetPropertiesForEntityNetworkId(Entity, CanMigrate, AlwaysExistsForSelf, AlwaysExistsForAll, ExistsOnAll)
end