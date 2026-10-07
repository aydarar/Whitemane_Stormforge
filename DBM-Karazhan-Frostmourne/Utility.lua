--Shared utility namespace for the DBM_Karazhan_Frostmourne module
DBM_KFU = DBM_KFU or {}

--Fetches the localized boss name
function DBM_KFU.GetBossName(boss_mod)
	return boss_mod:GetLocalizedStrings().name
end

--Solves the spells name from the spell table using its id
function DBM_KFU.SpellIdToName(spells, spell_id, difficulty)
	if spell_id == DBM_BEHAVIOR.SPELL_UNKNOWN_ID then return "Unkown" end
	local default_key = "DEFAULT"
	difficulty = difficulty or "DEFAULT"
	--Loop trough spell table until our spell hits
	if spells ~= nil then
		for spell_key, spell_data in pairs(spells) do
			local spell_id_data = spell_data.ID[difficulty] or spell_data.ID[default_key]
			if spell_id_data ~= nil and spell_id_data == spell_id then
				return spell_data.NAME
			end
		end
	end
	return nil
end

--Solves the spells id from the spell table using its name
function DBM_KFU.SpellNameToId(spells, spell_name, difficulty)
	local default_key = "DEFAULT"
	if spell_name == DBM_BEHAVIOR.SPELL_UNKNOWN_NAME then return DBM_BEHAVIOR.SPELL_UNKNOWN_ID end
	difficulty = difficulty or default_key
	--Loop trough spell table until our spell hits
	if spells ~= nil then
		for spell_key, spell_data in pairs(spells) do
			if spell_data.NAME == spell_name then
				return spell_data.ID[difficulty] or spell_data.ID[default_key] 
			end
		end
	end
	return nil
end

--Solves the spells id from the spell table using its name
function DBM_KFU.SpellKeyToId(spells, spell_key, difficulty)
	local default_key = "DEFAULT"
	if spell_key == DBM_BEHAVIOR.SPELL_UNKNOWN_KEY then return DBM_BEHAVIOR.SPELL_UNKNOWN_ID end
	difficulty = difficulty or default_key
	--Loop trough spell table until our spell hits
	if spells ~= nil then
		for _, spell_data in pairs(spells) do
			if spell_data.KEY == spell_key then
				return spell_data.ID[difficulty] or spell_data.ID[default_key] 
			end
		end
	end
	return nil
end

--Helper function for retrieving transition data
function DBM_KFU.GetTransitionThreshold(transition_table, difficulty, phase)
	if transition_table ~= nil and transition_table[difficulty] ~= nil then
		--See if the phase has a specific override table
		if transition_table[difficulty][phase] ~= nil then
			return transition_table[difficulty][phase]
		--See if we have a fallback default phase table
		elseif 
			transition_table[difficulty]["TRANSITION_DEFAULT"] ~= nil and
			transition_table[difficulty]["TRANSITION_DEFAULT"][phase] ~= nil 
		then
			return transition_table[difficulty]["TRANSITION_DEFAULT"][phase]
		end
	end
	--If we can't find the ability in current difficulty/phase setting then mark it as disabled
	return nil
end

--Helper to build the event string
function DBM_KFU.EventString(event_name, ...)
	--Set everything in table
	local parts = {event_name}
	for i = 1, select("#", ...) do
		table.insert(parts, tostring(select(i, ...)))
	end
	-- Concat the table
	return table.concat(parts, " ")
end

--Helper function for retrieving timers
function DBM_KFU.GetTiming(timing_table, difficulty, phase, ability, event, context)
	local difficulty_table = timing_table[difficulty]
	--Do we have difficulty level info?
	if difficulty_table ~= nil then
		local phase_table = difficulty_table[phase] or difficulty_table.PHASE_DEFAULT
		--What about phase level?
		if phase_table ~= nil then
			local ability_table = phase_table[ability]
			--Does the ability have timings here?
			if ability_table ~= nil then
				local context_table = ability_table[context]
				--Is there context level settings?
				if context_table ~= nil then
					return context_table[event] or context_table.DEFAULT
				end
				--Prefer event specific timings over default
				return ability_table[event] or ability_table.DEFAULT
			end
		end
	end
	--If we can't find the ability in current difficulty/phase setting then mark it as disabled
	return DBM_KFU.TIMER_DISABLED
end

--Helper function to start timers if possible, respects the DISABLED value
function DBM_KFU.TryStartTimer(timer_obj, timing, offset)
	if timer_obj ~= nil and type(timer_obj.Start) == "function" and timing ~= DBM_KFU.TIMER_DISABLED then
		timer_obj:Start(timing + (offset or 0))
	end
end

--Attempts to get the units health as a percentage of its total health
function DBM_KFU.GetUnitHealthPercentage(unit)
	local health = nil
	if UnitExists(unit) then
		health = UnitHealth(unit) / UnitHealthMax(unit) * 100
	end
	return health
end

--Attempts to get the units health as a percentage of its total health
function DBM_KFU.GetUnitCastingSpellName(unit)
	local spell_name = nil
	if UnitExists(unit) then
		--Preferably we would get the id, but 3.3.5 api doesn't allow for that
		spell_name = select(1, UnitCastingInfo(unit))
	end
	return spell_name
end

--Helper to try to find the unit of the given creature id
function DBM_KFU.FindBossUnitFromTargeting(creature_id)
	local unit_checks = { "boss1", "boss2", "boss3", "boss4", "boss5", "focus", "target"}
	for _, unit in ipairs(unit_checks) do
		if UnitExists(unit) and DBM:GetUnitCreatureId(unit) == creature_id then
			return unit
		end
	end
	return nil
end

--Create and Get a storage block for the given creatureid
local function GetStorageForCreature(creature_id, storage_bucket_id)
	DBM_KFU.storage = (DBM_KFU.storage or {})
	DBM_KFU.storage[creature_id] = (DBM_KFU.storage[creature_id] or {})
	DBM_KFU.storage[creature_id][storage_bucket_id] = (DBM_KFU.storage[creature_id][storage_bucket_id] or {})
	return DBM_KFU.storage[creature_id][storage_bucket_id]
end

--Reset a monitor object
local function ResetMonitor(monitor_obj)
	if monitor_obj then
		--Cancel previous timers
		if monitor_obj.timer_obj then
			monitor_obj.timer_obj:Cancel()
			monitor_obj.timer_obj = nil
		end
		--Zero the data
		monitor_obj.unit = nil
		monitor_obj.count = 0
		monitor_obj.found = nil
	end
end

--Manual function for polling boss health, based on timer
local function FindAndGetHealth(creature_id, storage, callback_func, max_attempts)
	max_attempts = max_attempts or 60
	if storage.unit == nil then
		storage.unit = DBM_KFU.FindBossUnitFromTargeting(creature_id)
		storage.count = (storage.count or 0) + 1
		--Check if we should cancel the search
		if storage.count > max_attempts and storage.timer_obj then
			DBM_KFU.Debug("Manual boss health monitoring failed!")
			storage.timer_obj:Cancel()
		end
	-- If the unit is say target, we may end up in a scenario where the unit is not the boss
	elseif DBM:GetUnitCreatureId(storage.unit) == creature_id then
		--If we have unit get its health and give it to the callback func
		local health_percentage = DBM_KFU.GetUnitHealthPercentage(storage.unit)
		if health_percentage then
			callback_func(health_percentage)
			--If boss is dead, cancel the health monitor
			if(health_percentage <= 0) then
				storage.timer_obj:Cancel()
			end
		end
	end
end

function DBM_KFU.CopyTable(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = DBM_KFU.CopyTable(v)
    end
    return copy
end

--Access point to the manual boss health monitoring
function DBM_KFU.MonitorBossHealth(creature_id, callback_func, freaquency)
	freaquency = freaquency or 0.5
	--Get storage and reset any previous monitors
	local storage = GetStorageForCreature(creature_id, "health_monitor")
	ResetMonitor(storage)
	storage.timer_obj = C_Timer.NewTicker(
		freaquency, 
		function()
			FindAndGetHealth(creature_id, storage, callback_func)
		end
	)
	--Return handle for the mod
	return storage.timer_obj
end

--Manually monitor what spells the boss is casting
local function FindAndMonitorCasting(creature_id, spell_names, storage, callback_func, max_attempts)
	max_attempts = max_attempts or 60
	--Try to find the unit
	if storage.unit == nil then
		storage.unit = DBM_KFU.FindBossUnitFromTargeting(creature_id)
		storage.count = (storage.count or 0) + 1
		--Check if we should cancel the search
		if storage.count > max_attempts and storage.timer_obj then
			DBM_KFU.Debug("Manual boss casting monitoring failed!")
			storage.timer_obj:Cancel()
		end
	-- If the unit is say target, we may end up in a scenario where the unit is not the boss
	elseif DBM:GetUnitCreatureId(storage.unit) == creature_id then
		--If we have unit get its casting info and call the callback
		local spell_name = DBM_KFU.GetUnitCastingSpellName(storage.unit)
		if spell_names and spell_names[spell_name] then
			callback_func(spell_name)
		end
	end
end

--Access point to the manual boss casting monitoring
function DBM_KFU.MonitorBossCasting(creature_id, spell_names, callback_func, freaquency)
	freaquency = freaquency or 1
	--Get storage and stop any previous timers
	local storage = GetStorageForCreature(creature_id, "casting_monitor")
	ResetMonitor(storage)
	storage.timer_obj = C_Timer.NewTicker(
		freaquency, 
		function()
			FindAndMonitorCasting(creature_id, spell_names, storage, callback_func)
		end
	)
	--Return handle for the mod
	return storage.timer_obj
end

--Manually monitor what entities exists around us
local function FindAndMonitorEntities(entity_names, storage, callback_func)
	local found = storage.found
	--Loop all the nameplates
	for _, plate in ipairs(DBM_KFU.NAMEPLATE_ENTITIES) do
		--If entity exists and not cached
		if UnitExists(plate) then
			local unit_name = UnitName(plate)
			if found[plate] ~= unit_name then
				--See if entity in our search list
				if entity_names[unit_name] ~= nil then
					--Good hit, callback
					found[plate] = unit_name
					callback_func(unit_name)
				else
					found[plate] = nil
				end 
			end
		--If not found remove old entries
		else
			found[plate] = nil
		end
	end
end

--Access point to the manual entity scanning
function DBM_KFU.MonitorNewEntities(creature_id, entity_names, callback_func, freaquency)
	DBM_KFU.NAMEPLATE_ENTITIES = {
			"nameplate1", "nameplate2", "nameplate3", "nameplate4",
			"nameplate5", "nameplate6", "nameplate7", "nameplate8",
			"nameplate9", "nameplate10", "nameplate11", "nameplate12",
			"nameplate13", "nameplate14", "nameplate15", "nameplate16",
			"nameplate17", "nameplate18", "nameplate19", "nameplate20",
			"nameplate21", "nameplate22", "nameplate23", "nameplate24", 
			"nameplate25", "nameplate26", "nameplate27", "nameplate28", 
			"nameplate29", "nameplate30", "nameplate31", "nameplate32", 
			"nameplate33", "nameplate34", "nameplate35", "nameplate36",
			"nameplate37", "nameplate38", "nameplate39", "nameplate40"
		}
	freaquency = freaquency or 1
	--Get storage and stop any previous timers
	local storage = GetStorageForCreature(creature_id, "entity_monitor")
	ResetMonitor(storage)
	storage.found = {}
	storage.timer_obj = C_Timer.NewTicker(
		freaquency, 
		function()
			FindAndMonitorEntities(entity_names, storage, callback_func)
		end
	)
	--Return handle for the mod
	return storage.timer_obj
end

--Debug function layer over dbm debug to accept multiple parameters
function DBM_KFU.Debug(...)
    local args = {...}
    local parts = {}
    for i = 1, #args do
        parts[#parts + 1] = tostring(args[i])
    end
    local msg = table.concat(parts, " ")
    DBM:Debug(msg)
end

DBM_KFU.INTERUPT_SPELLS = {
	[1766] = true,--Rogue Kick
	[2139] = true,--Mage Counterspell
	[6552] = true,--Warrior Pummel
	[15487] = true,--Priest Silence
	[19647] = true,--Warlock pet Spell Lock
	[47528] = true,--Death Knight Mind Freeze
	[49377] = true,--Druid Feral Charge
	[57994] = true,--Shaman Wind Shear
}
--Checks if the current player know any of the interupt spells
function DBM_KFU.KnowsInteruptSpell()
	--Check all interupt spells
	for spell_id, _ in pairs(DBM_KFU.INTERUPT_SPELLS) do
		if IsSpellKnown(spell_id) then
			return true
		end
	end
	return false
end

--Joink'd from core but we gonna make it useful
DBM_KFU.CLEANSE_SPELLS = {
	["magic"] = {
		[527] = true,--Priest: Dispel Magic (Magic and Disease)
		[32375] = true,--Priest: Mass Dispel (Magic and Disease)
		[4987] = true,--Paladin: Cleanse (Magic, Poison and Disease)
		[77130] = true,--Shaman: Purify Spirit (Magic and Curse)
	},
	["curse"] = {
		[2782] = true,--Druid: Remove Curse (Curse and Poison)
		[51886] = DBM:IsHealer() and true,--Shaman: Cleanse Spirit (Curse, Poison and Disease)
		[475] = true,--Mage: Remove Curse (Curse)
	},
	["poison"] = {
		[2782] = true,--Druid: Remove Corruption (Curse and Poison)
		[2893] = true,--Druid: Abolish Poison (Poison)
		[8946] = true,--Druid: Cure Poison (Poison)
		[1152] = true,--Paladin: Purify (Poison and Disease)
		[4987] = true,--Paladin: Cleanse (Magic, Poison and Disease)
		[526] = true,--Shaman: Cure Toxins (Poison and Disease)
		[51886] = DBM:IsHealer() and true,--Shaman: Cleanse Spirit (Curse, Poison and Disease)
	},
	["disease"] = {
		[527] = true,--Priest: Dispel Magic (Magic and Disease)
		[528] = true,--Priest: Cure Disease (Disease)
		[552] = true,--Priest: Abolish Disease (Disease)
		[32375] = true,--Priest: Mass Dispel (Magic and Disease)
		[1152] = true,--Paladin: Purify (Poison and Disease)
		[4987] = true,--Paladin: Cleanse (Magic, Poison and Disease)
		[526] = true,--Shaman: Cure Toxins (Poison and Disease)
		[51886] = DBM:IsHealer() and true,--Shaman: Cleanse Spirit (Curse, Poison and Disease)
	},
}

-- Checks if the current player knows any decurse spells
function DBM_KFU.CanCleanseType(type)
	if type ~= nil and DBM_KFU.CLEANSE_SPELLS[type] ~= nil then
		for spell_id, enabled in pairs(DBM_KFU.CLEANSE_SPELLS[type]) do
			if enabled and IsSpellKnown(spell_id) then
				return true
			end
		end
	end
	return false
end