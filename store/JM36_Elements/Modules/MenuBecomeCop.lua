local RelationshipGroupToSet = "COP"

local menu = menu
local memory = memory

local Enabled, WasEnabled, LastPed, RelationshipGroupToRestore

local WantedLevel = 0

local MenuOption, MenuCommandOTR, MenuCommandWanted, MenuCommandWantedFake, MenuCommandWantedLock, MemoryPointer



local SetPedRelationshipGroupHash = SetPedRelationshipGroupHash
local SetPedAsCop = SetPedAsCop
local function ModeCopEnable(Ped)
	SetPedRelationshipGroupHash(Ped, RelationshipGroupToSet)
	SetPedAsCop(Ped, true)
end
local function ModeCopDisable(Ped, Restore, Group)
	if Restore then
		SetPedRelationshipGroupHash(Ped, Group or RelationshipGroupToRestore)
	end
	SetPedAsCop(Ped, false) -- Does nothing, needs to respawn
end



local menu_trigger_command = menu.trigger_command
local function Code3()
	WantedLevel = 2
	menu_trigger_command(MenuCommandWanted, 2)
end
local function Code4()
	WantedLevel = 0
	menu_trigger_command(MenuCommandWanted, 0)
	menu_trigger_command(MenuCommandWantedFake, 1)
end
local GetPedRelationshipGroupHash = GetPedRelationshipGroupHash
local function ModeCopEnableSelf(Ped)
	RelationshipGroupToRestore = GetPedRelationshipGroupHash(LastPed)
	ModeCopEnable(Ped)
	Code4()
	menu_trigger_command(MenuCommandOTR, 'on')
	menu_trigger_command(MenuCommandWantedLock, 'on')
	menu_trigger_command(MenuCommandWantedFake, 1)
end
local function ModeCopDisableSelf(Ped)
	ModeCopDisable(Ped, true, RelationshipGroupToRestore)
	menu_trigger_command(MenuCommandOTR, 'off')
	menu_trigger_command(MenuCommandWantedLock, 'off')
	menu_trigger_command(MenuCommandWantedFake, 0)
end



local entities_get_user_vehicle_as_handle = entities.get_user_vehicle_as_handle
local players_list = players.list
local memory_read_int = memory.read_int
return{
	init	=	function()
					MemoryPointer = memory.alloc()
					
					RelationshipGroupToSet = GetHashKey(RelationshipGroupToSet)
					
					local menu = menu
					
					local menu_ref_by_path = menu.ref_by_path
					MenuCommandOTR = menu_ref_by_path("Online>Off The Radar")
					MenuCommandWanted = menu_ref_by_path("Self>Set Wanted Level")
					MenuCommandWantedLock = menu_ref_by_path("Self>Lock Wanted Level")
					MenuCommandWantedFake = menu_ref_by_path("Self>Fake Wanted Level")
					
					MenuOption = menu.list(menu.my_root(), "Become a cop", {}, "Self explanitory")
					
					menu.toggle(MenuOption, "Enabled", {"beacop"}, "Sets your ped as a cop.", function(on)
						Enabled = on
						LastPed = Info.Player.Ped
						if Enabled then
							WasEnabled = true
							ModeCopEnableSelf(LastPed)
							return
						end
						ModeCopDisableSelf(LastPed)
					end)
					
					local menu_action = menu.action
					local menu_trigger_command = menu_trigger_command
					menu_action(MenuOption, "Code 4", {}, "", Code4)
					menu_action(MenuOption, "Code 2", {}, "", function()
						WantedLevel = 1
						menu_trigger_command(MenuCommandWanted, 1)
					end)
					menu_action(MenuOption, "Code 3", {}, "", Code3)
					local MenuCommandRecoverA = menu_ref_by_path("Self>Auto Heal")
					local MenuCommandRecoverB = menu_ref_by_path("Vehicle>Fix Vehicle")
					menu_action(MenuOption, "Recover", {}, "", function()
						menu_trigger_command(MenuCommandRecoverA, "on")
						menu_trigger_command(MenuCommandRecoverA, "off")
						menu_trigger_command(MenuCommandRecoverB)
					end)
				end,
	stop	=	function()
					memory.free(MemoryPointer)
					
					menu.delete(MenuOption)
					
					if WasEnabled then
						ModeCopDisableSelf(Info.Player.Ped)
						Code4()
					end
				end,
	loop	=	function()
					if WasEnabled then
						local Ped = Info.Player.Ped
						if Enabled then
							if Ped ~= LastPed then
								LastPed = Ped
								--ModeCopEnableSelf(LastPed)
								ModeCopEnable(LastPed)
							end
							if WantedLevel < 2 then
								local PedVeh = entities_get_user_vehicle_as_handle()
								local Players = players_list(false, IncludeFriends, true)
								for i=1, #Players do
									if GetEntityPlayerIsFreeAimingAt(Players[i], MemoryPointer) then
										local EntityAimedAt = memory_read_int(MemoryPointer)
										if EntityAimedAt == Ped or (PedVeh ~= 0 and EntityAimedAt == PedVeh) then
											Code3()
											break
										end
									end
								end
							end
							return
						end
						--ModeCopDisableSelf(LastPed)
						WasEnabled = false
					end
				end,
}