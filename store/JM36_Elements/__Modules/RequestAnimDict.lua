local os_time <const> = os.time
local HasAnimDictLoaded <const> = HasAnimDictLoaded
local RequestAnimDict <const> = RequestAnimDict
local util_yield <const> = util.yield

return function(AnimDict, TimeOutTime)
	local CurrentTime = os_time()
    local TimeOutTime <const> = CurrentTime + (TimeOutTime or 5)
    local AnimDictLoaded = HasAnimDictLoaded(AnimDict)
    while not AnimDictLoaded and TimeOutTime > CurrentTime do
        RequestAnimDict(AnimDict)
		util_yield()
        CurrentTime = os_time()
		AnimDictLoaded = HasAnimDictLoaded(AnimDict)
    end
    return AnimDictLoaded
end