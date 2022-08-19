local setmetatable <const> = setmetatable
local mode <const> = "kv"
local call <const> = function(Table, Key) return Table[Key] end
return function(Function)
	local Function <const> = Function
--	local TimesRan = 0
	return setmetatable({},
		{
			__mode	=	mode,
			__index	=	function(Table, Key)
--							TimesRan = TimesRan + 1
--							print('TimesRan', TimesRan)
							local Value = Function(Key)
							--print('AlreadyCachedButRanAgainAnyways', rawget(Table,Key) == Value, Table, Key, Value, rawget(Table,Key))
							Table[Key] = Value
							return Value
						end,
			__call	=	call,
		}
	)
end
