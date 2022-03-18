local CreateCacheSimpleForFunction = require'CreateCacheSimpleForFunction'

local GetWeapontypeModel = CreateCacheSimpleForFunction(GetWeapontypeModel)
local GetWeapontypeGroup = CreateCacheSimpleForFunction(GetWeapontypeGroup)
local DoesEntityExist = DoesEntityExist
local DeleteEntity = DeleteEntity
local IsPedArmed = IsPedArmed
local GetSelectedPedWeapon = GetSelectedPedWeapon
local CreateObject = CreateObject
local SetNetworkIdCanMigrate = SetNetworkIdCanMigrate
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local AttachEntityToEntity = AttachEntityToEntity
--local SetEntityCleanupByEngine = SetEntityCleanupByEngine

local menu = menu
local memory = memory
local memory_alloc = memory.alloc
local memory_write_int = memory.write_int
local memory_free = memory.free



local WeaponGroupMelee = GetHashKey"group_melee"



local LastWeaponEntityModel, CurrentWeaponEntityOnBack, CurrentWeaponEntityModelOnBack = 0, 0, 0
local LastWeaponIsMeleeWeapon = false

local function RemoveCurrentWeaponEntityOnBack()
	if CurrentWeaponEntityOnBack ~= 0 and DoesEntityExist(CurrentWeaponEntityOnBack) then
		local Mem = memory_alloc()
		memory_write_int(Mem, CurrentWeaponEntityOnBack)
		DeleteEntity(Mem)
		memory_free(Mem)
		CurrentWeaponEntityOnBack = 0
	end
end

local Enabled, MenuOption
local WeaponsOnBackModule WeaponsOnBackModule = {
	init	=	function()
					do
						local config = configFileRead("LastWeaponOnBack.ini")
						Enabled = toboolean(config.Enabled)
					end
					
					MenuOption = menu.toggle(menu.my_root(), "Last Weapon On Back", {}, "Puts your last used weapon on your back.", function(state)
						Enabled = state
						if not state then RemoveCurrentWeaponEntityOnBack() end
						configFileWrite("LastWeaponOnBack.ini", {Enabled = state})
					end, Enabled)
				end,
	stop	=	function()
					RemoveCurrentWeaponEntityOnBack()
					menu.delete(MenuOption)
				end,
	loop	=	function(Info)
					if Enabled then
						local Player_Ped = Info.Player.Ped
						if IsPedArmed(Player_Ped, 7) then
							RemoveCurrentWeaponEntityOnBack()
							local SelectedPedWeapon = GetSelectedPedWeapon(Player_Ped)
							LastWeaponEntityModel = GetWeapontypeModel(SelectedPedWeapon)
							LastWeaponIsMeleeWeapon = GetWeapontypeGroup(SelectedPedWeapon) == WeaponGroupMelee
						else
							if LastWeaponEntityModel ~= CurrentWeaponEntityModelOnBack then
								RemoveCurrentWeaponEntityOnBack()
								CurrentWeaponEntityOnBack = CreateObject(LastWeaponEntityModel, 1.0, 1.0, 1.0, true, true, false)
								SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(CurrentWeaponEntityOnBack), false)
								if not LastWeaponIsMeleeWeapon then
									AttachEntityToEntity(CurrentWeaponEntityOnBack, Player_Ped, GetPedBoneIndex(Player_Ped, 24816), 0.075, -0.15, -0.02, 0.0, 165.0, 0.0, true, true, false, false, 2, true)
								else
									AttachEntityToEntity(CurrentWeaponEntityOnBack, Player_Ped, GetPedBoneIndex(Player_Ped, 24816), 0.11, -0.14, 0.0, -75.0, 185.0, 92.0, true, true, false, false, 2, true)
								end
								--SetEntityCleanupByEngine(CurrentWeaponEntityOnBack, false)
							end
						end
					end
				end,
}
return WeaponsOnBackModule