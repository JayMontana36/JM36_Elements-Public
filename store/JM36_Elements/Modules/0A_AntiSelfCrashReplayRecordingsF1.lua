local Ref_GamePoolsSizeMultiplier = menu.ref_by_path"Game>Early Inject Enhancements>Game Pools Size Multiplier"
if Ref_GamePoolsSizeMultiplier:isValid() and Ref_GamePoolsSizeMultiplier.value ~= Ref_GamePoolsSizeMultiplier:getDefaultState() then
	local DisableControlAction = DisableControlAction
	local IsControlPressed = IsControlPressed
	local IsDisabledControlPressed = IsDisabledControlPressed
	local DisableAllControlActions = DisableAllControlActions
	local EnableAllControlActions = EnableAllControlActions
	local yield = JM36.yield_once
	
	JM36.CreateThread_HighPriority(function()
		while true do
			--[[ INPUT_CHARACTER_WHEEL ]]
			DisableControlAction(0,19,true)
			DisableControlAction(2,19,true)
			DisableControlAction(13,19,true)
			
			--[[ INPUT_REPLAY_START_STOP_RECORDING ]]
			DisableControlAction(0,288,true)
			DisableControlAction(2,288,true)
			DisableControlAction(13,288,true)
			
			--[[ INPUT_REPLAY_START_STOP_RECORDING_SECONDARY ]]
			DisableControlAction(0,289,true)
			DisableControlAction(2,289,true)
			DisableControlAction(13,289,true)
			
			if IsControlPressed(0, 19) or IsDisabledControlPressed(0, 19) then
				DisableAllControlActions(2)
				EnableAllControlActions(0)
			end
			
			--[[ yield ]]
			yield()
		end
	end)
end