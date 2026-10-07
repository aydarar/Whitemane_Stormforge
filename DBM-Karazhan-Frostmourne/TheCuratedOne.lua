local mod	= DBM:NewMod("CuratedOne", "DBM-Karazhan-Frostmourne")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(354276)
mod:SetEncounterID(924)
mod:RegisterCombat("combat")

mod.MAX_PHASES = 4

--Spell ids of the counter
mod.SPELLS = {
	BERSERK = {KEY = "BERSERK", NAME = "Berserk", ID = {DEFAULT = 26662}},
	CHAOS_BOLT = {KEY = "CHAOS_BOLT", NAME = "Chaos Bolt", ID = {
			DEFAULT = 51287,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 9250076
		}
	},
	SOUL_FLAY = {KEY = "SOUL_FLAY", NAME = "Soul Flay", ID = {DEFAULT = 45442}},
	FEAR = {KEY = "FEAR", NAME = "Fear", ID = {DEFAULT = 30530}},
	AURA_OF_FEAR = {KEY = "AURA_OF_FEAR", NAME = "Aura of Fear", ID = {DEFAULT = 9250009}},
	MORTAL_WOUND = {KEY = "MORTAL_WOUND", NAME = "Mortal Wound", ID = {DEFAULT = 25646}},
	BLOOD_MIRROR = {KEY = "BLOOD_MIRROR", NAME = "Blood Mirror", ID = {DEFAULT = 70838}},
	DEATH_AND_DECAY = {KEY = "DEATH_AND_DECAY", NAME = "Death and Decay", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 71001,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 72108,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 72109,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 72110
		}
	},
	COLDFLAME = {KEY = "COLDFLAME", NAME = "Coldflame", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 69146,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 70824,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 70823,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 70825,
		}
	},
	COLDFLAME_SUMMON = {KEY = "COLDFLAME_SUMMON", NAME = "Coldflame", ID = {DEFAULT = 69138}},
	CURATED_SUFFERING = {KEY = "CURATED_SUFFERING", NAME = "Curated Suffering", ID = {
			DEFAULT = 9250055,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250055
		}
	}
}

--We transition based on his health %
mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = {THRESHOLD = 75, WARNING = 80, NEXT = DBM_BEHAVIOR.PHASES.PHASE_TWO},
	[DBM_BEHAVIOR.PHASES.PHASE_TWO] = {THRESHOLD = 40, WARNING = 45, NEXT = DBM_BEHAVIOR.PHASES.PHASE_THREE},
	[DBM_BEHAVIOR.PHASES.PHASE_THREE] = {THRESHOLD = 15, WARNING = 20, NEXT = DBM_BEHAVIOR.PHASES.PHASE_FOUR}
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
	[mod.SPELLS.CHAOS_BOLT.KEY] = {DEFAULT = 4, ON_COMBAT_START = 3},
	[mod.SPELLS.FEAR.KEY] = {DEFAULT = 25},
	[mod.SPELLS.BLOOD_MIRROR.KEY] = {DEFAULT = 25},
	[mod.SPELLS.DEATH_AND_DECAY.KEY] = {DEFAULT = 10, PHASE_START_2 = 10},
	[mod.SPELLS.COLDFLAME_SUMMON.KEY] = {DEFAULT = 10}
}
mod.TIMINGS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
}

--Define the model behavior
mod.BEHAVIOR = {
	[mod.SPELLS.BERSERK.KEY] = {
		TIMER = {DEFAULT = {TIMER = {type = "NewBerserkTimer"}, TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}}}}
	},
	[mod.SPELLS.FEAR.KEY] = {
		CD = {
			DEFAULT = {
				TIMER = {type = "NewCDTimer", option_name = "Fear cooldown", color_type = 3},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_SUCCESS = {}}
			}
		}
	},
	[mod.SPELLS.CHAOS_BOLT.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Chaos Bolt warning"},
				TIMER = {type = "NewCDTimer", option_name = "Chaos Bolt cooldown", color_type = 3},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_START = {}},
				SCAN_TRIGGER = {SPELL_CAST_START = {frequency = 0.05, scan_attempts = 10}},
				WARNING_SHOW = {ON_SCAN = {}},
			}
		}
	},
	[mod.SPELLS.BLOOD_MIRROR.KEY] = {
		AURA_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Blood Mirror warning"},
				TIMER = {type = "NewCDTimer", option_name = "Blood Mirror cooldown", color_type = 3},
				TIMER_STARTS = {PHASE_START_3 = {}, SPELL_AURA_APPLIED = {}},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.IsTargetOrDest}},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.IsTargetOrDest, sound = "targetyou"}}
			}
		}
	},
	[mod.SPELLS.SOUL_FLAY.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Soul Flay warning"},
				WARNING_SHOW = {SPELL_CAST_SUCCESS = {condition = DBM_BEHAVIOR.OnSelf}},
				PLAY_SOUND = {SPELL_CAST_SUCCESS = {condition = DBM_BEHAVIOR.OnSelf, sound = "targetyou"}}
			}
		}
	},
	[mod.SPELLS.MORTAL_WOUND.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningStack", stacks = 5, option_name = "Mortal Found stack warning"},
				WARNING_SHOW = {
					SPELL_AURA_APPLIED_DOSE = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
							return args.amount > 5 and 
							       DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
						end,
						inject = "amount"
					}
				},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED_DOSE = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.amount > 5 and 
							       DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
						end,
						sound = "stackhigh"
					}
				},
			}
		},
		TAUNT_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningTaunt", option_name = "Mortal Found taunt warning"},
				WARNING_SHOW = {
					SPELL_AURA_APPLIED_DOSE = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
							return args.amount == 5 and 
							       not DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context) and
								   DBM_BEHAVIOR.IsTank(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end,
						inject = "destName"
					}
				},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED_DOSE = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
							return args.amount == 5 and 
							       not DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context) and
								   DBM_BEHAVIOR.IsTank(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end,
						sound = "tauntboss"
					}
				}
			}
		}
	},
	[mod.SPELLS.COLDFLAME_SUMMON.KEY] = {
		CD = {
			DEFAULT = {TIMER = {type = "NewCDTimer", option_name = "Coldflame summon cooldown", color_type = 2},TIMER_STARTS = {PHASE_START_4 = {}, SPELL_SUMMON = {}}},
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = {TIMER = {type = "NewCDTimer", option_name = "Coldflame summon cooldown"},TIMER_STARTS = {ON_COMBAT_START = {}, SPELL_SUMMON = {}}},
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = {TIMER = {type = "NewCDTimer", option_name = "Coldflame summon cooldown"},TIMER_STARTS = {ON_COMBAT_START = {}, SPELL_SUMMON = {}}},
		}
	},
	[mod.SPELLS.COLDFLAME.KEY] = {
		DAMAGE_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningGTFO", option_name = "Coldflame damage warning"},
				WARNING_SHOW = {
					SPELL_PERIODIC_DAMAGE = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}, 
					SPELL_PERIODIC_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}
				},
				PLAY_SOUND = {
					SPELL_PERIODIC_DAMAGE = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "watchfeet"}, 
					SPELL_PERIODIC_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "watchfeet"}
				}
			}
		}
	},
	[mod.SPELLS.DEATH_AND_DECAY.KEY] = {
		DAMAGE_WARN = {
			DEFAULT = {
				TIMER = {type = "NewCDTimer", option_name = "Death and Decay cooldown", color_type = 2},
				TIMER_STARTS = {PHASE_START_2 = {}, SPELL_CAST_SUCCESS = ""},
				WARNING = {type = "NewSpecialWarningGTFO", option_name = "Death and Decay damage warning"},
				WARNING_SHOW = {
					SPELL_PERIODIC_DAMAGE = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}, 
					SPELL_PERIODIC_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}
				},
				PLAY_SOUND = {
					SPELL_PERIODIC_DAMAGE = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "watchfeet"}, 
					SPELL_PERIODIC_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "watchfeet"}
				}
			}
		}
	},
	[mod.SPELLS.AURA_OF_FEAR.KEY] = {
		TURN_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningLookAway", option_name = "Aura of Fear warning"},
				WARNING_SHOW = {SPELL_CAST_START = {condition = DBM_BEHAVIOR.AntiSpam}},
				PLAY_SOUND = {SPELL_CAST_START = {condition = DBM_BEHAVIOR.AntiSpam, sound = "turnaway"}}
			}
		}
	}
}

local boss_unit_id = "boss1"

function mod:OnCombatStart(delay)
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
