local os_time <const> = os.time
local IsModelValid <const> = require('CreateCacheSimpleForFunction')(IsModelValid)
local HasModelLoaded <const> = HasModelLoaded
local RequestModel <const> = RequestModel
local util_yield <const> = util.yield
local util_create_thread <const> = util.create_thread
local SetModelAsNoLongerNeeded <const> = SetModelAsNoLongerNeeded

return function(EntityHash, TimeOutTime)
    --local _TimeOutTime = (TimeOutTime or 5)
    local _TimeOutTime <const> = (TimeOutTime or 500)
	local CurrentTime = os_time()
    local TimeOutTime <const> = CurrentTime + _TimeOutTime
    local ModelExists <const> = IsModelValid(EntityHash)
    local ModelLoaded = HasModelLoaded(EntityHash)
    while ModelExists and not ModelLoaded and TimeOutTime > CurrentTime do
        RequestModel(EntityHash)
		util_yield()
        CurrentTime = os_time()
		ModelLoaded = HasModelLoaded(EntityHash)
    end
	if ModelExists then
		util_create_thread(function()
			util_yield(_TimeOutTime--[[*1000]])
			SetModelAsNoLongerNeeded(EntityHash)
		end)
	--else
		--local _error = "Model Doesn't Exist?" error(_error)print(_error)
	end
    return ModelLoaded and ModelExists
end