local MenuOption, Wings

local RemoveWings = function()
	if Wings and Wings ~= 0 then
		entities.delete_by_handle(Wings)
	end
end

return{
	init	=	function()
					local menu = menu
					local WingsHash, DummyV3 = GetHashKey"vw_prop_art_wings_01a", {x=0,y=0,z=0}
					local RequestEntityModel = require'RequestEntityModel'
					local Player = Info.Player
					MenuOption = menu.toggle(menu.my_root(), "Wings On Back", {}, "Puts wings on your back.", function(state)
						if state and RequestEntityModel(WingsHash) then
							Wings = entities.create_object(WingsHash, DummyV3)
							if Wings ~= 0 then
								local Player_Ped = Player.Ped
								AttachEntityToEntity(Wings, Player_Ped, GetPedBoneIndex(Player_Ped, 23553), -1.0, 0.0, 0.0, 0.0, 90.0, 0.0, false, true, false, true, 0, true)
							end
							return
						end
						RemoveWings()
					end, false)
				end,
	stop	=	function()
					RemoveWings()
					menu.delete(MenuOption)
				end,
}
