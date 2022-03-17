local _GetHashKey = util.joaat
local __GetHashKey = setmetatable({},
	{
		__mode = "kv",
		__index	=	function(Table, Key)
						local Hash = _GetHashKey(Key)
						Table[Key] = Hash
						return Hash
					end,
		__call	=	function(Table, String)
						return Table[String]
					end,
	}
)
GetHashKey, util.joaat = __GetHashKey, __GetHashKey
return __GetHashKey