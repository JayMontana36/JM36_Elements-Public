local Player = Info.Player

local CreateCacheSimpleForFunction = require'CreateCacheSimpleForFunction'

local entities_create_object = entities.create_object
local entities_delete_by_handle = entities.delete_by_handle

local IsPedArmed = IsPedArmed
local GetSelectedPedWeapon = GetSelectedPedWeapon
local GetWeapontypeModel = CreateCacheSimpleForFunction(GetWeapontypeModel)
local GetWeapontypeGroup = CreateCacheSimpleForFunction(GetWeapontypeGroup)
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local SetEntityCollision = SetEntityCollision
local SetEntityCompletelyDisableCollision = SetEntityCompletelyDisableCollision
local AttachEntityToEntity = AttachEntityToEntity
local GetPedBoneIndex = GetPedBoneIndex
local DoesEntityExist = DoesEntityExist
local ObjToNet = ObjToNet
local SetNetworkIdExistsOnAllMachines = SetNetworkIdExistsOnAllMachines
local SetNetworkIdCanMigrate = SetNetworkIdCanMigrate

local CreateThread = JM36.CreateThread
local yield = JM36.yield

local CurrentlyArmed
local LastWeaponEntityModel = 0
local LastWeaponIsMeleeWeapon = false
local CurrentWeaponEntityOnBack = 0
local UnarmedHandlerRunning = false
local WeaponGroupMelee;CreateThread(function()WeaponGroupMelee=GetHashKey"group_melee"end)
local Enabled = toboolean(configFileRead("LastWeaponOnBack.ini").Enabled)

menu.toggle(menu.my_root(), "Last Weapon On Back", {}, "Puts your last used weapon on your back.", function(state, click_type)
	if click_type == CLICK_MENU then
		configFileWrite("LastWeaponOnBack.ini", {Enabled = state})
	end
	Enabled = state
end, Enabled)

CreateThread(function()
	while true do
		if Enabled then
			local Player_Ped = Player.Ped
			CurrentlyArmed = IsPedArmed(Player_Ped, 7)
			if CurrentlyArmed then
				--remove weapon
				local SelectedPedWeapon = GetSelectedPedWeapon(Player_Ped)
				LastWeaponEntityModel = GetWeapontypeModel(SelectedPedWeapon)
				LastWeaponIsMeleeWeapon = GetWeapontypeGroup(SelectedPedWeapon) == WeaponGroupMelee
			elseif not UnarmedHandlerRunning --[[or (CurrentWeaponEntityOnBack ~= 0 and not DoesEntityExist(CurrentWeaponEntityOnBack))]] then
				UnarmedHandlerRunning = true
				CreateThread(function()
					CurrentWeaponEntityOnBack = entities_create_object(LastWeaponEntityModel, Player.Coords)
					if CurrentWeaponEntityOnBack ~= 0 then
						SetEntityAsMissionEntity(CurrentWeaponEntityOnBack, true, true)
						SetEntityCollision(CurrentWeaponEntityOnBack, false, false)
						SetEntityCompletelyDisableCollision(CurrentWeaponEntityOnBack, not true, false)
						if not LastWeaponIsMeleeWeapon then
							AttachEntityToEntity(CurrentWeaponEntityOnBack, Player_Ped, GetPedBoneIndex(Player_Ped, 24816), 0.075, -0.15, -0.02, 0.0, 165.0, 0.0, true, true, false, false, 2, true)
						else
							AttachEntityToEntity(CurrentWeaponEntityOnBack, Player_Ped, GetPedBoneIndex(Player_Ped, 24816), 0.11, -0.14, 0.0, -75.0, 185.0, 92.0, true, true, false, false, 2, true)
						end
						CreateThread(function()
							while DoesEntityExist(CurrentWeaponEntityOnBack) do
								local _CurrentWeaponEntityOnBack = ObjToNet(CurrentWeaponEntityOnBack)
								if _CurrentWeaponEntityOnBack ~= 0 then
									SetNetworkIdExistsOnAllMachines(_CurrentWeaponEntityOnBack, true)
									SetNetworkIdCanMigrate(_CurrentWeaponEntityOnBack, false)
									break
								end
								yield()
							end
						end)
						while Enabled and UnarmedHandlerRunning and not CurrentlyArmed do
							yield()
						end
						if DoesEntityExist(CurrentWeaponEntityOnBack) then
							entities_delete_by_handle(CurrentWeaponEntityOnBack)
						end
						CurrentWeaponEntityOnBack = 0
					end
					UnarmedHandlerRunning = false
				end)
			end
		end
		yield()
	end
end)

return
{
	stop	=	function()
					if CurrentWeaponEntityOnBack ~= 0 and DoesEntityExist(CurrentWeaponEntityOnBack) then
						entities_delete_by_handle(CurrentWeaponEntityOnBack)
					end
				end,
}
