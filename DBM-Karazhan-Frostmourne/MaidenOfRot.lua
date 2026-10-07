local mod	= DBM:NewMod("MaidenRot", "DBM-Karazhan-Frostmourne")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(354272)
mod:SetEncounterID(924)
mod:RegisterCombat("combat")

--Spell ids of the counter
mod.SPELLS = {
	BERSERK = {KEY = "BERSERK", NAME = "Berserk", ID = {DEFAULT = 26662}},
	DEEP_FREEZE = {KEY = "DEEP_FREEZE", NAME = "Deep Freeze", ID = {
			DEFAULT = 70380,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 9250075,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 70381
		}
	},
	FRENZY = {KEY = "FRENZY", NAME = "Frenzy", ID = {DEFAULT = 12795}},
	PERMAFROST = {KEY = "PERMAFROST", NAME = "Permafrost", ID = {DEFAULT = 9250065}}
}

--We transition based on his health %
mod.MAX_PHASES = 2
mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = {THRESHOLD = 20, WARNING = 25, NEXT = DBM_BEHAVIOR.PHASES.PHASE_TWO, PLAY_ANNOUNCEMENT = false}
}
mod.PHASE_TRANSITION_THRESHOLDS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
}

--Timing tables
mod.TIMINGS_PHASE_DEFAULT = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.DEEP_FREEZE.KEY] = {DEFAULT = 30, DEBUFF_TIMER = {DEFAULT = 14}}
}
mod.TIMINGS_HEROIC_PHASE_DEFAULT = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.DEEP_FREEZE.KEY] = {DEFAULT = 15, DEBUFF_TIMER = {DEFAULT = 14}},
	[mod.SPELLS.PERMAFROST.KEY] = {APPLICATION_TIMER = {DEFAULT = 3}}
}
mod.TIMINGS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { PHASE_DEFAULT = mod.TIMINGS_HEROIC_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { PHASE_DEFAULT = mod.TIMINGS_HEROIC_PHASE_DEFAULT },
}

--Define the model behavior
mod.BEHAVIOR = {
	[mod.SPELLS.BERSERK.KEY] = {
		TIMER = {DEFAULT = {TIMER = {type = "NewBerserkTimer"}, TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}}}}
	},
	[mod.SPELLS.DEEP_FREEZE.KEY] = {
		WARN_CAST = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Deep Freeze warning"},
				TIMER = {type = "NewCDTimer", option_name = "Deep Freeze cooldown"},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_START = {}},
				SCAN_TRIGGER = {SPELL_CAST_START = {}},
				WARNING_SHOW = {ON_SCAN = {}},
				PLAY_SOUND = {ON_SCAN = {sound = "targetyou"}}
			}
		},
		DEBUFF_TIMER = {
			DEFAULT = {
				TIMER = {type = "NewBuffFadesTimer",  icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Deep Freeze debuff timer", color_type = 3},
				TIMER_STARTS = {
					SPELL_AURA_APPLIED = {
						condition = DBM_BEHAVIOR.OnSelf
					}
				}
			}
		}
	},
	[mod.SPELLS.FRENZY.KEY] = {
		WARN_AURA = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarning", text = "Frenzy", option_name = "Frenzy warning"},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {}},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED = {
						sound = "frenzy"
					}
				}
			}
		}
	},
	--[[[mod.SPELLS.PERMAFROST.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningStack", stacks = 7, option_name = "Permafrost stack warning"},
				WARNING_SHOW = {
					SPELL_AURA_APPLIED_DOSE = {threshold = 3, condition = DBM_BEHAVIOR.StackHigh, inject = "amount"}
				},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED_DOSE = {threshold = 3, condition = DBM_BEHAVIOR.StackHigh, sound = "stackhigh"}
				},
			}
		}
	}--]]
}
local boss_unit_id = "boss1"

function mod:OnCombatStart(delay)
	DBM_BEHAVIOR.CombatStartFetchData(mod)
	DBM_BEHAVIOR.StartPhaseMonitor(mod, boss_unit_id)
	DBM_BEHAVIOR.HandleModelEvent("ON_COMBAT_START", mod, {offset=-delay})
end

function mod:OnCombatEnd(wipe)
	DBM_BEHAVIOR.StopPhaseMonitor(mod)
end

--Initialize the model
DBM_BEHAVIOR.CreateBossModel(mod)
DBM_BEHAVIOR.InitPhaseMonitor(mod, boss_unit_id, mod.MAX_PHASES)