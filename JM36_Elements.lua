--[[ Config Area ]]
Natives              = "natives-1627063482"
Natives_FiveM        = true
Natives_FiveM_Only   = true
DebugMode            = false
Script_Home          = string.format("%s%s//", filesystem.store_dir(), SCRIPT_NAME)--filesystem.resources_dir()
Info_Update_Delay    = 500



--[[ Script/Code Area ]]
Script_Modules = Script_Home.."Modules//" -- Modular Script Components/Parts
__Script_Modules = Script_Home.."__Modules//" -- Shared Script Components/Resources
Script_Libs = Script_Home.."libs//" -- Standard libs Directory For Environment
__Script_Libs = Script_Home.."__libs//" -- Automatically Loaded libs On Startup

local tostring, table_concat, util_toast
    = tostring, table.concat, util.toast
print = function(...)
    local Content = {...}
    for i=1, #Content do
        Content[i] = tostring(Content[i])
    end
    util_toast(table_concat(Content, "	"), TOAST_ALL)
end

local DirectoriesList = {"Script_Home","Script_Modules","__Script_Modules","Script_Libs","__Script_Libs"}
local filesystem = filesystem
for i=1,5 do
    local Directory = _G[DirectoriesList[i]]
    if not filesystem.exists(Directory) then
        filesystem.mkdir(Directory)
    end
end



local Info = { Enabled=false, Time=0, Player=0 } _G.Info = Info
local setmetatable, table_sort, pcall, require, print, collectgarbage
    = setmetatable, table.sort, pcall, require, print, collectgarbage
local Scripts_Init, Scripts_Loop, Scripts_Stop
Scripts_Init = setmetatable({},{
    __call  =   function()
                    if Info.Enabled then
                        Scripts_Stop()
                    end
                    
                    local string_endsWith, string_split, string_gsub
                        = string.endsWith, string.split, string.gsub
                    local Scripts_List, Scripts_NMBR = {}, 0
                    local _Scripts_List = filesystem.list_files(Script_Modules)
                    for i=1, #_Scripts_List do
                        local Script = _Scripts_List[i]
                        if string_endsWith(Script, ".lua") then
                            Scripts_NMBR = Scripts_NMBR+1
                            Scripts_List[Scripts_NMBR] = string_gsub(string_split(Script, "//")[3], ".lua", "")
                        end
                    end
                    table_sort(Scripts_List)
                    
                    local pcall, require, type
                        = pcall, require, type
                    local Successful, Script
                    for i=1, Scripts_NMBR do
                        Successful, Script = pcall(require, Scripts_List[i])
                        if Successful then
                            if type(Script)=="table" then
                                Scripts_Stop[#Scripts_Stop+1]=Script.stop
                                Scripts_Init[#Scripts_Init+1]=Script.init
                                Scripts_Loop[#Scripts_Loop+1]=Script.loop
                            end
                        else
                            print(Script)
                        end
                    end
                    for i=1, #Scripts_Init do
                        Successful, Script = pcall(Scripts_Init[i], Info) if not Successful then print(Script) end
                    end
                    Info.Enabled = true
                end
})
Scripts_Loop = {}
Scripts_Stop = setmetatable({},{
    __call  =   function()
                    Info.Enabled = false
                    
                    local string_endsWith, string_gsub, string_split, unrequire
                        = string.endsWith, string.gsub, string.split, unrequire
                    
                    local _Scripts_List = filesystem.list_files(Script_Modules)
                    for i=1, #_Scripts_List do
                        local Script = _Scripts_List[i]
                        if string_endsWith(Script, ".lua") then
                            unrequire(string_gsub(string_split(Script, "//")[3], ".lua", ""))
                        end
                    end
                    
                    for i=1, #Scripts_Init do
                        Scripts_Init[i]=nil
                    end
                    for i=1, #Scripts_Loop do
                        Scripts_Loop[i]=nil
                    end
                    local Successful, Error
                    for i=1, #Scripts_Stop do
                        Successful, Error = pcall(Scripts_Stop[i], Info) if not Successful then print(Error) end Scripts_Stop[i]=nil
                    end
                    
                    collectgarbage()
                end
})
_G.Scripts_Init, _G.Scripts_Stop = Scripts_Init, Scripts_Stop



local os_clock = os.clock
local GetTime = function()
    return os_clock()*1000
end

local UpdateInfoTime = 0
local tick
if DebugMode then
    tick = function()
        local Time = GetTime()
        local Info = Info
        Info.Time = Time
        if Time >= UpdateInfoTime then
            Info.Player()
            Time = GetTime()
            Info.Time = Time
            UpdateInfoTime = Time + Info_Update_Delay
        end
        local Successful, Error
        local Scripts_Loop = Scripts_Loop
        for i=1, #Scripts_Loop do
            if not Info.Enabled and i>1 then break end
            Successful, Error = pcall(Scripts_Loop[i], Info) if not Successful then print(Error) end
        end
    end
else
    tick = function()
        local Info = Info
        if Info.Enabled then
            local Time = GetTime()
            Info.Time = Time
            if Time >= UpdateInfoTime then
                Info.Player()
                Time = GetTime()
                Info.Time = Time
                UpdateInfoTime = Time + Info_Update_Delay
            end
            local Scripts_Loop = Scripts_Loop
            for i=1, #Scripts_Loop do
                Scripts_Loop[i](Info)
            end
        end
    end
end
local function _init()
    local setmetatable = setmetatable
    --[[ Introduce/Create a new Secondary Global Environment Variable ]]
    local _G2 _G2 = {} setmetatable(_G,{__index=_G2})
    
    --[[ Introduce some new useful functions ]]
    function _G2.unrequire(script) -- Very useful for script resets/reloads/cleanup
        package.loaded[script]=nil
    end
    
    local string = string
    local string_gmatch = string.gmatch
    local function string_split(inputstr,sep) -- Split strings into chunks or arguments (in tables)
        sep = sep or "%s" local t,n={},0
        for str in string_gmatch(inputstr, "([^"..sep.."]+)") do
            n=n+1 t[n]=str
        end
    return t end string.split = string_split
    local function string_upperFirst(s) -- Make the first letter of a string uppercase
        return s:sub(1,1):upper()..s:sub(2)
    end string.upperFirst = string_upperFirst
    local function string_startsWith(str, start) -- Check if a string starts with something
        return str:sub(1, #start) == start
    end string.startsWith = string_startsWith
    local function string_endsWith(str, ending) -- Check if a string ends with something
        return ending == "" or str:sub(-#ending) == ending
    end string.endsWith = string_endsWith
    
    local io_open, io_lines, string_gsub
        = io.open, io.lines, string.gsub
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
    local io_open, pairs, string_format, tostring
        = io.open, pairs, string.format, tostring
    function _G2.configFileWrite(file, config, sep) -- Write simple config file
        local configFile, sep = io_open(Script_Home..file, "w"), sep or "="
        for k,v in pairs(config) do
            configFile:write(string_format("%s%s%s\n", k, sep, tostring(v)))
        end
    end
    
    --[[ Update the search path ]]
    for i=1,5 do
        local Directory = _G[DirectoriesList[i]]
        package.path = string_format(".\\?.dll;%s?.dll;%slibs\\?.dll;%slibs\\?\\init.dll;%s", Directory, Directory, Directory, package.path) -- DLL
        package.path = string_format(".\\?.lua;%s?.lua;%slibs\\?.lua;%slibs\\?\\init.lua;%s", Directory, Directory, Directory, package.path) -- Lua
        package.path = string_format(".\\?;%s?;%slibs\\?;%slibs\\?\\init;%s", Directory, Directory, Directory, package.path) -- NoExtension
    end
    
    require(Natives)
    if Natives_FiveM then
        --[[ Introduce/Create FiveM style game native function calls ]]
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
        
        local string_lower, table_concat
            = string.lower, table.concat
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
    
    --[[ Framework Things ]]
    local PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
        = players.user or PlayerId or PLAYER.PLAYER_ID, PlayerPedId or PLAYER.PLAYER_PED_ID, GetEntityCoords or ENTITY.GET_ENTITY_COORDS, IsPedInAnyVehicle or PED.IS_PED_IN_ANY_VEHICLE, GetVehiclePedIsIn or PED.GET_VEHICLE_PED_IS_IN, GetPedInVehicleSeat or PED.GET_PED_IN_VEHICLE_SEAT, NetworkGetNetworkIdFromEntity or NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY, GetEntityModel or ENTITY.GET_ENTITY_MODEL, GetDisplayNameFromVehicleModel or VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL, IsThisModelABicycle or VEHICLE.IS_THIS_MODEL_A_BICYCLE, IsThisModelABike or VEHICLE.IS_THIS_MODEL_A_BIKE, IsThisModelABoat or VEHICLE.IS_THIS_MODEL_A_BOAT, IsThisModelACar or VEHICLE.IS_THIS_MODEL_A_CAR, IsThisModelAHeli or VEHICLE.IS_THIS_MODEL_A_HELI, IsThisModelAJetski or VEHICLE._IS_THIS_MODEL_A_JETSKI, IsThisModelAPlane or VEHICLE.IS_THIS_MODEL_A_PLANE, IsThisModelAQuadbike or VEHICLE.IS_THIS_MODEL_A_QUADBIKE, IsThisModelATrain or VEHICLE.IS_THIS_MODEL_A_TRAIN, IsThisModelAnAmphibiousCar or VEHICLE._IS_THIS_MODEL_AN_AMPHIBIOUS_CAR, IsThisModelAnAmphibiousQuadbike or VEHICLE_IS_THIS_MODEL_AN_AMPHIBIOUS_QUADBIKE
    local Player Player =
    setmetatable({
        Id          =    0,
        Ped         =    0,
        Handle      =    0,
        Coords      =    0,
        Vehicle     =   {
                            IsIn    =    0,
                            IsOp    =    0,
                            Id      =    0,
                            Handle  =    0,
                            NetId   =    0,
                            Model   =    0,
                            Name    =    0,
                            Type    =    setmetatable({},{__index=function() return false end}),
                        }
    },
    {
        __call  =   function()
                        Player.Id        = PlayerId()
                        local Ped        = PlayerPedId() Player.Ped,Player.Handle=Ped,Ped
                        Player.Coords    = GetEntityCoords(Ped, false)
                        local IsIn       = IsPedInAnyVehicle(Ped, false) Player.Vehicle.IsIn = IsIn
                        if IsIn then
                            local Vehicle   = Player.Vehicle
                            local Veh       = GetVehiclePedIsIn(Ped, false)
                            Vehicle.IsOp    = Ped == GetPedInVehicleSeat(Veh, -1)
                            
                            if Veh == Vehicle.Id then return end
                            
                            Vehicle.Id,Vehicle.Handle=Veh,Veh
                            Vehicle.NetId   = NetworkGetNetworkIdFromEntity(Veh)
                            local VehModel  = GetEntityModel(Veh) Vehicle.Model = VehModel
                            Vehicle.Name    = GetDisplayNameFromVehicleModel(VehModel)
                            
                            local Vehicle_Type = Vehicle.Type
                            Vehicle_Type.Bicycle            = IsThisModelABicycle(VehModel)
                            Vehicle_Type.Bike               = IsThisModelABike(VehModel)
                            Vehicle_Type.Boat               = IsThisModelABoat(VehModel)
                            Vehicle_Type.Car                = IsThisModelACar(VehModel)
                            Vehicle_Type.Heli               = IsThisModelAHeli(VehModel)
                            Vehicle_Type.Jetski             = IsThisModelAJetski(VehModel)
                            Vehicle_Type.Plane              = IsThisModelAPlane(VehModel)
                            Vehicle_Type.Quadbike           = IsThisModelAQuadbike(VehModel)
                            Vehicle_Type.Train              = IsThisModelATrain(VehModel)
                            Vehicle_Type.AmphibiousCar      = IsThisModelAnAmphibiousCar(VehModel)
                            Vehicle_Type.AmphibiousQuadbike = IsThisModelAnAmphibiousQuadbike(VehModel)
                        end
                    end
    })
    Info.Player = Player
    
    --[[ Automatically load __libs ]]
    local __libs_List, __libs_NMBR = {}, 0
    local ___libs_List = filesystem.list_files(__Script_Libs)
    for i=1, #___libs_List do
        local __lib = ___libs_List[i]
        if string_endsWith(__lib, ".lua") then
            __libs_NMBR = __libs_NMBR+1
            __libs_List[__libs_NMBR] = string_gsub(string_split(__lib, "//")[3], ".lua", "")
        end
    end
    table.sort(__libs_List)
    local pcall, require
        = pcall, require
    local Successful, __lib
    for i=1, __libs_NMBR do
        Successful, __lib = pcall(require, __libs_List[i])
        if not Successful then
            print(__lib)
        end
    end
    
    --[[ Add Reload Option With Debug Mode ]]
    if DebugMode then
        local Scripts_Init = function()Scripts_Init()end -- Required as Stand errors and complains otherwise - function tables unsupported.
		local menu = menu
        menu.action(menu.my_root(), "Reload Modules", {"elements reload", "reload elements", "reload modules"}, "", Scripts_Init)
    end
    
    --[[ Perform scripts initialization ]]
    --Scripts_Init()
end

local function init()
    --local print, error, DummyFunction = print, error, function()end _G.print, _G.error = DummyFunction, DummyFunction
    _init()
    --_G.print, _G.error, DummyFunction = print, error, nil
    collectgarbage()
    Scripts_Init()
end
init()

util.on_stop(Scripts_Stop)

util.create_tick_handler(function()
    tick()
return true end)