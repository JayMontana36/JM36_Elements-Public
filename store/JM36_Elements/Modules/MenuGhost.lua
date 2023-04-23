local GetEntityCanBeDamaged_Original <const> = GetEntityCanBeDamaged
local GetEntityCanBeDamaged
do
	local memory_read_int = memory.read_int
	local bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof = memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int()
	GetEntityCanBeDamaged = function(Entity)
		GetEntityProofs(Entity, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof)
		pluto_switch GetEntityType(Entity) do
			case 1:
				if IsPedAPlayer(Entity) then
					return
					(
						(
							not players.is_godmode(NetworkGetPlayerIndexFromPed(Entity))
							and GetEntityCanBeDamaged_Original(Entity)
						)
						and
						not
						(
							memory_read_int(bulletProof)~=0
							--or memory_read_int(fireProof)~=0
							or memory_read_int(explosionProof)~=0
							--or memory_read_int(collisionProof)~=0
							or memory_read_int(meleeProof)~=0
							--or memory_read_int(steamProof)~=0
							--or memory_read_int(p7)~=0
							--or memory_read_int(drownProof~=0
						)
					)
				end
            default:
                return
				(
					GetEntityCanBeDamaged_Original(Entity)
					and
					not
					(
						memory_read_int(bulletProof)~=0
						--or memory_read_int(fireProof)~=0
						or memory_read_int(explosionProof)~=0
						--or memory_read_int(collisionProof)~=0
						or memory_read_int(meleeProof)~=0
						--or memory_read_int(steamProof)~=0
						--or memory_read_int(p7)~=0
						--or memory_read_int(drownProof)~=0
					)
				)
		end
		--return GetEntityCanBeDamaged_Original(Entity)
	end
end

local JM36 <const> = JM36
local yield <const> = JM36.yield
local CreateThread <const> = JM36.CreateThread

local config
local GhostState <const>, _GhostState <const> = {}, {}
CreateThread(function()
	local TimeForceUpdate = 0
	local Info <const> = Info
	local players_list <const> = players.list
	local SetRelationshipToPlayer <const> = SetRelationshipToPlayer
	local GetPlayerPed <const> = GetPlayerPed
	local GetEntityCanBeDamaged <const> = GetEntityCanBeDamaged
	local IsEntityVisible <const> = IsEntityVisible
	local GetVehiclePedIsUsing <const> = GetVehiclePedIsUsing
	local config <const> = config
	local yield <const> = yield
	while true do
		local GhostAll <const>, GhostGod <const> = config.GhostAll, config.GhostGod
		if GhostAll or GhostGod then
			local Time <const> = Info.Time
			local ShouldForceUpdate <const> = Time >= TimeForceUpdate
			if ShouldForceUpdate then
				TimeForceUpdate = Time + 15000
			end
			
			if GhostAll then
				if ShouldForceUpdate then
					local Players <const> = players_list(false,true,true)
					for i=1, #Players do
						SetRelationshipToPlayer(Players[i], true)
					end
				end
			elseif GhostGod then
				local Players <const> = players_list(false,true,true)
				for i=1, #Players do
					local Player <const> = Players[i]
					if not _GhostState[Player] then
						local Ped <const> = GetPlayerPed(Player)
						local state = Ped ~= 0 and GetEntityCanBeDamaged(Ped) and IsEntityVisible(Ped)
						if state then
							local Vehicle <const> = GetVehiclePedIsUsing(Ped)
							if Vehicle ~= 0 then
								state = GetEntityCanBeDamaged(Vehicle) and IsEntityVisible(Vehicle)
							end
						end
						
						local state <const> = not state
						if state ~= GhostState[Player] or ShouldForceUpdate then
							GhostState[Player] = state
							SetRelationshipToPlayer(Player, state)
						end
					end
				end
			end
		end
		yield()
	end
end)

local MenuPlayer <const> = {}
local Join
do
	local menu <const> = menu
	local players <const> = players
	local players_exists <const> = players.exists
	local menu_player_root <const> = menu.player_root
	local menu_divider <const> = menu.divider
	local menu_toggle <const> = menu.toggle
	local players_get_name <const> = players.get_name
	local menu_trigger_command <const> = menu.trigger_command
	local util_yield <const> = util.yield
	Join = function(PlayerId)
		local PlayerId <const> = PlayerId
		if players_exists(PlayerId) then
			local Menu <const> = menu_player_root(PlayerId)
			local _Menu <const> = {0,0}
			_Menu[1] = menu_divider(Menu, "Ghosting/Passive")
			local _MenuOption2 <const> = menu_toggle(Menu, "Ghost "..players_get_name(PlayerId), {}, "", function(state)
				local state <const> = state
				GhostState[PlayerId] = state
				_GhostState[PlayerId] = state
				SetRelationshipToPlayer(PlayerId, state)
			end, false)
			_Menu[2] = _MenuOption2
			MenuPlayer[PlayerId] = _Menu
			if config.GhostAll then
				menu_trigger_command(_MenuOption2, 'on')
			end
		end
	end
end

local OnLeaveHandler -- fix/remove this, add on_leave to modularity framework instead
local Menu
return{
	init	=	function()
					do
						local toboolean <const> = toboolean
						config = configFileRead("MenuGhost.ini") local config <const> = config
						if config.GhostAll == nil then
							config.GhostAll = false
						end
						config.GhostAll = toboolean(config.GhostAll)
						if config.GhostGod == nil then
							config.GhostGod = false
						end
						config.GhostGod = toboolean(config.GhostGod)
					end
					
					do
						local menu <const> = menu
						local menu_toggle <const> = menu.toggle
						
						do
							Menu = menu.list(menu.my_root(), "Ghosting/Passive", {}, "")
							local Menu <const> = Menu
							
							do
								local players_list <const> = players.list
								menu_toggle(Menu, "Ghost All", {}, "Automatically ghost all players?", function(state)
									local state <const> = state
									config.GhostAll = state
									
									local Players = players_list(false,true,true)
									for i=1, #Players do
										local Player <const> = Players[i]
										GhostState[Player] = state
										SetRelationshipToPlayer(Player, state)
									end
								end, config.GhostAll)
							end
							
							menu_toggle(Menu, "Ghost God", {}, "Automatically ghost invincible players?", function(state)
								config.GhostGod = state
							end, config.GhostGod)
						end
						
						do -- fix/remove this, add on_leave to modularity framework instead
							OnLeaveHandler = players.on_leave(function(PlayerId)
								GhostState[PlayerId], _GhostState[PlayerId], MenuPlayer[PlayerId] = false, false, nil
							end)
						end
					end
				end,
	join	=	Join,
	stop	=	function()
					config = configFileWrite("MenuGhost.ini", config) -- Writes settings to ini and sets config to nil
					
					OnLeaveHandler = OnLeaveHandler and util.remove_handler(OnLeaveHandler) or nil
					
					local SetRelationshipToPlayer <const> = SetRelationshipToPlayer
					
					local menu_delete <const> = menu.delete
					menu_delete(Menu)
					
					local type <const> = type
					for i=0,31 do
						local _MenuPlayer <const> = MenuPlayer[i]
						if type(_MenuPlayer)=='table' then
							menu_delete(_MenuPlayer[1]) menu_delete(_MenuPlayer[2]) MenuPlayer[i] = nil
						end
						if GhostState[i] then
							GhostState[i], _GhostState[i] = false, false
							SetRelationshipToPlayer(i, false)
						end
					end
				end,
}