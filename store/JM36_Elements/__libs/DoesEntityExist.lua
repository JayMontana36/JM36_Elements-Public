local entities_handle_to_pointer = entities.handle_to_pointer
local _DoesEntityExist = function(EntityScriptHandle)
	return entities_handle_to_pointer(EntityScriptHandle) ~= 0
end
DoesEntityExist = _DoesEntityExist
return _DoesEntityExist