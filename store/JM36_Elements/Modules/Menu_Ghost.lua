local Info = Info
local Player = Info.Player
local Players = Info.Players

local yield = JM36.yield_once

local players_is_godmode = players.is_godmode -- GetPlayerInvincible

local SetRemotePlayerAsGhost = SetRemotePlayerAsGhost
local GetInteriorFromEntity = GetInteriorFromEntity
local IsEntityVisible = IsEntityVisible
local GetEntityCanBeDamaged = GetEntityCanBeDamaged
local GetEntityProofs = GetEntityProofs
local IsPedSittingInAnyVehicle = IsPedSittingInAnyVehicle
local GetVehiclePedIsUsing = GetVehiclePedIsUsing



local memory_alloc_int = memory.alloc_int
local MemPtr_FlagProofBullet, MemPtr_FlagProofFlame, MemPtr_FlagProofExplosion, MemPtr_FlagProofCollision, MemPtr_FlagProofMelee, MemPtr_FlagProofSteam, MemPtr_FlagDontResetDamageFlagsOnCleanupMissionState, MemPtr_FlagProofSmoke = memory_alloc_int(), memory_alloc_int(), memory_alloc_int(), memory_alloc_int(), memory_alloc_int(), memory_alloc_int(), memory_alloc_int(), memory_alloc_int()

local GhostAll, GhostUnkillable
JM36.CreateThread(function()
	while true do
		if GhostAll then
			for i=0,31 do
				if PlayerTable := Players[i] then
					PlayerTable.Ghosted = true
					SetRemotePlayerAsGhost(i,true)
				end
			end
		elseif GhostUnkillable then
			local CurrentInterior = GetInteriorFromEntity(Player.Ped);CurrentInterior = CurrentInterior ~= 0 ? CurrentInterior : false
			for i=0,31 do
				if (PlayerTable := Players[i]) and not PlayerTable.GhostedManual then
					local PlayerPed = PlayerTable.Ped;PlayerPed = ((PlayerPed ~= 0) ? PlayerPed : false)
					if PlayerPed then
						if CurrentInterior and (GetInteriorFromEntity(PlayerPed) == CurrentInterior) then
							SetRemotePlayerAsGhost(i,false)
							PlayerTable.Ghosted = false
						else
							if players_is_godmode(i) or not (IsEntityVisible(PlayerPed) and GetEntityCanBeDamaged(PlayerPed)) then
								SetRemotePlayerAsGhost(i,true)
								PlayerTable.Ghosted = true
							else
								local RetVal, FlagProofBullet, FlagProofFlame, FlagProofExplosion, FlagProofCollision, FlagProofMelee, FlagProofSteam, FlagDontResetDamageFlagsOnCleanupMissionState, FlagProofSmoke = GetEntityProofs(PlayerPed, MemPtr_FlagProofBullet, MemPtr_FlagProofFlame, MemPtr_FlagProofExplosion, MemPtr_FlagProofCollision, MemPtr_FlagProofMelee, MemPtr_FlagProofSteam, MemPtr_FlagDontResetDamageFlagsOnCleanupMissionState, MemPtr_FlagProofSmoke)
								if RetVal and (FlagProofBullet or FlagProofExplosion or FlagProofCollision or FlagProofMelee) then
									SetRemotePlayerAsGhost(i,true)
									PlayerTable.Ghosted = true
								else
									local PlayerVeh = (IsPedSittingInAnyVehicle(PlayerPed) ? GetVehiclePedIsUsing(PlayerPed) : false)
									if PlayerVeh then
										if not (IsEntityVisible(PlayerVeh) and GetEntityCanBeDamaged(PlayerVeh)) then
											SetRemotePlayerAsGhost(i,true)
											PlayerTable.Ghosted = true
										else
											RetVal, FlagProofBullet, FlagProofFlame, FlagProofExplosion, FlagProofCollision, FlagProofMelee, FlagProofSteam, FlagDontResetDamageFlagsOnCleanupMissionState, FlagProofSmoke = GetEntityProofs(PlayerVeh, MemPtr_FlagProofBullet, MemPtr_FlagProofFlame, MemPtr_FlagProofExplosion, MemPtr_FlagProofCollision, MemPtr_FlagProofMelee, MemPtr_FlagProofSteam, MemPtr_FlagDontResetDamageFlagsOnCleanupMissionState, MemPtr_FlagProofSmoke)
											if RetVal and (FlagProofBullet or FlagProofExplosion or FlagProofCollision or FlagProofMelee) then
												SetRemotePlayerAsGhost(i,true)
												PlayerTable.Ghosted = true
											else
												SetRemotePlayerAsGhost(i,false)
												PlayerTable.Ghosted = false
											end
										end
									else
										SetRemotePlayerAsGhost(i,false)
										PlayerTable.Ghosted = false
									end
								end
							end
						end
					end
				end
			end
		end
		yield()
	end
end)

local players_exists = players.exists
players.add_command_hook(function(PlayerId,PlayerRoot)
	PlayerRoot:toggle("Ghost", {"ghost"}, "", function(State)
		Players[PlayerId].GhostedManual=State
	end)
end)

do
	local Menu = Info.MenuLayout.Main:list("Ghosting (Passive)", DummyCmdTbl, "")
	Menu:toggle("Ghost All", {"ghostall"}, "", function(State)
		GhostAll=State
	end)
	Menu:toggle("Ghost Unkillable", {"ghostgod","ghostunkillable"}, "Ghost God", function(State)
		GhostUnkillable=State
	end)
end

return{stop=function()fori=0,31 do SetRemotePlayerAsGhost(i,false) end end}
