local DummyCmdTbl = _G2.DummyCmdTbl

local util_is_session_started = util.is_session_started
local util_is_session_transition_active = util.is_session_transition_active

local yield = JM36.yield

local PlayerScriptHostRefs = {[0]=false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false} -- 0-31

local Delay, Enabled = 20000, false

local Menu = menu.my_root():list("Script Host Rotation Options", DummyCmdTbl, "")
Menu:toggle("Enable Automatic Script Host Rotation", DummyCmdTbl, "", function(on)
	Enabled = on;if on then
		JM36.CreateThread(function()
			local PlayerId, PlayerScriptHostRef = -1, false
			while Enabled do
				if util_is_session_started() and not util_is_session_transition_active() then
					repeat
						PlayerId += 1
						PlayerScriptHostRef = PlayerScriptHostRefs[PlayerId]
					until PlayerScriptHostRef or PlayerId == 32
					if PlayerScriptHostRef then
						PlayerScriptHostRef:trigger()
						JM36.yield(Delay)
					else PlayerId = -1 end
				else
					yield()
				end
			end
			local PlayerScriptHostRef = PlayerScriptHostRefs[players.get_host()]
			if PlayerScriptHostRef then
				PlayerScriptHostRef:trigger()
			end
		end)
	end
end, Enabled)
Menu:slider("Set Automatic Script Host Rotation Delay", DummyCmdTbl, "", 15, 45, Delay/1000, 5, function(value)
	Delay = value * 1000
end)

return{
	join	=	function(PlayerId, PlayerRoot)
					PlayerScriptHostRefs[PlayerId] = PlayerRoot:refByRelPath"Friendly>Give Script Host"
				end,
	left	=	function(PlayerId, PlayerName)
					PlayerScriptHostRefs[PlayerId] = false
				end,
}
