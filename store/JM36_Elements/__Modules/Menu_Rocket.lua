local menu = menu
local Menu = menu.list(menu.my_root(), "Rocket Guidance", {}, "Rocket Related Options")
do
	local Enabled
	do
		local config = configFileRead("RocketGuidance.ini")
		Enabled = toboolean(config.Enabled)
	end
	local Info = Info
	Info.RocketGuidanceEnabled = Enabled
	menu.toggle(Menu, "Enable Rocket Guidance", {}, "Make rockets smarter | Increase rocket accuracy | Enable missile aimbot", function(state)
		configFileWrite("RocketGuidance.ini", {Enabled = state})
		Info.RocketGuidanceEnabled = state
	end, Enabled)
end
return Menu