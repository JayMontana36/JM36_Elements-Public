local Info = Info
local yield = JM36.yield_once

local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local IsModelValid = IsModelValid
local HasModelLoaded = HasModelLoaded
local RequestModel = RequestModel

local ModelAutoUnloadTimeout = setmetatable({},{__index=function()return 0 end})
JM36.CreateThread_HighPriority(function()
	while true do
		for EntityHash, TimeUnload in ModelAutoUnloadTimeout do
			if Info.Time > TimeUnload then
				SetModelAsNoLongerNeeded(EntityHash)
				ModelAutoUnloadTimeout[EntityHash] = nil
			end
		end
		yield()
	end
end)

return function(EntityHash, TimeBail, TimeUnload)
	if IsModelValid(EntityHash) then
		local _TimeUnload = ModelAutoUnloadTimeout[EntityHash]
		local ModelLoaded = HasModelLoaded(EntityHash)
		if not ModelLoaded then
			TimeBail = Info.Time + (TimeBail or 500)
			RequestModel(EntityHash)
			repeat
				yield()
				ModelLoaded = HasModelLoaded(EntityHash)
			until ModelLoaded or Info.Time > TimeBail
		end
		if ModelLoaded then
			TimeUnload = Info.Time + (TimeUnload or 500)
			if _TimeUnload < TimeUnload then
				ModelAutoUnloadTimeout[EntityHash] = TimeUnload
			end
			return true
		end
	end
end
