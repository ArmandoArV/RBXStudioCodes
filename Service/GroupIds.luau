-- GroupIds.luau
-- Module script containing group IDs and their associated spawn locations

local groupIDs = {}

groupIDs.EM = {
	MAIN = {
		ID = 5101519,
		TEAM = "Forest green", -- EJERCITO [1]
		SPAWN_LOCATION = "EM" -- Name in workspace.ubicaciones or CapturePoints
	},
	ALTOMANDO = {
		ID = 5101519,
		TEAM = "Medium blue", -- EJERCITO [1]
		SPAWN_LOCATION = "EM"
	}
}

groupIDs.MARINA = {
	MAIN = {
		ID = 13540601,
		TEAM = "Bright bluis green", -- 1 Marina 1
		SPAWN_LOCATION = "MARINA"
	},
	FAN = {
		ID = 33481034,
		SPAWN_LOCATION = "MARINA"
	},
	PN = {
		ID = 33481029,
		SPAWN_LOCATION = "MARINA"
	},
	UNOPES = {
		ID = 33481038,
		SPAWN_LOCATION = "MARINA"
	},
	FES = {
		ID = 33481037,
		SPAWN_LOCATION = "MARINA"
	}
}

groupIDs.FAM = {
	MAIN = {
		ID = 33481012,
		TEAM = "Bright orange", -- 1 FAM 4
		SPAWN_LOCATION = "FAM"
	},
	BFP = {
		ID = 33481015,
		TEAM = "Cocoa", -- 1 FAM 4
		SPAWN_LOCATION = "FAM"
	}
}

groupIDs.GN = {
	MAIN = {
		ID = 9129741, -- ORIGINAL: 4863102
		TEAM = "Institutional white", -- 1 GN 2 (PFP MAIN)
		SPAWN_LOCATION = "GN"
	},
	GENDARMERIA = {
		ID = 33481044,
		SPAWN_LOCATION = "GN"
	},
	TRANSITO = {
		ID = 33481051,
		SPAWN_LOCATION = "GN"
	}
}

groupIDs.PM = {
	MAIN = {
		ID = 33481016,
		TEAM = "Parsley green", -- 1 PM 2
		SPAWN_LOCATION = "PM_MAIN"
	}
}

groupIDs.HCM = {
	MAIN = {
		ID = 33483010,
		TEAM = "Salmon", -- 1 PM 2
		SPAWN_LOCATION = "EM"
	}
}

groupIDs.AIC = {
	MAIN = {
		ID = 32758507,
		TEAM = "Oyster", -- 1 AIC
		SPAWN_LOCATION = "AIC"
	},
	GL = {
		ID = 14337201,
		TEAM = "Medium blue",
		SPAWN_LOCATION = "AIC"
	}
}

return groupIDs