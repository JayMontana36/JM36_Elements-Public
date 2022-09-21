--local getmetatable = getmetatable

local memory_alloc_int = memory.alloc_int
local memory_write_int = memory.write_int
local memory_read_int = memory.read_int

local DoesBlipExist = DoesBlipExist
local RemoveBlip = RemoveBlip

local MetaTableFunctionGC <const> = function(Self)
	if DoesBlipExist(memory_read_int(Self)) then
		RemoveBlip(Self)
	end
end
local MetaTable <const> =
{
	__gc = MetaTableFunctionGC
}

local setmetatable = setmetatable
local AllBlips <const> = setmetatable
(
	{},
	{
		__mode = "v",
		__call = function(Self, Blip)
			local _Blip = memory_alloc_int()
			memory_write_int(_Blip, Blip)
			--getmetatable(_Blip).__gc = MetaTableFunctionGC
			setmetatable(_Blip, MetaTable)
			Self[#Self+1] = _Blip
		end
	}
)

setmetatable = debug.setmetatable

return AllBlips