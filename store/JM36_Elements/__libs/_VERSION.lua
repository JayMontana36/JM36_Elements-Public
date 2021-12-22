local config = configFileRead'Version.txt'
if config.Version ~= 1.0 then
	config.Version = 1.0
end
config = configFileWrite('Version.txt', config)
util.create_thread(function()
	util.yield(5)
	unrequire'_VERSION'
end)