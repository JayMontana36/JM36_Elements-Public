local Info <const> = Info
local RequestEntityModel <const> = require'RequestEntityModel'
local RequestAnimDict <const> = require'RequestAnimDict'
local util_yield <const> = util.yield
local IsEntityDead <const> = IsEntityDead
local util_create_thread <const> = util.create_thread
local CreateObject <const> = CreateObject
local AttachEntityToEntity <const> = AttachEntityToEntity
local GetPedBoneIndex <const> = GetPedBoneIndex
local ClearPedTasks <const> = ClearPedTasks
local SetCurrentPedWeapon <const> = SetCurrentPedWeapon
local TaskTurnPedToFaceEntity <const> = TaskTurnPedToFaceEntity
local TaskPlayAnim <const> = TaskPlayAnim
local HasEntityAnimFinished <const> = HasEntityAnimFinished
local RemoveAnimDict <const> = RemoveAnimDict
local DetachEntity <const> = DetachEntity
local memory_write_int <const> = memory.write_int
local DeleteObject <const> = DeleteObject
local DoesEntityExist <const> = DoesEntityExist
local PlaySoundFromEntity <const> = PlaySoundFromEntity

local Weapon <const> = GetHashKey("WEAPON_UNARMED")
local KeyFobHash <const> = GetHashKey("p_car_keys_01")
local KeyFobAnimDict <const> = "anim@mp_player_intmenu@key_fob@"--[[memory.alloc() memory.write_string(KeyFobAnimDict, "anim@mp_player_intmenu@key_fob@")]]
local KeyFobAnimName <const> = "fob_click"--[[memory.alloc() memory.write_string(KeyFobAnimName, "fob_click")]]
--local KeyFobAudioName = "Remote_Control_Fob"
--local KeyFobAudioName <const> = memory.alloc() memory.write_string(KeyFobAudioName, "Remote_Control_Fob")
local KeyFobAudioName = "Remote_Control_Fob"
--local KeyFobAudioRef = "PI_Menu_Sounds"
--local KeyFobAudioRef <const> = memory.alloc() memory.write_string(KeyFobAudioRef, "PI_Menu_Sounds")
local KeyFobAudioRef = "PI_Menu_Sounds"
local _KeyFobObject <const> = memory.alloc()

return function(Vehicle_Id, SkipAnims)
	local Player <const> = Info.Player
	local Player_Ped <const> = Player.Ped
	local Vehicle <const> = Player.Vehicle
	local Vehicle_Id <const> = Vehicle_Id or Vehicle.Id
	local KeyFobObject = 0
	local AudioSource = 0
	if not IsEntityDead(Player_Ped, false) and not Vehicle.IsIn then
		util_create_thread(function()
			if not SkipAnims and RequestEntityModel(KeyFobHash) then
				KeyFobObject = CreateObject(KeyFobHash, 0.0, 0.0, 0.0, true, true, true)
				AttachEntityToEntity(KeyFobObject, Player_Ped, GetPedBoneIndex(Player_Ped, 57005), 0.09, 0.03, -0.02, -76, 13, 28, false, true, true, true, 0, true)
				
				ClearPedTasks(Player_Ped)
				SetCurrentPedWeapon(Player_Ped, Weapon, true)
				
				TaskTurnPedToFaceEntity(Player_Ped, (Vehicle_Id), 1000)
				
				if RequestAnimDict(KeyFobAnimDict) then
					TaskPlayAnim(Player_Ped, KeyFobAnimDict, "fob_click_fp", 8.0, 8.0, -1, 48, 1.0, false, false, false)
					--[[
					local Finished = HasEntityAnimFinished(Player_Ped, KeyFobAnimDict, KeyFobAnimName, 3)
					while not Finished do
						util_yield()
						Finished = HasEntityAnimFinished(Player_Ped, KeyFobAnimDict, KeyFobAnimName, 3)
						print(Finished)
					end
					]]
					RemoveAnimDict(KeyFobAnimDict)
				end
				
				util_yield(1000)
				
				DetachEntity(KeyFobObject, false, false)
				memory_write_int(_KeyFobObject, KeyFobObject)
				DeleteObject(_KeyFobObject)
				KeyFobObject = 0
			end
		end)
	end
	if not SkipAnims then
		util_yield(250)
	end
	AudioSource = KeyFobObject
	if not DoesEntityExist(AudioSource) then
		AudioSource = Player_Ped
	end
	PlaySoundFromEntity(-1, KeyFobAudioName, AudioSource, KeyFobAudioRef, true, 0)
end