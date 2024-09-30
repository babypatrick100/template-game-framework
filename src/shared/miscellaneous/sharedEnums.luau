local sharedEnums = {
	BadgeId = {},
	GamepassId = {},
	DeveloperProductId = {},
	GroupId = {},
	Tag = {},
	Attribute = {},
	Utf8 = {
		Robux = utf8.char(0xE002),
		Premium = utf8.char(0xE001),
		Verified = utf8.char(0xE000),
	},
	GroupRank = {
		Owner = 255,
		Default = 0,

		-- [GROUP_ID]: {[string]: number}
	},
}

return table.freeze(sharedEnums)
