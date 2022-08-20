JM36.CreateThread(function()
	local IsControlJustPressed <const> = IsControlJustPressed
	local IsPedRunning <const> = IsPedRunning
	local SetPedUsingActionMode <const> = SetPedUsingActionMode
	local SetPedStealthMovement <const> = SetPedStealthMovement
	local Player <const> = Info.Player
	local Vehicle <const> = Player.Vehicle
	local yield <const> = JM36.yield
	local StealthMode
	while true do
		if not Vehicle.IsIn then
			if IsControlJustPressed(0,28) then
				StealthMode = not StealthMode
			end
			local Player_Ped <const> = Player.Ped
			if not StealthMode or IsPedRunning(Player_Ped) then
				SetPedUsingActionMode(Player_Ped, false, -1, 0 or "DEFAULT_ACTION") -- no stupid jank walk
			else
				SetPedStealthMovement(Player_Ped, true, 0 or "DEFAULT_ACTION")
			end
		else
			StealthMode = false
		end
		yield()
	end
end)