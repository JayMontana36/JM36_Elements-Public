local booleans <const> = setmetatable
(
	{
		["false"]	=	false,
		["true"]	=	true,
		["0"]		=	false,
		["1"]		=	true,
		[0]			=	false,
		[1]			=	true,
	},
	{
		__index = true
	}
)

local type <const> = type
local toboolean <const> = function(p1)
	if p1 == nil then return false end
	local Type <const> = type(p1)
	if Type == 'boolean' then return p1 end
	return booleans[p1]
end
_G.toboolean, _G.tobool = toboolean, toboolean
return toboolean