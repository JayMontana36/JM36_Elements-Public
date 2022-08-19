local entities_handle_to_pointer <const> = entities.handle_to_pointer
local _DoesEntityExist <const> = function(EntityScriptHandle)
	return EntityScriptHandle and entities_handle_to_pointer(EntityScriptHandle) ~= 0
end
DoesEntityExist = _DoesEntityExist
return _DoesEntityExist