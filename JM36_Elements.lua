-- Config Area
DebugMode	= false
Script_Home	= "%s%s//":format(filesystem.store_dir(), SCRIPT_NAME)--filesystem.resources_dir()



-- Script/Code Area
--



Scripts_Path = Script_Home
--[[ Localize all "frequently" used things ]]
local _G = _G
local Scripts_Path = Script_Home
local setmetatable = setmetatable
local pairs = pairs
local coroutine = coroutine
local coroutine_yield = coroutine.yield
local coroutine_create = coroutine.create
local coroutine_wrap = coroutine.wrap
local coroutine_resume = coroutine.resume
local coroutine_status = coroutine.status
local table = table
local table_insert = table.insert
local table_sort = table.sort
local io = io
local io_open = io.open
local io_lines = io.lines
local print = print
local type = type
local pcall = pcall
local require = require
local collectgarbage = collectgarbage



--[[ Create secondary "global" table for storing tables containing "global" functions, such as natives. ]]
do
	local _G2 = setmetatable
	(
		{},
		{
			__index = function(Self,Key)
				for k,v in pairs(Self) do
					local ReturnValue = type(v)=='table' and v[Key]
					if ReturnValue then return ReturnValue end
				end
			end
		}
	)
	_G._G2 = _G2
	setmetatable
	(
		_G,
		{
			__index = function(Self,Key)
				return _G2[Key]
			end
		}
	)
end


--[[ Add string functions ]]
do
	local string = string
	--string.split
	
	string.upperFirst = function(string) -- Make the first letter of a string uppercase
		return string[1]:upper()..string:sub(2)
	end
	
	string.startsWith = string.startswith
	string.endsWith = string.endswith
end



--[[ Add useful core/framework functions ]]
local unrequire
do
	local package_loaded = package.loaded
	function unrequire(script) -- Very useful for script resets/reloads/cleanup
		package_loaded[script]=nil
	end
end
_G.unrequire = unrequire
do
	function configFileRead(file,sep) -- Read simple config file
		file = Scripts_Path..file;sep = sep or "="
		local configFile = io_open(file);local config = {}
		if configFile then
			for line in io_lines(file) do
				if not (line:startsWith("[") and line:endsWith("]")) then
					line = line:gsub("\n","");line = line:gsub("\r","")
					if line ~= "" then
						line = line:split(sep)
						config[line[1]] = line[2]
					end
				end
			end
			configFile:close()
		end
		return config
	end
	
	do
		local tostring = tostring
		function configFileWrite(configFile, config, sep) -- Write simple config file
			local configFile, sep = io_open(Scripts_Path..configFile, "w"), sep or "="
			for k,v in pairs(config) do
				configFile:write(("%s%s%s\n"):format(k, sep, tostring(v)))
			end
		end
	end
end



-- Set up framework
--[[ Fix Scripts_Path string variable if missing the trailing "//" on the end ]]
if not Scripts_Path:endsWith("//") then
	Scripts_Path = Scripts_Path.."//"
	_G.Scripts_Path = Scripts_Path
end

--[[ Define other additional Script Paths ]]
local Script_Modules = Scripts_Path.."Modules//" _G.Script_Modules = Script_Modules -- Modular Script Components/Parts
local __Script_Modules = Scripts_Path.."__Modules//" _G.__Script_Modules = __Script_Modules -- Shared Script Components/Resources
local Script_Libs = Scripts_Path.."libs//" _G.Script_Libs = Script_Libs -- Standard libs Directory For Environment
local __Script_Libs = Scripts_Path.."__libs//" _G.__Script_Libs = __Script_Libs -- Automatically Loaded libs On Startup
local __Internal_Path = Scripts_Path.."__Internal//" _G.__Internal_Path = __Internal_Path



do
	local util_toast, TOAST_ALL, table_concat, tostring = util.toast, TOAST_ALL, table.concat, tostring
	print = function(...)
		local Content = {...}
		for i=1, #Content do
			Content[i] = tostring(Content[i])
		end
		util_toast(table_concat(Content, "	"), TOAST_ALL)
	end
	_G.print = print
end
do
	local _require = require
	require = function(file)
		local ReturnValue
	--	util.execute_in_os_thread(function()
			ReturnValue = _require(file)
	--	end)
		return ReturnValue
	end
	_G.require = require
end



--[[ Update the search path ]]
do
	local package_path = package.path
	local DirectoriesList = {"Scripts_Path","Script_Modules","__Script_Modules","Script_Libs","__Script_Libs"}
	local FiletypesList = {".dll",".luac","",".lua"}
	
	local filesystem = filesystem
	local filesystem_mkdir = filesystem.mkdir
	local filesystem_exists = filesystem.exists
	
	for i=1,5 do
		local Directory = _G[DirectoriesList[i]]
		if not filesystem_exists(Directory) then
			filesystem_mkdir(Directory)
		end
		for j=1,4 do
			local Filetype = FiletypesList[j]
			package_path = (".\\?%s;%s?%s;%slibs\\?%s;%slibs\\?\\init%s;%s"):format(Filetype,Directory,Filetype,Directory,Filetype,Directory,Filetype,package_path)
			--Type,Directory,Type,Directory,Type,Directory,Type,ConcatOnTo
		end
	end
	package.path = package_path
end

local Threads_HighPriority = {}
local Threads_New = {}
local Threads = {}

local Info = {Enabled=false,Time=0,Player=0}
_G.Info = Info

local JM36 =
{
	CreateThread_HighPriority = function(func)
			table_insert(Threads_HighPriority, coroutine_create(func))
		end,
	CreateThread = function(func)
			table_insert(Threads_New, coroutine_create(func))
		end,
	Wait=0,
	wait=0,
	yield=0
}
do
	local Halt = function(ms)
		local TimeResume = Info.Time+(ms or 0)
		repeat
			coroutine_yield()
		until Info.Time > TimeResume
	end
	JM36.Wait, JM36.wait, JM36.yield = Halt, Halt, Halt
	JM36.CreateThread_HighPriority(function() wait=JM36.wait;IsKeyPressed=get_key_pressed end)
end
_G.JM36 = JM36

local Scripts_Init, Scripts_Join, Scripts_Left, Scripts_Stop
do
	local loopToThread
	do
		local CreateThread = JM36.CreateThread
		local yield = JM36.yield
		loopToThread = function(func)
			CreateThread(function()
				while true do
					func(Info)
					yield()
				end
			end)
		end
	end
	local _Scripts_Init = function(Self)
		if Info.Enabled then Scripts_Stop() end
		
		local Scripts_List, Scripts_NMBR = {}, 0
		for i, Script in filesystem.list_files(Script_Modules) do
			if Script:endsWith(".lua") then
				Scripts_NMBR = Scripts_NMBR+1
				Scripts_List[Scripts_NMBR] = Script:split("//")[3]:gsub(".lua","")
			elseif Script:endsWith(".luac") then
				Scripts_NMBR = Scripts_NMBR+1
				Scripts_List[Scripts_NMBR] = Script:split("//")[3]:gsub(".luac","")
			end
		end
		
		table_sort(Scripts_List)
		Scripts_List.Num = Scripts_NMBR
		Self.List = Scripts_List
		
		for i=1, Scripts_NMBR do
			local Successful, Script = pcall(require, Scripts_List[i])
			if Successful then
				if type(Script)=='table' then
					Self[#Self+1] = Script.init
					
					Scripts_Join[#Scripts_Join+1]=Script.join
					Scripts_Left[#Scripts_Left+1]=Script.left
					
					Scripts_Stop[#Scripts_Stop+1] = (Script.stop or Script.unload)
					
					local loop = (Script.loop or Script.tick)
					if loop then
						loopToThread(loop)
					end
				end
			else
				print(Script)
			end
		end
		
		JM36.CreateThread_HighPriority(function()
			for i=1, #Self do
				local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end
			end
			players.dispatch_on_join()
		end)
		
		Info.Enabled = true
	end
	Scripts_Init = setmetatable({},{
		__call	=	function(Self)
						util.spoof_script("main_persistent",function()
							_Scripts_Init(Self)
						end)
					end
	})
end
Scripts_Join = {} -- Use metatable to make this also act as a function instead?
Scripts_Left = {} -- Use metatable to make this also act as a function instead?
do
	local _Scripts_Stop = function(Self)
		Info.Enabled = false
		
		local Scripts_List = Scripts_Init.List
		for i=1, Scripts_List.Num do
			unrequire(Scripts_List[i])
		end
		
		for i=1, #Scripts_Init do
			Scripts_Init[i]=nil
		end
		
		for i=1, #Scripts_Join do
			Scripts_Join[i]=nil
		end
		
		for i=1, #Scripts_Left do
			Scripts_Left[i]=nil
		end
		
		for i=1, #Threads do
			Threads[i]=nil
		end
		for i=1, #Threads_New do
			Threads_New[i]=nil
		end
		
		for i=1, #Self do
			local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end Self[i]=nil
		end
		
		collectgarbage()
	end
	Scripts_Stop = setmetatable({},{
		__call  =   function(Self)
						util.spoof_script("main_persistent",function()
							_Scripts_Stop(Self)
						end)
					end
	})
end
_G.Scripts_Init, _G.Scripts_Stop = Scripts_Init, Scripts_Stop



-- Automatically load __Internal
do
	local Functions = setmetatable({},{
		__call  =   function(Self)
						for i=1, #Self do
							Self[i](Info)
						end
					end
	})
	Info.Functions = Functions
	
	local package = package
	local package_path_orig = package.path
	
	package.path = ("%s?.lua;%s?.luac"):format(__Internal_Path,__Internal_Path)
	
	local List, ListNum = {}, 0
	for i, Lib in filesystem.list_files(__Internal_Path) do
		if Lib:endsWith(".lua") then
			ListNum = ListNum+1
			List[ListNum] = Lib:split("//")[3]:gsub(".lua","")
		elseif Lib:endsWith(".luac") then
			ListNum = ListNum+1
			List[ListNum] = Lib:split("//")[3]:gsub(".luac","")
		end
	end
	table_sort(List)
	local FunctionsNum = 0
	for i=1, ListNum do
		local Successful, Function = pcall(require, List[i])
		if Successful then
			local Type = type(Function)
			if Type == "table" then
				if not Function.InfoKeyOnly then
					FunctionsNum = FunctionsNum + 1
					Functions[FunctionsNum] = Function
				end
				local Key = Function.InfoKeyName
				if type(Key) == "string" then
					Info[Key] = Function
				end
			elseif Type == "function" then
				FunctionsNum = FunctionsNum + 1
				Functions[FunctionsNum] = Function
			end
		else
			print(Function)
		end
	end
	
	package.path = package_path_orig
end

-- Automatically load __libs
do
	local __libs_List, __libs_NMBR = {}, 0
	for i, __lib in filesystem.list_files(__Script_Libs) do
		if __lib:endsWith(".lua") then
			__libs_NMBR = __libs_NMBR+1
			__libs_List[__libs_NMBR] = __lib:split("//")[3]:gsub(".lua","")
		elseif __lib:endsWith(".luac") then
			__libs_NMBR = __libs_NMBR+1
			__libs_List[__libs_NMBR] = __lib:split("//")[3]:gsub(".luac","")
		end
	end
	
	table_sort(__libs_List)
	
	for i=1, __libs_NMBR do
		local Successful, __lib = pcall(require, __libs_List[i])
		if not Successful then
			print(__lib)
		end
	end
end



-- Add Reload Option With Debug Mode
if DebugMode then
	local _Scripts_Init <const> = function()Scripts_Init()end -- Required as Stand errors and complains otherwise - function tables unsupported.
	menu.action(menu.my_root(), "Reload Modules", {"elements reload", "reload elements", "reload modules"}, "", _Scripts_Init)
end



-- Add player triggers
players.on_join(function(PlayerId)
	for i=1, #Scripts_Join do
		Scripts_Join[i](PlayerId)
	end
end)
players.on_leave(function(PlayerId, PlayerName)
	for i=1, #Scripts_Left do
		Scripts_Left[i](PlayerId, PlayerName)
	end
end)



-- init
collectgarbage()
Scripts_Init()



-- tick handler function
local tick = coroutine_wrap(function()
	local GetTime = coroutine_wrap(function()
		local os_clock = os.clock
		while true do
			coroutine_yield(os_clock()*1000)
		end
	end)
	
	local Functions = Info.Functions
	
	while true do
		Info.Time = GetTime()
		if Info.Enabled then
			for i=1, #Functions do
				Functions[i](Info)
			end
			do
				local j = 1
				for i = 1, #Threads_HighPriority do
					local Thread = Threads_HighPriority[i]
					if coroutine_status(Thread)~="dead" then
						do
							local Successful, Error = coroutine_resume(Thread)
							if not Successful then print(Error) end
						end
						if i ~= j then
							Threads_HighPriority[j] = Threads_HighPriority[i]
							Threads_HighPriority[i] = nil
						end
						j = j + 1
					else
						Threads_HighPriority[i] = nil
					end
				end
			end
			local ThreadsNum = #Threads
			for i=1, #Threads_New do
				ThreadsNum = ThreadsNum + 1
				Threads[ThreadsNum] = Threads_New[i]
				Threads_New[i] = nil
			end
			local j = 1
			for i = 1, ThreadsNum do
				local Thread = Threads[i]
				if coroutine_status(Thread)~="dead" then
					do
						local Successful, Error = coroutine_resume(Thread)
						if not Successful then print(Error) end
					end
					if i ~= j then
						Threads[j] = Threads[i]
						Threads[i] = nil
					end
					j = j + 1
				else
					Threads[i] = nil
				end
			end
		end
		coroutine_yield(true)
	end
end)util.create_tick_handler(tick)

util.on_stop(Scripts_Stop)