
local mod	= DBM:NewMod("ArchMageAnton", "DBM-Karazhan-Frostmourne")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(354288)
mod:SetEncounterID(924)
mod:RegisterCombat("combat")

mod.MAX_PHASES = 3

--Spell ids of the counter
mod.SPELLS = {
	BERSERK = {KEY = "BERSERK", NAME = "Berserk", ID = {DEFAULT = 26662}},
    SHADOWBOLT = {KEY = "SHADOWBOLT", NAME = "Shadow Bolt", ID = {DEFAULT = 29317}},
    FROSTBOLT = {KEY = "FROSTBOLT", NAME = "Frostbolt", ID = {DEFAULT = 55802}},
    PRESENCE_OF_FROST = {KEY = "PRESENCE_OF_FROST", NAME = "Presence of Frost", ID = {DEFAULT = 9250005}},
    PRESENCE_OF_SHADOW = {KEY = "PRESENCE_OF_SHADOW", NAME = "Presence of Shadow", ID = {DEFAULT = 9250004}},
    CHILL = {KEY = "CHILL", NAME = "Chill", ID = {DEFAULT = 55699, [DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] =  28547}},
    BLIGHT = {
		KEY = "BLIGHT", NAME = "Blight", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 9250041,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 9250042,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250043,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250044
		}
	},
    EMPOWERED_BLIGHT = {
		KEY = "EMPOWERED_BLIGHT", NAME = "Empowered Blight", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 9250045,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 9250046,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250047,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250048
		}
	},
	CURSE_OF_DOOM = {
		KEY = "CURSE_OF_DOOM", NAME = "Curse of Doom", ID = {
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 9250049,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = 9250050,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250051,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = 9250052
		}
	},
    AURA_OF_SUFFERING = {KEY = "AURA_OF_SUFFERING", NAME = "Aura of Suffering", ID = {DEFAULT = 41292}},
    FINGER_OF_DEATH = {KEY = "FINGER_OF_DEATH", NAME = "Finger of Death", ID = {DEFAULT = 31984}},
	SPELL_DISRUPTION = {KEY = "SPELL_DISRUPTION", NAME = "Spell Disruption", ID = {
			DEFAULT = 29310,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250070
		}
	},
	PERMAFROST = {KEY = "PERMAFROST", NAME = "Permafrost", ID = {
			DEFAULT = 67856,
			[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = 9250062
		}
	},
	SHROUD_OF_DARKNESS = {KEY = "SHROUD_OF_DARKNESS", NAME = "Shroud of Darkness", ID = {
			DEFAULT = 54525,
			[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = 9250077
		}
	}
}

--We transition based on his health %
mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = {THRESHOLD = 60, WARNING = 65, NEXT = DBM_BEHAVIOR.PHASES.PHASE_TWO},
	[DBM_BEHAVIOR.PHASES.PHASE_TWO] = {THRESHOLD = 10, WARNING = 15, NEXT = DBM_BEHAVIOR.PHASES.PHASE_THREE}
}
mod.PHASE_HEROIC_TRANSITION_THRESHOLDS_DEFAULT = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = {THRESHOLD = 60, WARNING = 65, NEXT = DBM_BEHAVIOR.PHASES.PHASE_TWO},
	[DBM_BEHAVIOR.PHASES.PHASE_TWO] = {THRESHOLD = 10, WARNING = 15, NEXT = DBM_BEHAVIOR.PHASES.PHASE_THREE}
}
mod.PHASE_TRANSITION_THRESHOLDS = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = { TRANSITION_DEFAULT = mod.PHASE_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = { TRANSITION_DEFAULT = mod.PHASE_HEROIC_TRANSITION_THRESHOLDS_DEFAULT },
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = { TRANSITION_DEFAULT = mod.PHASE_HEROIC_TRANSITION_THRESHOLDS_DEFAULT },
}

--Timing tables
mod.TIMINGS_PHASE_DEFAULT = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.CURSE_OF_DOOM.KEY] = {
		DEFAULT = 40, DECURSE_TIMER = {DEFAULT = 12}
	},
	[mod.SPELLS.PERMAFROST.KEY] = {DEFAULT = 30, ON_COMBAT_START = 20},
	[mod.SPELLS.SHROUD_OF_DARKNESS.KEY] = {DEFAULT = 12},
	[mod.SPELLS.BLIGHT.KEY] = {CURE_TIMER = {DEFAULT = 20}},
	[DBM_BEHAVIOR.SPELL_UNKNOWN_KEY] = {
		WATER_ELEMENTAL_TIMER = {DEFAULT = 60, ON_COMBAT_START = 50},
		DEATH_ELEMENTAL_TIMER = {DEFAULT = 60, ON_COMBAT_START = 40},
		DEATH_ELEMENTAL_EXPLOSION = {DEFAULT = 14}
	},
	[mod.SPELLS.PRESENCE_OF_FROST.KEY] = {DEFAULT = 29},
	[mod.SPELLS.PRESENCE_OF_SHADOW.KEY] = {DEFAULT = 29}
}

mod.HEROIC_TIMINGS_PHASE_DEFAULT = {
	[mod.SPELLS.BERSERK.KEY] = {DEFAULT = 600},
	[mod.SPELLS.CURSE_OF_DOOM.KEY] = {
		DEFAULT = 40, DECURSE_TIMER = {DEFAULT = 10}
	},
	[mod.SPELLS.PERMAFROST.KEY] = {DEFAULT = 30, ON_COMBAT_START = 20},
	[mod.SPELLS.SHROUD_OF_DARKNESS.KEY] = {DEFAULT = 12},
	[mod.SPELLS.BLIGHT.KEY] = {
		CURE_TIMER = {DEFAULT = 20}
	},
	[DBM_BEHAVIOR.SPELL_UNKNOWN_KEY] = {
		WATER_ELEMENTAL_TIMER = {DEFAULT = 60, ON_COMBAT_START = 50},
		DEATH_ELEMENTAL_TIMER = {DEFAULT = 60, ON_COMBAT_START = 40},
		DEATH_ELEMENTAL_EXPLOSION = {DEFAULT = 10}
	},
	[mod.SPELLS.PRESENCE_OF_FROST.KEY] = {DEFAULT = 29},
	[mod.SPELLS.PRESENCE_OF_SHADOW.KEY] = {DEFAULT = 29}
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
	[mod.SPELLS.BLIGHT.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningDispel", filter = true, option_name = "Blight cure warning"}, 
				WARNING_SHOW = {SPELL_AURA_APPLIED = {
						inject = "destName",
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return DBM_BEHAVIOR.CanCleanseDisease(boss_mod, trigger_data, args, spell_id, update_subtype, context) and 
							       DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end,
					}
				}
			}
		},
		CURE_TIMER  = {
			DEFAULT = {
				TIMER = {type = "NewBuffFadesTimer",  icon = DBM_COMMON_L.HEALER_ICON, option_name = "Blight cure timer", color_type = 3},
				TIMER_STARTS = {SPELL_AURA_APPLIED = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return DBM_BEHAVIOR.CanCleanseDisease(boss_mod, trigger_data, args, spell_id, update_subtype, context) and 
							       DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				}
			}
		}
	},
	[mod.SPELLS.EMPOWERED_BLIGHT.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningDispel", filter = true, option_name = "Empowered Blight cure warning"},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {inject = "destName"}},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {sound = "dispelnow", condition = DBM_BEHAVIOR.CanCleanseDisease}}
			}
		}
	},
	[mod.SPELLS.CURSE_OF_DOOM.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningDispel", filter = true, option_name = "Curse of Doom decurse warning"},
				TIMER = {type = "NewCDTimer", option_name = "Curse of Doom cooldown", color_type = 2},
				TIMER_STARTS = {PHASE_START_2 = {}, SPELL_AURA_APPLIED = {}},
				WARNING_SHOW = {SPELL_AURA_APPLIED = {inject = "destName", condition = DBM_BEHAVIOR.AntiSpam}},
				PLAY_SOUND = {SPELL_AURA_APPLIED = {
						sound = "decurse", 
						antispam_duration = 8,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return DBM_BEHAVIOR.CanDecurse(boss_mod, trigger_data, args, spell_id, update_subtype, context) and
							       DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end,
					}
				}
			}
		},
		DECURSE_TIMER  = {
			DEFAULT = {
				TIMER = {type = "NewBuffFadesTimer",  icon = DBM_COMMON_L.HEALER_ICON, option_name = "Curse of Doom decurse timer", color_type = 3},
				TIMER_STARTS = {SPELL_AURA_APPLIED = {
						antispam_duration = 8,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return DBM_BEHAVIOR.CanDecurse(boss_mod, trigger_data, args, spell_id, update_subtype, context) and
							       DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				}
			}
		}
	},
	--[[[mod.SPELLS.FINGER_OF_DEATH.KEY] = {
		CAST_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningYou"},
				WARNING_SHOW = {SPELL_CAST_START = {condition = DBM_BEHAVIOR.OnSelf}},
				PLAY_SOUND = {SPELL_CAST_START = {condition = DBM_BEHAVIOR.OnSelf, sound = "targetyou"}}
			}
		}
	},--]]
	[mod.SPELLS.PERMAFROST.KEY] = {
		DAMAGE_WARN = {
			DEFAULT = {
				TIMER = {type = "NewCDTimer", option_name = "Permafrost damage announcement"},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_SUCCESS = {}},
				WARNING = {type = "NewSpecialWarningGTFO", option_name = "Permafrost damage warning"},
				WARNING_SHOW = {
					SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}, 
					SPELL_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam}
				},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "watchfeet"}, 
					SPELL_MISSED = {condition = DBM_BEHAVIOR.OnSelfAntiSpam, sound = "watchfeet"}
				}
			}
		}
	},
	[mod.SPELLS.PRESENCE_OF_FROST.KEY] = {
		DEBUFF_TIMER = {
			DEFAULT = {
				TIMER = {type = "NewBuffFadesTimer",  icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Presence of Frost Debuff timer", color_type = 3},
				TIMER_STARTS = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.OnSelf}}
			}
		}
	},
	[mod.SPELLS.PRESENCE_OF_SHADOW.KEY] = {
		DEBUFF_TIMER = {
			DEFAULT = {
				TIMER = {type = "NewBuffFadesTimer",  icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Presence of Shadow Debuff timer", color_type = 3},
				TIMER_STARTS = {SPELL_AURA_APPLIED = {condition = DBM_BEHAVIOR.OnSelf}}
			}
		}
	},
	[mod.SPELLS.CHILL.KEY] = {
		DAMAGE_WARN = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningGTFO", option_name = "Blizzard damage announcement"},
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
	[mod.SPELLS.SHROUD_OF_DARKNESS.KEY] = {
		APPLIED_WARN = {
			DEFAULT = {
				TIMER = {type = "NewCDTimer", option_name = "Shroud of Darkness cooldown", color_type = 3},
				TIMER_STARTS = {ON_COMBAT_START = {inject = "offset"}, SPELL_CAST_SUCCESS = {}, SPELL_AURA_APPLIED_DOSE = {}},
				WARNING = {type = "NewSpecialWarningStack", stacks = 2, option_name = "Shroud of Darkness stack warning"},
				WARNING_SHOW = {
					SPELL_AURA_APPLIED_DOSE = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.amount > 2 and 
							       DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
						end,
						inject = "amount"
					}
				},
				PLAY_SOUND = {
					SPELL_AURA_APPLIED_DOSE = {
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.amount > 2 and 
							       DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
						end,
						sound = "stackhigh"
					}
				},
			}
		}
	},
	[DBM_BEHAVIOR.SPELL_UNKNOWN_KEY] = {
		WATER_ELEMENTAL_TIMER = {
			DEFAULT = {
				WARNING = {type = "NewSpecialWarningAdds", spell_id = 31687, option_name = "Warn Water Elementals spawn"},
				WARNING_SHOW = {
					MANUAL_NEW_ENTITY = {
						entity = "Water Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.entity ~= nil and
							       args.entity == "Water Elemental" and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				},
				PLAY_SOUND = {
					MANUAL_NEW_ENTITY = {
						entity = "Water Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.entity ~= nil and
							       args.entity == "Water Elemental" and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end,
						sound = "killmob"
					}
				},
				TIMER = {
					type = "NewCDTimer", spell_id = 31687, option_name = "Summon Water Elemental cooldown", color_type = 1
				},
				TIMER_STARTS = {
					ON_COMBAT_START = {inject = "offset"}, 
					MANUAL_NEW_ENTITY = {
						entity = "Water Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.entity ~= nil and
							       args.entity == "Water Elemental" and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				}
			}
		},
		DEATH_ELEMENTAL_TIMER = {
			DEFAULT = {
				TIMER = {type = "NewCDTimer", spell_id = 697, text = "Death Elemental", option_name = "Summon Death Elemental cooldown", color_type = 1},
				WARNING = {type = "NewSpecialWarningAdds", spell_id = 697, option_name = "Warn Death Elemental spawn"},
				WARNING_SHOW = {
					MANUAL_NEW_ENTITY = {
						entity = "Death Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.entity ~= nil and
							       args.entity == "Death Elemental" and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				},
				PLAY_SOUND = {
					MANUAL_NEW_ENTITY = {
						entity = "Death Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context)  
							return args.entity ~= nil and
							       args.entity == "Death Elemental" and
								   DBM_BEHAVIOR.IsTank(boss_mod, trigger_data, args, spell_id, update_subtype, context) and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end,
						sound = "mobout"
					}
				},
				TIMER_STARTS = {
					ON_COMBAT_START = {inject = "offset"}, 
					MANUAL_NEW_ENTITY = {
						entity = "Death Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
							return args.entity ~= nil and args.entity == "Death Elemental" and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				}
			}
		},
		DEATH_ELEMENTAL_EXPLOSION = {
			DEFAULT = {
				TIMER = {type = "NewCastTimer", spell_id = 9250064, icon = DBM_COMMON_L.DEADLY_ICON, option_name = "Death Elemental Explosion timer", color_type = 2},
				TIMER_STARTS = {		
					MANUAL_NEW_ENTITY = {
						entity = "Death Elemental",
						antispam_duration = 30,
						condition = function(boss_mod, trigger_data, args, spell_id, update_subtype, context) 
							return args.entity ~= nil and args.entity == "Death Elemental" and
								   DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
						end
					}
				}
			}
		}
	}
}

local boss_unit_id = "boss1"

function mod:OnCombatStart(delay)
	--Fetch difficulty from dbm
	DBM_BEHAVIOR.CombatStartFetchData(mod)
	DBM_BEHAVIOR.StartPhaseMonitor(mod, boss_unit_id)
	DBM_BEHAVIOR.StartNewEntityMonitor(mod)
	DBM_BEHAVIOR.HandleModelEvent("ON_COMBAT_START", mod, {offset=-delay})
end

function mod:OnCombatEnd(wipe)
    --Stop the monitors
	DBM_BEHAVIOR.StopNewEntityMonitor(mod)
	DBM_BEHAVIOR.StopPhaseMonitor(mod)
end


--Initialize the model
DBM_BEHAVIOR.CreateBossModel(mod)
DBM_BEHAVIOR.InitPhaseMonitor(mod, boss_unit_id, mod.MAX_PHASES)