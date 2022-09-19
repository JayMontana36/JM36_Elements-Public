JM36.CreateThread(function()
	local Enabled = false
	
	menu.toggle(require'Menu_World', "Control Look At", {}, "Requests control of whatever you look at.", function(state)
		Enabled = state
		print('"World > Control Look At" is now:', Enabled)
	end, Enabled)
	
	local NetworkRequestControlOfEntity <const> = NetworkRequestControlOfEntity
	local TargetTable <const> = Info.Target
	local yield <const> = JM36.yield
	
	while true do
		if Enabled then
			local Target <const> = TargetTable.CollisionA and TargetTable.EntityHitA or TargetTable.CollisionB and TargetTable.EntityHitB
			if Target and Target ~= 0 then
				NetworkRequestControlOfEntity(Target)
			end
		end
		yield()
	end
end)