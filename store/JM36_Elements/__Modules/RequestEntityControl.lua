local os_time <const> = os.time
local DoesEntityExist <const> = DoesEntityExist
local NetworkRequestControlOfEntity <const> = NetworkRequestControlOfEntity
local util_yield <const> = util.yield

return function(EntityHandle, TimeOutTime)
    local CurrentTime = os_time()
    local TimeOutTime <const> = CurrentTime + (TimeOutTime or 5)
    local EntityExists = DoesEntityExist(EntityHandle)
    local HasControlOfEntity = NetworkRequestControlOfEntity(EntityHandle)
    while EntityExists and not HasControlOfEntity and TimeOutTime > CurrentTime do
        util_yield()
        CurrentTime = os_time()
		EntityExists = DoesEntityExist(EntityHandle) if not EntityExists then break end
        HasControlOfEntity = NetworkRequestControlOfEntity(EntityHandle)
    end
    return EntityExists and HasControlOfEntity
end