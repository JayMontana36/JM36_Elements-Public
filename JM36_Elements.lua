--[[ Config Area ]]
Natives              = "natives-1640181023"
Natives_FiveM        = true
Natives_FiveM_Only   = true
DebugMode            = false
Script_Home          = string.format("%s%s//", filesystem.store_dir(), SCRIPT_NAME)--filesystem.resources_dir()
Info_Update_Delay    = 0



--[[ Script/Code Area ]]
Script_Modules = Script_Home.."Modules//" -- Modular Script Components/Parts
__Script_Modules = Script_Home.."__Modules//" -- Shared Script Components/Resources
Script_Libs = Script_Home.."libs//" -- Standard libs Directory For Environment
__Script_Libs = Script_Home.."__libs//" -- Automatically Loaded libs On Startup

do
	local util_toast, table_concat, tostring
		= util.toast, table.concat, tostring
	print = function(...)
		local Content = {...}
		for i=1, #Content do
			Content[i] = tostring(Content[i])
		end
		util_toast(table_concat(Content, "	"), TOAST_ALL)
	end
end

local DirectoriesList = {"Script_Home","Script_Modules","__Script_Modules","Script_Libs","__Script_Libs"}
do
	local filesystem = filesystem
	local filesystem_mkdir = filesystem.mkdir
	local filesystem_exists = filesystem.exists
	local _G = _G
	for i=1,5 do
		local Directory = _G[DirectoriesList[i]]
		if not filesystem_exists(Directory) then
			filesystem_mkdir(Directory)
		end
	end
end



Info = { Enabled=false, Time=0, Player=0, Target=0 } local Info = Info
local Scripts_Init, Scripts_Join, Scripts_Loop, Scripts_Stop
do
	Scripts_Init = setmetatable({},{
		__call	=	function(Self)
						if Info.Enabled then Scripts_Stop() end
						
						local Scripts_List, Scripts_NMBR = {}, 0
						do
							local string_gsub, string_split, string_endsWith
								= string.gsub, string.split, string.endsWith
							local _Scripts_List = filesystem.list_files(Script_Modules)
							for i=1, #_Scripts_List do
								local Script = _Scripts_List[i]
								if string_endsWith(Script, ".lua") then
									Scripts_NMBR = Scripts_NMBR+1
									Scripts_List[Scripts_NMBR] = string_gsub(string_split(Script, "//")[3], ".lua", "")
								end
							end
						end
						
						table.sort(Scripts_List)
						Scripts_List.Num = Scripts_NMBR
						Self.List = Scripts_List
						
						do
							local Scripts_Loop, Scripts_Stop
								= Scripts_Loop, Scripts_Stop
							local print, type, pcall, require
								= print, type, pcall, require
							for i=1, Scripts_NMBR do
								local Successful, Script = pcall(require, Scripts_List[i])
								if Successful then
									if type(Script)=='table' then
										Self[#Self+1] = Script.init
										Scripts_Join[#Scripts_Join+1]=Script.join
										Scripts_Loop[#Scripts_Loop+1]=Script.loop
										Scripts_Stop[#Scripts_Stop+1]=Script.stop
									end
								else
									print(Script)
								end
							end
						end
						do
							local print, pcall = print, pcall
							for i=1, #Self do
								local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end
							end
						end
						
						players.dispatch_on_join()
						
						Info.Enabled = true
					end
	})
end
Scripts_Loop = {} -- Merge with tick using metatables?
Scripts_Join = {} -- Use metatable to make this also act as a function instead?
do
	Scripts_Stop = setmetatable({},{
		__call  =   function(Self)
						Info.Enabled = false
						
						do
							local Scripts_Init = Scripts_Init
							do
								local unrequire = unrequire
								local Scripts_List = Scripts_Init.List
								for i=1, Scripts_List.Num do
									unrequire(Scripts_List[i])
								end
							end
							
							for i=1, #Scripts_Init do
								Scripts_Init[i]=nil
							end
						end
						
						for i=1, #Scripts_Loop do
							Scripts_Loop[i]=nil
						end
						
						do
							local print, pcall = print, pcall
							for i=1, #Self do
								local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end Self[i]=nil
							end
						end
						
						collectgarbage()
					end
	})
end
_G.Scripts_Init, _G.Scripts_Stop = Scripts_Init, Scripts_Stop



local tick
do
	local GetTime
	do
		local os_clock = os.clock
		GetTime = function()
			return os_clock()*1000
		end
	end
	do
		local Info_Update_Delay = Info_Update_Delay
		local UpdateInfoTime = 0
		local Scripts_Loop = Scripts_Loop
		local Info = Info
		if DebugMode then
			local print, pcall = print, pcall
			tick = function()
				local Time = GetTime()
				Info.Time = Time
				if Time >= UpdateInfoTime then
					local Functions = Info.Functions
					for i=1, #Functions do
						Functions[i](Info)
					end
					UpdateInfoTime = Time + Info_Update_Delay
				end
				for i=1, #Scripts_Loop do
					--if not Info.Enabled and i~=1 then break end
					if not Info.Enabled then break end
					local Successful, Error = pcall(Scripts_Loop[i], Info) if not Successful then print(Error) end
				end
			end
		else
			tick = function()
				if Info.Enabled then
					local Time = GetTime()
					Info.Time = Time
					if Time >= UpdateInfoTime then
						local Functions = Info.Functions
						for i=1, #Functions do
							Functions[i](Info)
						end
						UpdateInfoTime = Time + Info_Update_Delay
					end
					for i=1, #Scripts_Loop do
						Scripts_Loop[i](Info)
					end
				end
			end
		end
	end
end

do
	--[[ Introduce some new useful string functions ]]
	do
		local string = string
		
		do
			local string_gmatch = string.gmatch
			string.split = function(inputstr,sep) -- Split strings into chunks or arguments (in tables)
				sep = sep or "%s" local t,n={},0
				for str in string_gmatch(inputstr, "([^"..sep.."]+)") do
					n=n+1 t[n]=str
				end
				return t
			end
		end
		
		string.upperFirst = function(s) -- Make the first letter of a string uppercase
			return s:sub(1,1):upper()..s:sub(2)
		end
		
		string.startsWith = function(str, start) -- Check if a string starts with something
			return str:sub(1, #start) == start
		end
		
		string.endsWith = function(str, ending) -- Check if a string ends with something
			return ending == "" or str:sub(-#ending) == ending
		end
	end
	
	--[[ Introduce/Create a new Secondary Global Environment Variable ]]
	local setmetatable = setmetatable
	local _G2
	do
		_G2 = {}
		setmetatable(_G,{__index=_G2})
	end
	
	--[[ Introduce some new useful core functions ]]
	do
		local package_loaded = package.loaded
		function _G2.unrequire(script) -- Very useful for script resets/reloads/cleanup
			package_loaded[script]=nil
		end
	end
	do
		local io_open, string_split, string_gsub, string_endsWith, string_startsWith, io_lines
			= io.open, string.split, string.gsub, string.endsWith, string.startsWith, io.lines
		function _G2.configFileRead(file, sep) -- Read simple config file
			file, sep = Script_Home..file, sep or "="
			local config, configFile = {}, io_open(file)
			if configFile then
				for line in io_lines(file) do
					if not (string_startsWith(line, "[") and string_endsWith(line, "]")) then
						line = string_gsub(line, "\n", "") line = string_gsub(line, "\r", "")
						if line ~= "" then
							line = string_split(line, sep)
							config[line[1]] = line[2]
						end
					end
				end
				configFile:close()
			end
			return config
		end
	end
	do
		local io_open, string_format, tostring, pairs
			= io.open, string.format, tostring, pairs
		function _G2.configFileWrite(file, config, sep) -- Write simple config file
			local configFile, sep = io_open(Script_Home..file, "w"), sep or "="
			for k,v in pairs(config) do
				configFile:write(string_format("%s%s%s\n", k, sep, tostring(v)))
			end
		end
	end
	
	--[[ Update the search path ]]
	do
		local package_path = package.path
		local string_format = string.format
		local _G = _G
		local DirectoriesList = DirectoriesList
		for i=1,5 do
			local Directory = _G[DirectoriesList[i]]
			package_path = string_format(".\\?.dll;%s?.dll;%slibs\\?.dll;%slibs\\?\\init.dll;%s", Directory, Directory, Directory, package_path) -- DLL
			package_path = string_format(".\\?.lua;%s?.lua;%slibs\\?.lua;%slibs\\?\\init.lua;%s", Directory, Directory, Directory, package_path) -- Lua
			package_path = string_format(".\\?;%s?;%slibs\\?;%slibs\\?\\init;%s", Directory, Directory, Directory, package_path) -- NoExtension
		end
		package.path = package_path
	end
	
	require(Natives) --[[ Load RAGE Native Function Wrapper Library ]]
	
	--[[ Introduce/Create FiveM style game native function calls ]]
    if Natives_FiveM then
        local Namespaces    = {
            SYSTEM          = true,
            APP             = true,
            AUDIO           = true,
            BRAIN           = true,
            CAM             = true,
            CLOCK           = true,
            CUTSCENE        = true,
            DATAFILE        = true,
            DECORATOR       = true,
            DLC             = true,
            ENTITY          = true,
            EVENT           = true,
            FILES           = true,
            FIRE            = true,
            GRAPHICS        = true,
            HUD             = true,
            INTERIOR        = true,
            ITEMSET         = true,
            LOADINGSCREEN   = true,
            LOCALIZATION    = true,
            MISC            = true,
            MOBILE          = true,
            MONEY           = true,
            NETSHOPPING     = true,
            NETWORK         = true,
            OBJECT          = true,
            PAD             = true,
            PATHFIND        = true,
            PED             = true,
            PHYSICS         = true,
            PLAYER          = true,
            RECORDING       = true,
            REPLAY          = true,
            SCRIPT          = true,
            SHAPETEST       = true,
            SOCIALCLUB      = true,
            STATS           = true,
            STREAMING       = true,
            TASK            = true,
            VEHICLE         = true,
            WATER           = true,
            WEAPON          = true,
            ZONE            = true,
        }
        
        local table_concat, string_upperFirst, string_lower, string_split, string_startsWith, _G, pairs
            = table.concat, string.upperFirst, string.lower, string.split, string.startsWith, _G, pairs
        for k,v in pairs(_G) do
            if Namespaces[k] then
                for k,v in pairs(_G[k]) do
                    if string_startsWith(k, "_0x") then
                        _G2[k] = v
                    else
                        k = string_split(k, "_")
                        for i=1, #k do
                            k[i] = string_upperFirst(string_lower(k[i]))
                        end
                        _G2[table_concat(k)] = v
                    end
                end
                if Natives_FiveM_Only then
                    _G[k] = nil
                end
            end
        end
        
        if Natives_FiveM_Only then
            unrequire(Natives)
        end
        
        Namespaces = nil
        _G2.Wait = util.yield
    end
	
	--[[ Automatically load __Internal ]]
	do
		local Info = Info
		
		local Functions = setmetatable({},{
			__call  =   function(Self)
							local Info = Info
							for i=1, #Self do
								Self[i](Info)
							end
						end
		})
		Info.Functions = Functions
		
		local package = package
		local package_path_orig = package.path
		
		local Directory = Script_Home.."__Internal//"
		
		package.path = string.format("%s?.lua", Directory)
		
		local List, ListNum = {}, 0
		do
			local string_endsWith, string_split, string_gsub
                = string.endsWith, string.split, string.gsub
			local _List = filesystem.list_files(Directory)
			for i=1, #_List do
				local Lib = _List[i]
				if string_endsWith(Lib, ".lua") then
					ListNum = ListNum+1
					List[ListNum] = string_gsub(string_split(Lib, "//")[3], ".lua", "")
				end
			end
		end
		table.sort(List)
		do
			local pcall, require, type, print
				= pcall, require, type, print
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
		end
		
		package.path = package_path_orig
	end
	
	--[[ Automatically load __libs ]]
	do
		local __libs_List, __libs_NMBR = {}, 0
		do
			local string_gsub, string_split, string_endsWith
				= string.gsub, string.split, string.endsWith
			local ___libs_List = filesystem.list_files(__Script_Libs)
			for i=1, #___libs_List do
				local __lib = ___libs_List[i]
				if string_endsWith(__lib, ".lua") then
					__libs_NMBR = __libs_NMBR+1
					__libs_List[__libs_NMBR] = string_gsub(string_split(__lib, "//")[3], ".lua", "")
				end
			end
		end
		
		table.sort(__libs_List)
		
		do
			local print, pcall, require
				= print, pcall, require
			for i=1, __libs_NMBR do
				local Successful, __lib = pcall(require, __libs_List[i])
				if not Successful then
					print(__lib)
				end
			end
		end
    end
    
    --[[ Add Reload Option With Debug Mode ]]
    if DebugMode then
        local Scripts_Init = function()Scripts_Init()end -- Required as Stand errors and complains otherwise - function tables unsupported.
        local menu = menu
        menu.action(menu.my_root(), "Reload Modules", {"elements reload", "reload elements", "reload modules"}, "", Scripts_Init)
    end
end

local init
do
	local Scripts_Init, collectgarbage
		= Scripts_Init, collectgarbage
	init = function()
		collectgarbage()
		Scripts_Init()
	end
end

--if SCRIPT_MANUAL_START then
--    util.execute_in_os_thread(init)
--else
    init()
--end
--[[init()]]--[[util.execute_in_os_thread(init)]]

do
	local Scripts_Join = Scripts_Join
	players.on_join(function(PlayerId)
		for i=1, #Scripts_Join do
			Scripts_Join[i](PlayerId)
		end
	end)
end

util.on_stop(Scripts_Stop)

do
	local tick = tick
	util.create_tick_handler(function()
		tick()
	return true end)
end