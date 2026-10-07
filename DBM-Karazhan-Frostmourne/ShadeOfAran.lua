
local mod	= DBM:NewMod("WotlkShadeAran", "DBM-Karazhan-Frostmourne")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(354280)
mod:SetEncounterID(924)
mod:RegisterCombat("combat")

mod.MAX_PHASES = 2

--Spell ids of the counter
mod.SPELLS = {
	BERSERK = {KEY = "BERSERK", NAME = "Berserk", ID = {DEFAULT = 26662}},
	FROSTBOLT = {KEY = "FROSTBOLT", NAME = "Frostbolt", ID = {
			DEFAULT = 29954,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250058,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250058
		}
	},
	FIREBALL = {KEY = "FIREBALL", NAME = "Fireball", ID = {
			DEFAULT = 29953,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250059,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250059
		}
	},
	ARCANE_MISSILES = {KEY = "ARCANE_MISSILES", NAME = "Arcane Missiles", ID = {
			DEFAULT = 29956,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250060,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250060
		}
	},
	FLAME_WREATH_CAST = {KEY = "FLAME_WREATH_CAST", NAME = "Flame Wreath", ID = {DEFAULT = 30004}},
	FLAME_WREATH = {KEY = "FLAME_WREATH", NAME = "Flame Wreath", ID = {DEFAULT = 29946}},
	WATER_BOLT = {KEY = "WATER_BOLT", NAME = "Water Bolt", ID = {DEFAULT = 37054}},
	ARCANE_EXPLOSION = {KEY = "ARCANE_EXPLOSION", NAME = "Arcane Explosion", ID = {DEFAULT = 29973}},
	CHAINS_OF_ICE = {KEY = "CHAINS_OF_ICE", NAME = "Chains of Ice", ID = {DEFAULT = 29991}},
	SUMMON_BLIZZARD = {KEY = "SUMMON_BLIZZARD", NAME = "Summon Blizzard", ID = {DEFAULT = 29969}},
	BLIZZARD = {KEY = "BLIZZARD", NAME = "Blizzard", ID = {DEFAULT = 29951}},
	COUNTERSPELL = {KEY = "COUNTERSPELL", NAME = "Counterspell", ID = {DEFAULT = 29961}},
	MASS_SLOW = {KEY = "MASS SLOW", NAME = "Mass Slow", ID = {DEFAULT = 30035}}
}

--We transition based on his health %
mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = {THRESHOLD = 40, WARNING = 45, NEXT = DBM_BEHAVIOR.PHASES.PHASE_TWO, PLAY_ANNOUNCEMENT = false}
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
	[mod.SPELLS.FLAME_WREATH_CAST.KEY] = {
		DEFAULT = 60,
		CAST_TIMER = {DEFAULT = 5}
	},
	[mod.SPELLS.FLAME_WREATH.KEY] = {DEFAULT = 20},
	[mod.SPELLS.ARCANE_EXPLOSION.KEY] = {
		DEFAULT = 60,
		CAST_TIMER = {DEFAULT = 10}
	},
	[mod.SPELLS.SUMMON_BLIZZARD.KEY] = {DEFAULT = 63},
	[mod.SPELLS.CHAINS_OF_ICE.KEY] = {DEFAULT = 60},
	[mod.SPELLS.COUNTERSPELL.KEY] = {DEFAULT = 6},
}
mod.HEROIC_TIMINGS_PHASE_DEFAULT = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.FLAME_WREATH_CAST.KEY] = {
		DEFAULT = 60,
		CAST_TIMER = {DEFAULT = 5}
	},
	[mod.SPELLS.FLAME_WREATH.KEY] = {DEFAULT = 20},
	[mod.SPELLS.ARCANE_EXPLOSION.KEY] = {
		DEFAULT = 60,
		CAST_TIMER = {DEFAULT = 5}
	},
	[mod.SPELLS.SUMMON_BLIZZARD.KEY] = {DEFAULT = 63},
	[mod.SPELLS.CHAINS_OF_ICE.KEY] = {DEFAULT = 60},
	[mod.SPELLS.COUNTERSPELL.KEY] = {DEFAULT = 6},
}
mod.TIMINGS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { PHASE_DEFAULT = mod.TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { PHASE_DEFAULT = mod.HEROIC_TIMINGS_PHASE_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { PHASE_DEFAULT = mod.HEROIC_TIMINGS_PHASE_DEFAULT },
}

--Define the model behavior
mod.BEHAVIOR = {
	[mod.SPELLS.BERSERK.KEY] = {
		TIMER = {DEFAULT = {TIMER = {type = "NewBerserkTimer"}, TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}}}}
	},
	[mod.SPELLS.FLAME_WREATH_CAST.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewCastAnnounce", option_name = "Flame Wreath cast warning"},
				--TIMER = {type = "NewCDTimer", option_name = "Flame Wreath cooldown"},
				--TIMER_STARTS = {SPELL_CAST_START = {}},
				WARNING_SHOW = {SPELL_CAST_START = {}},
				PLAY_SOUND = {SPELL_CAST_START = {sound = "aesoon"}}
			}
		},
		CAST_TIMER = {
			DEFAULT = {
				TIMER = {type = "NewCastTimer", timing = 5, icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Flame Wreath cast timer", color_type = 2},
				TIMER_STARTS = {SPELL_CAST_START = {}}
			}
		}
	},
	[mod.SPELLS.FLAME_WREATH.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				TIMER = {type = "NewBuffFadesTimer",  icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Flame Wreath debuff timer", color_type = 3},
				TIMER_STARTS = {SPELL_AURA_APPLIED = {}},
				WARNING = {type = "NewSpecialWarning", text = "Stop Moving!", option_name = "Flame Wreath stop moving warning"},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.AntiSpam}},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.AntiSpam, sound = "stopmove"}}
			}
		}
	},
	[mod.SPELLS.MASS_SLOW.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningDispel", filter = true, option_name = "Mass Slow dispell warning"},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return DBM_BEHAVIOR.CanDispel(boss_mod, trigger_data, args, spell_id, update_subtype, context) and 
							       DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end, 
					}
				},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return DBM_BEHAVIOR.CanDispel(boss_mod, trigger_data, args, spell_id, update_subtype, context) and 
							       DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end, 
						sound = "dispel_run"
					}
				}
			}
		}
	},
	[mod.SPELLS.ARCANE_EXPLOSION.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningMove", option_name = "Arcane Explosion cast warning"},
				--TIMER = {type = "NewCDTimer", option_name = "Arcane Explosion cooldown"},
				--TIMER_STARTS = {SPELL_CAST_START = {}},
				WARNING_SHOW = {SPELL_CAST_START = {}},
				PLAY_SOUND = {SPELL_CAST_START = {sound = "runtoedge", condition = DBM_BEHAVIOR.CanNotDispel}}
			}
		},
		CAST_TIMER = {
			DEFAULT = {
				TIMER = {type = "NewCastTimer", timing = 5, icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Arcane Explosion cast timer", color_type = 2},
				TIMER_STARTS = {SPELL_CAST_START = {}}
			}
		}
	},
	[mod.SPELLS.CHAINS_OF_ICE.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningDispel", filter = true, option_name = "Chains of Ice cast warning"},
				--TIMER = {type = "NewCDTimer", option_name = "Chains of Ice cooldown"},
				--TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_AURA_APPLIED = {}},
				WARNING_SHOW = {SPELL_AURA_APPLIED = { condition = DBM_BEHAVIOR.CanDispel, inject = "destName" }}
			}
		}
	},
	[mod.SPELLS.ARCANE_MISSILES.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Arcane Missiles warning"},
				WARNING_SHOW = {SPELL_DAMAGE = {
						antispam_duration = 6,
						condition = DBM_BEHAVIOR.OnSelfAntiSpam
					}
				},
				PLAY_SOUND = {
					SPELL_DAMAGE = {
						sound = "targetyou", 
						antispam_duration = 6,
						condition = DBM_BEHAVIOR.OnSelfAntiSpam
					}
				}
			}
		}
	},
	--[[[mod.SPELLS.SUMMON_BLIZZARD.KEY] = {
		CD = {
			DEFAULT = {
				TIMER = {type = "NewCDTimer", option_name = "Summon Blizzard cooldown"},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_START = {}},
			}
		}
	},--]]
	[mod.SPELLS.COUNTERSPELL.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Counterspell warning"},
				TIMER = {type = "NewCDTimer", option_name = "Counterspell cooldown", color_type = 3},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_SUCCESS = {}},
				WARNING_SHOW = {SPELL_CAST_SUCCESS = {condition = DBM_BEHAVIOR.OnSelf}},
				PLAY_SOUND = {SPELL_CAST_SUCCESS = {sound = "targetyou", condition = DBM_BEHAVIOR.OnSelf}}
			}
		}
	},
	[mod.SPELLS.BLIZZARD.KEY] = {
		DAMAGE_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningMove", option_name = "Blizzard damage warning"},
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
	[DBM_BEHAVIOR.SPELL_UNKNOWN_KEY] = {
		ADDS_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarning", text = "Kill the adds!", option_name = "Kill adds warning"},
				WARNING_SHOW = {
					CHAT_MSG_MONSTER_SAY = { 
						message = "I'm not finished yet! No, I have a few more tricks up my sleeve...",
						condition = DBM_BEHAVIOR.BossMessage
					}
				},
				PLAY_SOUND = {
					CHAT_MSG_MONSTER_SAY = { 
						message = "I'm not finished yet! No, I have a few more tricks up my sleeve...",
						condition = DBM_BEHAVIOR.BossMessage,
						sound = "killmob"
					}
				}
			}
		}
	},
	[mod.SPELLS.FROSTBOLT.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Frostbolt warning"},
				SCAN_TRIGGER = {SPELL_CAST_START = {frequency = 0.05, scan_attempts = 10}},
				WARNING_SHOW = {ON_SCAN = {}},
				PLAY_SOUND = {ON_SCAN = {sound = "targetyou"}}
			}
		},
	},
	[mod.SPELLS.FIREBALL.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou", option_name = "Fireball warning"},
				SCAN_TRIGGER = {SPELL_CAST_START = {frequency = 0.05, scan_attempts = 10}},
				WARNING_SHOW = {ON_SCAN = {}},
				PLAY_SOUND = {ON_SCAN = {sound = "targetyou"}}
			}
		}
	},
}

local boss_unit_id = "boss1"

function mod:OnCombatStart(delay)
	DBM_BEHAVIOR.CombatStartFetchData(mod)
	DBM_BEHAVIOR.StartPhaseMonitor(mod, boss_unit_id)
	DBM_BEHAVIOR.HandleModelEvent("ON_COMBAT_START", mod, {offset=-delay})
end

function mod:OnCombatEnd(wipe)
    --Stop the health monitor
	DBM_BEHAVIOR.StopPhaseMonitor(mod)
end

--Initialize the model
DBM_BEHAVIOR.CreateBossModel(mod)
DBM_BEHAVIOR.InitPhaseMonitor(mod, boss_unit_id, mod.MAX_PHASES)