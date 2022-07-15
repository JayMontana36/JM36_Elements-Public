local JM36 <const> = JM36
local yield <const> = JM36.yield
local CreateThread <const> = JM36.CreateThread

local config
local PersonalVehicleIsPlane, PersonalVehicleIsHeli, PersonalVehicleIsOther = false, false, false
local PersonalVehicle, _PersonalVehicle, PersonalVehicleBlip
CreateThread(function()
	local config <const> = config
	local DoesEntityExist <const> = DoesEntityExist
	local GetPedInVehicleSeat <const> = GetPedInVehicleSeat
	local NetworkRequestControlOfEntity <const> = NetworkRequestControlOfEntity
	local yield <const> = yield
	while true do
		local PersonalVehicle <const> = PersonalVehicle
		if PersonalVehicle ~= 0 and DoesEntityExist(PersonalVehicle) then
			local VehicleExclusiveDriver <const> = VehicleExclusiveDriver
			if VehicleExclusiveDriver or GetPedInVehicleSeat(PersonalVehicle, -1) == 0 then
				NetworkRequestControlOfEntity(PersonalVehicle)
				SetNetworkIdCanMigrate(_PersonalVehicle, false)
--			elseif not VehicleExclusiveDriver then
--				SetNetworkIdCanMigrate(_PersonalVehicle, true)
			end
		end
		yield()
	end
end)

local Menu
return
{
	init	=	function()
					do
						local toboolean <const> = toboolean
						config = configFileRead("MenuPersonalVehicle.ini") local config <const> = config
						
						if config.EnginesAlwaysOn == nil then
							config.EnginesAlwaysOn = true
						end
						config.EnginesAlwaysOn = toboolean(config.EnginesAlwaysOn)
						if config.DoorLockForSelf == nil then
							config.DoorLockForSelf = true
						end
						config.DoorLockForSelf = toboolean(config.DoorLockForSelf)
						if config.DoorLockHard == nil then
							config.DoorLockHard = false
						end
						config.DoorLockHard = toboolean(config.DoorLockHard)
						if config.VehicleBlipEnable == nil then
							config.VehicleBlipEnable = true
						end
						config.VehicleBlipEnable = toboolean(config.VehicleBlipEnable)
						if config.VehicleExclusiveDriver == nil then
							config.VehicleExclusiveDriver = false
						end
						config.VehicleExclusiveDriver = toboolean(config.VehicleExclusiveDriver)
					end
					
					do
						local BlipNameLabel <const> = util.register_label"Elements Personal Vehicle"
						
						local menu <const> = menu
						local menu_list <const> = menu.list
						local menu_action <const> = menu.action
						
						Menu = menu_list(require'Menu_Vehicle', "Personal Vehicle", {"vehj pv"}, "Personal Vehicle")
						local Menu <const> = Menu
						local Info <const> = Info
						local RequestEntityControl <const> = require'RequestEntityControl'
						local PressKeyFob <const> = require'PressKeyFob'
						
						--[[ Press KeyFob ]]
						do
							menu_action(Menu, "Press KeyFob", {}, "", function()
								PressKeyFob(PersonalVehicle)
							end)
						end
						
						-- Personal Vehicle Name/Label Divider Here
						
						--[[ Set Vehicle ]]
						do
							local PtrMem <const> = require'Memory_SharedIntegerPointerSingle'
							local Player <const> = Info.Player
							local Vehicle <const> = Player.Vehicle
							local Type <const> = Vehicle.Type
							local CreateThread <const> = util.create_thread
							local SetNetworkIdAlwaysExistsForPlayer <const> = SetNetworkIdAlwaysExistsForPlayer
							local memory_write_int <const> = memory.write_int
							local RemoveBlip <const> = RemoveBlip
							local SetEntityCleanupByEngine <const> = SetEntityCleanupByEngine
							local SetEntityAsNoLongerNeeded <const> = SetEntityAsNoLongerNeeded
							local SetEntityAsMissionEntity <const> = SetEntityAsMissionEntity
							local GetVehicleModelNumberOfSeats <const> = GetVehicleModelNumberOfSeats
							local SetVehicleExclusiveDriver <const> = require'SetVehicleExclusiveDriver'
							local GetBlipFromEntity <const> = GetBlipFromEntity
							local AddBlipForEntity <const> = AddBlipForEntity
							local BeginTextCommandSetBlipName <const> = BeginTextCommandSetBlipName
							local EndTextCommandSetBlipName <const> = EndTextCommandSetBlipName
							local SetBlipSprite <const> = SetBlipSprite
							local ShowHeadingIndicatorOnBlip <const> = ShowHeadingIndicatorOnBlip
							local SetBlipAsMinimalOnEdge <const> = SetBlipAsMinimalOnEdge
							menu_action(Menu, "Set Vehicle", {}, "Sets your current vehicle as your personal vehicle. If you already have a personal vehicle set then this will override your selection.", function()
								local __PersonalVehicle <const> = Vehicle.Id
								if __PersonalVehicle ~= 0 and RequestEntityControl(__PersonalVehicle) then
									if PersonalVehicle ~= 0 then
										local PersonalVehicle <const>, _PersonalVehicle <const>, PersonalVehicleBlip <const> = PersonalVehicle, _PersonalVehicle, PersonalVehicleBlip
										CreateThread(function()
											if RequestEntityControl(PersonalVehicle) then
												if config.VehicleExclusiveDriver then
													SetVehicleExclusiveDriver(PersonalVehicle, _PersonalVehicle, false)
												else
													SetNetworkIdAlwaysExistsForPlayer(_PersonalVehicle, Player.Id, false)
												end
												if config.VehicleBlipEnable and DoesBlipExist(PersonalVehicleBlip) then
													memory_write_int(PtrMem, PersonalVehicleBlip)
													RemoveBlip(PtrMem)
												end
												SetEntityCleanupByEngine(PersonalVehicle, true)
												memory_write_int(PtrMem, PersonalVehicle)
												SetEntityAsNoLongerNeeded(PtrMem)
											end
										end)
									end
									
									PersonalVehicle = __PersonalVehicle
									_PersonalVehicle = Vehicle.NetId
									local _PersonalVehicle <const> = _PersonalVehicle
									
									SetNetworkIdAlwaysExistsForPlayer(_PersonalVehicle, Player.Id, true)
									SetEntityCleanupByEngine(__PersonalVehicle, false)
									SetEntityAsMissionEntity(__PersonalVehicle, true, true)
									--SetVehicleExtendedRemovalRange(PersonalVehicle, 32767)--fails to function as expected, appears to make vehicles despawn sooner
									
									PersonalVehicleIsPlane, PersonalVehicleIsHeli = Type.Plane, Type.Heli
									PersonalVehicleIsOther = PersonalVehicleIsPlane == PersonalVehicleIsHeli
									PersonalVehicleNumSeats = GetVehicleModelNumberOfSeats(Vehicle.Model)
									
									if config.VehicleExclusiveDriver then
										SetVehicleExclusiveDriver(__PersonalVehicle, _PersonalVehicle, true)
									end
									if config.VehicleBlipEnable then
										if GetBlipFromEntity(PersonalVehicle) == 0 then
											PersonalVehicleBlip = AddBlipForEntity(PersonalVehicle)
											local PersonalVehicleBlip <const> = PersonalVehicleBlip
											BeginTextCommandSetBlipName(BlipNameLabel)
											EndTextCommandSetBlipName(PersonalVehicleBlip)
											SetBlipSprite(PersonalVehicleBlip, 794)
											ShowHeadingIndicatorOnBlip(PersonalVehicleBlip, true)
											SetBlipAsMinimalOnEdge(PersonalVehicleBlip, true)
										else
											PersonalVehicleBlip = 0
										end
									end
									
									PressKeyFob(PersonalVehicle, true)
								end
							end)
						end
						
						--[[ Toggle Engine ]]
						do
							local GetIsVehicleEngineRunning <const> = GetIsVehicleEngineRunning
							local SetVehicleEngineOn <const> = SetVehicleEngineOn
							local SetVehicleJetEngineOn <const> = SetVehicleJetEngineOn
							local SetHeliBladesSpeed <const> = SetHeliBladesSpeed
							menu_action(Menu, "Toggle Engine", {}, "Toggles the engine on or off, even when you're not inside of the vehicle. This does not work if someone else is currently using your vehicle.", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									local EngineRunning <const> = not GetIsVehicleEngineRunning(PersonalVehicle)
									SetVehicleEngineOn(PersonalVehicle, EngineRunning, true, not EngineRunning)
									if not PersonalVehicleIsOther then
										if PersonalVehicleIsPlane then
											SetVehicleJetEngineOn(PersonalVehicle, EngineRunning)
										elseif PersonalVehicleIsHeli then
											SetHeliBladesSpeed(PersonalVehicle, EngineRunning and 1.0 or 0.0)
										end
									end
								end
							end)
						end
						
						--[[ Toggle Lights ]]
						--[[
						do
							menu_action(Menu, "Toggle Lights", {}, "This will enable or disable your vehicle headlights, the engine of your vehicle needs to be running for this to work.", function()
								local PersonalVehicle = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									
								end
							end)
						end
						]]
						
						--[[ Kick Passengers ]]
						do
							local Player <const> = Info.Player
							local DoesEntityExist <const> = DoesEntityExist
							local GetPedInVehicleSeat <const> = GetPedInVehicleSeat
							local IsPedAPlayer <const> = IsPedAPlayer
							local NetworkGetPlayerIndexFromPed <const> = NetworkGetPlayerIndexFromPed
							local menu_player_root <const> = menu.player_root
							local menu_ref_by_rel_path <const> = menu.ref_by_rel_path
							local menu_trigger_command <const> = menu.trigger_command
							local ClearPedTasksImmediately <const> = ClearPedTasksImmediately
							menu_action(Menu, "Kick Passengers", {}, "This will remove all passengers from your personal vehicle.", function()
								local PersonalVehicle <const> = PersonalVehicle
								if DoesEntityExist(PersonalVehicle) then
									local Player_Ped <const> = Player.Ped
									PressKeyFob(PersonalVehicle)
									for i=-1, PersonalVehicleNumSeats-2 do
										local Ped <const> = GetPedInVehicleSeat(PersonalVehicle, i)
										if Ped ~= 0 and Ped ~= Player_Ped then
											if IsPedAPlayer(Ped) then
												menu_trigger_command(menu_ref_by_rel_path(menu_player_root(NetworkGetPlayerIndexFromPed(Ped)), "Trolling>Kick From Vehicle"))
											else
												local Ped <const> = Ped
												if RequestEntityControl(Ped) then
													ClearPedTasksImmediately(Ped)
												end
											end
										end
									end
								end
							end)
						end
						
						--[[ Lock/Unlock Doors ]]
						do
							local Player <const> = Info.Player
							--local SetVehicleDoorsLocked <const> = SetVehicleDoorsLocked
							local SetVehicleDoorsLockedForAllPlayers <const> = SetVehicleDoorsLockedForAllPlayers
							local SetVehicleIsConsideredByPlayer <const> = SetVehicleIsConsideredByPlayer
							local SetVehicleDoorsLockedForPlayer <const> = SetVehicleDoorsLockedForPlayer
							menu_action(Menu, "Lock Doors", {}, "This will lock all your vehicle doors for all players. Anyone already inside will always be able to leave the vehicle, even if the doors are locked.", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									--SetVehicleDoorsLocked(PersonalVehicle, 4) -- GlobalGeneralDoorLockState
									SetVehicleDoorsLockedForAllPlayers(PersonalVehicle, true)
									--SetVehicleIsConsideredByPlayer(PersonalVehicle, false) -- DoorLockHard
									SetVehicleDoorsLockedForPlayer(PersonalVehicle, Info.Player.Id, false)
								end
							end)
							menu_action(Menu, "Unlock Doors", {}, "This will unlock all your vehicle doors for all players.", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									--SetVehicleDoorsLocked(PersonalVehicle, 1) -- GlobalGeneralDoorLockState
									SetVehicleDoorsLockedForAllPlayers(PersonalVehicle, false)
									--SetVehicleIsConsideredByPlayer(PersonalVehicle, true) -- DoorLockHard
									SetVehicleDoorsLockedForPlayer(PersonalVehicle, Info.Player.Id, false)
								end
							end)
						end
						
						--[[ Sound Horn ]]
						do
							local SetNetworkIdCanMigrate <const> = SetNetworkIdCanMigrate
							local SetHornPermanentlyOn <const> = SetHornPermanentlyOn
							local util_yield <const> = util.yield
							local SoundHornPV <const> = function(TimeOut)
								local _PersonalVehicle <const>, PersonalVehicle <const> = _PersonalVehicle, PersonalVehicle
								local TimeOut <const> = Info.Time + ((TimeOut or 1) * 1000)
								while Info.Time < TimeOut and RequestEntityControl(PersonalVehicle) do
									SetNetworkIdCanMigrate(_PersonalVehicle, false)
									SetHornPermanentlyOn(PersonalVehicle)
									util_yield()
								end
								SetNetworkIdCanMigrate(_PersonalVehicle, true)
							end
							menu_action(Menu, "Sound Horn", {}, "Sounds the horn of the vehicle.", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									SoundHornPV(1)
								end
							end)
						end
						
						--[[ Toggle Alarm ]]
						do
							local SetVehicleAlarm <const> = SetVehicleAlarm
							local IsVehicleAlarmActivated <const> = IsVehicleAlarmActivated
							local StartVehicleAlarm <const> = StartVehicleAlarm
							menu_action(Menu, "Toggle Alarm", {}, "Toggles the vehicle alarm sound on or off. This does not set an alarm. It only toggles the current sounding status of the alarm.", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									SetVehicleAlarm(PersonalVehicle, not IsVehicleAlarmActivated(PersonalVehicle))
									StartVehicleAlarm(PersonalVehicle)
								end
							end)
						end
						
						--[[ Disable Vehicle && Bait / Booby Trap && Self Destruct ]]
						do
							local SetVehicleDoorsLockedForAllPlayers <const> = SetVehicleDoorsLockedForAllPlayers
							local SetVehicleDoorsLocked <const> = SetVehicleDoorsLocked
							local SetVehicleIsConsideredByPlayer <const> = SetVehicleIsConsideredByPlayer
							local SetVehicleEngineOn <const> = SetVehicleEngineOn
							local SetVehicleUndriveable <const> = SetVehicleUndriveable
							local SetVehicleAlarm <const> = SetVehicleAlarm
							local StartVehicleAlarm <const> = StartVehicleAlarm
							
							menu_action(Menu, "Disable Vehicle", {}, "Makes the semi-vehicle inoperable and traps players inside (including yourself)", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									SetVehicleDoorsLockedForAllPlayers(PersonalVehicle, true)
									SetVehicleDoorsLocked(PersonalVehicle, 4)
									SetVehicleIsConsideredByPlayer(PersonalVehicle, false)
									SetVehicleEngineOn(PersonalVehicle, false, true, true)
									SetVehicleUndriveable(PersonalVehicle, true)
									SetVehicleAlarm(PersonalVehicle, true)
									StartVehicleAlarm(PersonalVehicle)
								end
							end)
							
							local DoesEntityExist <const> = DoesEntityExist
							local IsEntityDead <const> = IsEntityDead
							local GetPedInVehicleSeat <const> = GetPedInVehicleSeat
							local GetEntityCanBeDamaged <const> = GetEntityCanBeDamaged
							local SetEntityInvincible <const> = SetEntityInvincible
							--local SetVehicleControlsInverted <const> = SetVehicleControlsInverted
							local SetVehicleOutOfControl <const> = SetVehicleOutOfControl
							local NetworkExplodeVehicle <const> = NetworkExplodeVehicle
							local util_yield <const> = util.yield
							local BaitBoobyTrapPV <const> = function(ExcludePed)
								local ExcludePed <const> = ExcludePed
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									SetVehicleExclusiveDriver(PersonalVehicle, _PersonalVehicle, false)
									SetVehicleDoorsLocked(PersonalVehicle, 1)
									SetVehicleDoorsLockedForAllPlayers(PersonalVehicle, false)
									SetVehicleIsConsideredByPlayer(PersonalVehicle, true)
									SetVehicleEngineOn(PersonalVehicle, true, true, false)
									SetVehicleAlarm(PersonalVehicle, true)
									local PersonalVehicleNumSeats <const> = PersonalVehicleNumSeats - 2
									while DoesEntityExist(PersonalVehicle) and not IsEntityDead(PersonalVehicle) do
										for i=-1, PersonalVehicleNumSeats do
											local Ped <const> = GetPedInVehicleSeat(PersonalVehicle, i)
											if Ped ~= 0 and Ped ~= ExcludePed then
												if RequestEntityControl(PersonalVehicle) then
													if not GetEntityCanBeDamaged(PersonalVehicle) then
														SetEntityInvincible(PersonalVehicle, false)
													end
													--SetVehicleControlsInverted(PersonalVehicle, true)
													SetVehicleOutOfControl(PersonalVehicle, false, true)
													NetworkExplodeVehicle(PersonalVehicle, true, false, false)
													--return
												end
												break
											end
										end
										util_yield()
									end
								end
							end
							
							do
								local Player <const> = Info.Player
								menu_action(Menu, "Bait / Booby Trap", {}, "Self Explanitory", function()
									BaitBoobyTrapPV(Player.Ped)
								end)
							end
							
							menu_action(Menu, "Bait / Booby Trap 2", {}, "Self Explanitory (Including Self)", function()
								BaitBoobyTrapPV()
							end)
							
							menu_action(Menu, "Self Destruct", {}, "Self Explanitory", function()
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									if not GetEntityCanBeDamaged(PersonalVehicle) then
										SetEntityInvincible(PersonalVehicle, false)
									end
									SetVehicleOutOfControl(PersonalVehicle, false, true)
									NetworkExplodeVehicle(PersonalVehicle, true, false, false)
								end
							end)
						end
						
						--[[ Settings ]]
						do
							local Menu <const> = menu_list(Menu, "Settings", {}, "Settings")
							local menu_toggle <const> = menu.toggle
							
							--[[ Add Blip ]]
							do
								local PtrMem <const> = require'Memory_SharedIntegerPointerSingle'
								local config <const> = config
								local GetBlipFromEntity <const> = GetBlipFromEntity
								local AddBlipForEntity <const> = AddBlipForEntity
								local BeginTextCommandSetBlipName <const> = BeginTextCommandSetBlipName
								local EndTextCommandSetBlipName <const> = EndTextCommandSetBlipName
								local SetBlipSprite <const> = SetBlipSprite
								local ShowHeadingIndicatorOnBlip <const> = ShowHeadingIndicatorOnBlip
								local SetBlipAsMinimalOnEdge <const> = SetBlipAsMinimalOnEdge
								local DoesBlipExist <const> = DoesBlipExist
								local memory_write_int <const> = memory.write_int
								local RemoveBlip <const> = RemoveBlip
								menu_toggle(Menu, "Add Blip", {}, "Enables or disables the blip that gets added when you mark a vehicle as your personal vehicle.", function(state)
									local state <const> = state
									config.VehicleBlipEnable = state
									local PersonalVehicle <const> = PersonalVehicle
									if RequestEntityControl(PersonalVehicle) then
										PressKeyFob(PersonalVehicle)
										if state then
											if GetBlipFromEntity(PersonalVehicle) == 0 then
												PersonalVehicleBlip = AddBlipForEntity(PersonalVehicle)
												local PersonalVehicleBlip <const> = PersonalVehicleBlip
												BeginTextCommandSetBlipName(BlipNameLabel)
												EndTextCommandSetBlipName(PersonalVehicleBlip)
												SetBlipSprite(PersonalVehicleBlip, 794)
												ShowHeadingIndicatorOnBlip(PersonalVehicleBlip, true)
												SetBlipAsMinimalOnEdge(PersonalVehicleBlip, true)
											end
										elseif DoesBlipExist(PersonalVehicleBlip) then
											memory_write_int(PtrMem, PersonalVehicleBlip)
											RemoveBlip(PtrMem)
										end
									end
								end, config.VehicleBlipEnable)
							end
							
							--[[ Exclusive Driver ]]
							menu_toggle(Menu, "Exclusive Driver", {}, "If enabled, then you will be the only one that can enter the drivers seat. Other players will not be able to drive the car. They can still be passengers.", function(state)
								local state <const> = state
								config.VehicleExclusiveDriver = state
								local PersonalVehicle <const> = PersonalVehicle
								if RequestEntityControl(PersonalVehicle) then
									PressKeyFob(PersonalVehicle)
									SetVehicleExclusiveDriver(PersonalVehicle, _PersonalVehicle, state)
								end
							end, config.VehicleExclusiveDriver)
							
							--[[ Auto Mode ]] -- Remove or improve in future revision; add Stand menu god.
							do
								menu_toggle(Menu, "Auto Mode", {}, "Hide yourself", function(state)
									local state <const> = state
									local _state <const> = state and 'on' or 'off'
									if state then
										SetEntityInvincible(PersonalVehicle, true)
									end
									menu_trigger_command(string_format('otr %s', _state))
									menu_trigger_command(string_format('invisibility %s', _state))
								end, false)
							end
						end
					end
				end,
	stop	=	function()
					config = configFileWrite("MenuPersonalVehicle.ini", config) -- Writes settings to ini and sets config to nil
					menu.delete(Menu)
				end,
}