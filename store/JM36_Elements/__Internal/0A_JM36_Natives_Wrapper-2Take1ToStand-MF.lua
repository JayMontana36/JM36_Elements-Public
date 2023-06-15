local native = {call=0,ByteBuffer8=0,ByteBuffer32=0,ByteBuffer256=0};_G.native=native

local native_invoker = native_invoker
local begin_call, end_call, get_return_value_bool, get_return_value_float, get_return_value_int, get_return_value_string, get_return_value_vector3, push_arg_bool, push_arg_float, push_arg_int, push_arg_pointer, push_arg_string, push_arg_vector3 = native_invoker.begin_call, native_invoker.end_call_2, native_invoker.get_return_value_bool, native_invoker.get_return_value_float, native_invoker.get_return_value_int, native_invoker.get_return_value_string, native_invoker.get_return_value_vector3, native_invoker.push_arg_bool, native_invoker.push_arg_float, native_invoker.push_arg_int, native_invoker.push_arg_pointer, native_invoker.push_arg_string, native_invoker.push_arg_vector3



local type = type
local math_type = math.type
local memory = memory
local memory_write_int = memory.write_int
local memory_write_float = memory.write_float
local memory_write_byte = memory.write_byte
local memory_write_string = memory.write_string
local memory_read_int = memory.read_int
local memory_read_float = memory.read_float
local memory_read_string = memory.read_string
local memory_alloc = memory.alloc
local setmetatable = debug.setmetatable
local MetatableVector3_OG = getmetatable(v3())
local MetatableMemory;MetatableMemory =
{
	set			=	function(Self,Offset,Value)
						switch type(Value) do
							case "nil":
								memory_write_int(Self+Offset,0)
								break
							case "number":
								if math_type(Value) == "float" then
									memory_write_float(Self+Offset,Value)
								else
									memory_write_int(Self+Offset,Value)
								end
								break
							case "boolean":
								memory_write_byte(Self,Value ? 1 : 0)
								break
							case "string":
								memory_write_string(Self,Value)
								break
							default:
								print(debug.traceback(('[Heads Up - Native]	Unsupported argument type ("%s" | "%s").'):format(type(Value),Value)))
						end
					end,
	__tointeger	=	memory_read_int,
	__tonumber	=	memory_read_float,
	__tostring	=	memory_read_string,
	__tov3		=	function(Self)
						setmetatable(Self,MetatableVector3_OG);return Self
					end,
	__index		=	function(Self,Key)
						return MetatableMemory[Key]
					end,
}
do
	local MetatableMemory_OG = getmetatable(memory_alloc(1))
	for Key, Value in MetatableMemory_OG do
		if not MetatableMemory[Key] then MetatableMemory[Key] = Value end
	end
end

local CreateNewMemPtrInstance = function(Size,Value)
	local MemPtr = setmetatable(memory_alloc(Size),MetatableMemory)
	MemPtr:set(0,Value)
	return MemPtr
end

native.ByteBuffer8 = function(Value)
	return CreateNewMemPtrInstance(8,Value)
end
native.ByteBuffer32 = function(Value)
	return CreateNewMemPtrInstance(32,Value)
end
native.ByteBuffer256 = function(Value)
	return CreateNewMemPtrInstance(256,Value)
end

local RetVal = {__tointeger=get_return_value_int,__tonumber=get_return_value_float,__tostring=get_return_value_string,__tov3=get_return_value_vector3}
native.call = function(NativeHexHash,...args)
	begin_call()
	for args as arg do
		switch type(arg) do
			case "nil":
				push_arg_int(0)
				break
			case "number":
				if math_type(arg) == "float" then
					push_arg_float(arg)
				else
					push_arg_int(arg)
				end
				break
			case "boolean":
				push_arg_bool(arg)
				break
			case "string":
				push_arg_pointer(arg)
				break
			case "userdata":
				setmetatable(arg,MetatableMemory)
				push_arg_pointer(arg)
				break
			default:
				print(debug.traceback(('[Heads Up - Native]	Unsupported argument type ("%s" | "%s").'):format(type(arg),arg)))
				push_arg_int(0)
		end
	end
	end_call(NativeHexHash)
	return RetVal
end



do
	local _G_Metatable_Original = getmetatable(_G)
	local natives=require'natives_JM36-2T1-UNI_AIO-ABB-1686866900-Comments-Legacy'
	setmetatable(_G,_G_Metatable_Original)
	_G2.JM36_2Take1_Natives = natives
end



--[[
do
	local GlobalsWarnAndRedirect
	local _G2 = _G2
	JM36.CreateThread_HighPriority(function()
		setmetatable
		(
			_G,
			{
				__index = function(Self,Key)
					return _G2[Key]
				end,
				__newindex = function(Self,Key,Value)
					local DebugData = debug.getinfo(2,'lS')
					if DebugData and GlobalsWarnAndRedirect and not (DebugData.what == 'main' or DebugData.short_src == 'scripts/main.lua') then
						print(('[Warning - Script]	%s:%s\n	Variable "%s" (%s) declared global (use local).'):format(DebugData.short_src, DebugData.currentline, Key, type(Value)))
						_G2._GlobalVariables[Key] = Value
					else
						rawset(Self,Key,Value)
					end
				end
			}
		)
		_G2.JM36_2Take1_Natives = Natives
	end)
end
]]
