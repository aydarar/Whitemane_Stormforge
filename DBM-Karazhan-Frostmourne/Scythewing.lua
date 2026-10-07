local mod	= DBM:NewMod("Scythewing", "DBM-Karazhan-Frostmourne")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(354284)
mod:SetEncounterID(924)
mod:RegisterCombat("combat")

mod.MAX_PHASES = 4

--Spell ids of the counter
mod.SPELLS = {
	BERSERK = {KEY = "BERSERK", NAME = "Berserk", ID = {DEFAULT = 26662}},
	DEADEN = {KEY = "DEADEN", NAME = "Deaden", ID = {
			DEFAULT = 41410,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250068,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250068
		}
	},
	BLISTERING_COLD = {KEY = "BLISTERING_COLD", NAME = "Blistering Cold", ID = { 
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 70123,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 71047,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 71048,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 71049
		}
	},
	TAILSWEEP = {KEY = "TAILSWEEP", NAME = "Tail Sweep", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 55697,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 55697,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 55696,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 55696
		}
	},
	FROSTBOLT_VOLLEY = {KEY = "FROSTBOLT_VOLLEY", NAME = "Frostbolt Volley", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 72905,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 72906,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 72907,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 72908
		}
	},
	CONSUMPTION = {KEY = "CONSUMPTION", NAME = "Consumption", ID = {DEFAULT = 28865}},
	SHADOW_BOLT = {KEY = "SHADOW_BOLT", NAME = "Shadow Bolt", ID = {DEFAULT = 9250074}},
	SCYTHEWINGS_WAIL = {KEY = "SCYTHEWINGS_WAIL", NAME = "Scythewing's Wail", ID = {DEFAULT = 9250057}}
}

--We transition based on his health %
mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = {THRESHOLD = 80, WARNING = 85, NEXT = DBM_BEHAVIOR.PHASES.PHASE_TWO},
	[DBM_BEHAVIOR.PHASES.PHASE_TWO] = {THRESHOLD = 50, WARNING = 55, NEXT = DBM_BEHAVIOR.PHASES.PHASE_THREE},
	[DBM_BEHAVIOR.PHASES.PHASE_THREE] = {THRESHOLD = 20, WARNING = 25, NEXT = DBM_BEHAVIOR.PHASES.PHASE_FOUR}
}
mod.PHASE_TRANSITION_THRESHOLDS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
}

--Timing tables
mod.TIMINGS_PHASE_DEFAULT_NORMAL = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.DEADEN.KEY] = {DEFAULT = 30, ON_COMBAT_START = 15},
	[mod.SPELLS.BLISTERING_COLD.KEY] = {DEFAULT = 60, PHASE_START_2 = 35},
	[mod.SPELLS.FROSTBOLT_VOLLEY.KEY] = {DEFAULT = 20},
	[mod.SPELLS.TAILSWEEP.KEY] = {DEFAULT = 10}
}
mod.TIMINGS_PHASE_DEFAULT_HEROIC = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.DEADEN.KEY] = {DEFAULT = 15},
	[mod.SPELLS.BLISTERING_COLD.KEY] = {DEFAULT = 60, PHASE_START_2 = 35},
	[mod.SPELLS.FROSTBOLT_VOLLEY.KEY] = {DEFAULT = 20},
	[mod.SPELLS.TAILSWEEP.KEY] = {DEFAULT = 10}
}
mod.TIMINGS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT_NORMAL },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT_NORMAL },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT_HEROIC },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT_HEROIC },
}

--Define the model behavior
mod.BEHAVIOR = {
	[mod.SPELLS.BERSERK.KEY] = {TIMER = {DEFAULT = {TIMER = {type = "NewBerserkTimer"}, TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}}}}},
	[mod.SPELLS.TAILSWEEP.KEY] = {
		CD = {
			DEFAULT = {TIMER = {type = "NewCDTimer", option_name = "Tail Sweep cooldown"}, TIMER_STARTS = {ON_COMBAT_START = {}, SPELL_CAST_SUCCESS = {}}}
		}
	},
	[mod.SPELLS.FROSTBOLT_VOLLEY.KEY] = {
		CD = {
			DEFAULT = {TIMER = {type = "NewCDTimer", option_name = "Frostbolt volley cooldown"}, TIMER_STARTS = {PHASE_START_2 = {}, SPELL_CAST_SUCCESS = {}}}
		}
	},
	[mod.SPELLS.DEADEN.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Deaden warning"},
				TIMER = {type = "NewCDTimer", option_name = "Deaden cooldown", color_type = 3},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_START = {}},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.OnSelf}},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {sound = "targetyou", condition = DBM_BEHAVIOR.OnSelf}}
			}
		},
		TAUNT_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningTaunt", option_name = "Deaden taunt warning"},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.NotOnSelfAndIsTank, inject = "destName"}},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {sound = "tauntboss", condition = DBM_BEHAVIOR.NotOnSelfAndIsTank}}
			}
		}
	},
	[mod.SPELLS.BLISTERING_COLD.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningGTFO", option_name = "Blistering Cold warning"},
				TIMER = {type = "NewCDTimer", option_name = "Blistering Cold cooldown"},
				TIMER_STARTS = {PHASE_START_3 = {}, SPELL_CAST_START = {}},
				WARNING_SHOW = {SPELL_CAST_START = {}},
				PLAY_SOUND = {SPELL_CAST_START = {sound = "runaway"}}
			}
		}
	},
	[mod.SPELLS.CONSUMPTION.KEY] = {
		DAMAGE_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningMove", option_name = "Consumption warning"},
				WARNING_SHOW = {
					SPELL_DAMAGE = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}, 
					SPELL_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}
				},
				PLAY_SOUND = {
					SPELL_DAMAGE = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "runaway"},
					SPELL_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "runaway"}
				}
			}
		}
	},
	[mod.SPELLS.SCYTHEWINGS_WAIL.KEY] = {
		WARN_AURA = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarning", text = "Scythewing's Wail", option_name = "Scythewing's Wail warning"},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {}},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED = {
						sound = "enrage"
					}
				}
			}
		}
	},
}

local boss_unit_id = "boss1"

function mod:OnCombatStart(delay)
	--Try read the kick group size setting
	mod.vb.kick_group_count = tonumber(mod.Options.KickGroupSize) or mod.vb.kick_group_count
	--Fetch difficulty from dbm
	DBM_BEHAVIOR.CombatStartFetchData(mod)
	DBM_BEHAVIOR.StartPhaseMonitor(mod, boss_unit_id)
	DBM_BEHAVIOR.HandleModelEvent("ON_COMBAT_START", mod, {offset=-delay})
end

function mod:OnCombatEnd(wipe)
    --Stop the monitors
	DBM_BEHAVIOR.StopPhaseMonitor(mod)
end

--Initialize the model
DBM_BEHAVIOR.CreateBossModel(mod)
DBM_BEHAVIOR.InitPhaseMonitor(mod, boss_unit_id, mod.MAX_PHASES)