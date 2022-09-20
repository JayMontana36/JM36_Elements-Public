local SharedIntPtr = memory.alloc_int()
JM36.CreateThread_HighPriority(function()
	local memory_write_int = memory.write_int
	local yield = JM36.yield
	while true do
		memory_write_int(SharedIntPtr, 0)
		yield()
	end
end)
return SharedIntPtr