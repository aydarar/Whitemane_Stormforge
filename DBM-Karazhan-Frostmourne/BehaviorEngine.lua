--Shared utility namespace for the DBM_Karazhan_Frostmourne module
DBM_BEHAVIOR = DBM_BEHAVIOR or {}

--Common flag for a disabled timer
DBM_BEHAVIOR.TIMER_DISABLED = 0
DBM_BEHAVIOR.SPELL_UNKNOWN_ID = 0
DBM_BEHAVIOR.SPELL_UNKNOWN_KEY = "UNKOWN"
DBM_BEHAVIOR.SPELL_UNKNOWN_NAME = "Unknown"

--Possible difficulties
DBM_BEHAVIOR.DIFFICULTY = {
	NORMAL_10 = "normal10",
	NORMAL_25 = "normal25",
	HEROIC_10 = "heroic10",
	HEROIC_25 = "heroic25"
}

--Possible difficulties pretty print format
DBM_BEHAVIOR.DIFFICULTY_PRETTY_PRINT = {
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_10] = "Normal 10",
	[DBM_BEHAVIOR.DIFFICULTY.NORMAL_25] = "Normal 25",
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_10] = "Heroic 10",
	[DBM_BEHAVIOR.DIFFICULTY.HEROIC_25] = "Heroic 25"
}

--Support boss phases upto 9
DBM_BEHAVIOR.PHASES = {
	PHASE_ONE = 1,	
	PHASE_TWO = 2,
	PHASE_THREE = 3,
	PHASE_FOUR = 4,
	PHASE_FIVE = 5,
	PHASE_SIX = 6,
	PHASE_SEVEN = 7,
	PHASE_EIGHT = 8,
	PHASE_NINE = 9
}

--Define some warning types for the behavior system
DBM_BEHAVIOR.WARNING_TYPE = {
	NewSpecialWarningDispel = "NewSpecialWarningDispel",
	NewSpecialWarningGTFO = "NewSpecialWarningGTFO",
	NewSpecialWarningYou = "NewSpecialWarningYou",
	NewSpecialWarningStack = "NewSpecialWarningStack",
	NewSpecialWarningLookAway = "NewSpecialWarningLookAway",
	NewSpecialWarningInterruptCount = "NewSpecialWarningInterruptCount",
	NewSpecialWarningMove = "NewSpecialWarningMove",
	NewSpecialWarning = "NewSpecialWarning",
	NewSpellAnnounce = "NewSpellAnnounce",
	NewSpecialWarningDefensive = "NewSpecialWarningDefensive",
	NewCastAnnounce = "NewCastAnnounce",
	NewSpecialWarningTaunt = "NewSpecialWarningTaunt",
	NewSpecialWarningAdds = "NewSpecialWarningAdds"
}

--Define some warning default parameters for the behavior system
DBM_BEHAVIOR.WARNING_CREATION_ARG_ORDER = {
	"text", "spell_id", "color", "icon", "filter", "stacks",
	"option_name", "option_version", "run_sound", 
	"has_voice", "difficulty"
}
DBM_BEHAVIOR.WARNING_DEFAULT_PARAMS = {
    NewSpecialWarningDispel = { spell_id = "", filter = "RemoveDisease", option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
    NewSpecialWarningGTFO = { spell_id = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 8 },
    NewSpecialWarningYou = { spell_id = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
    NewSpecialWarningStack = { spell_id = "", filter = true, stacks = 1, option_name = false, option_version = false, run_sound = 1, has_voice = 6 },
	NewSpecialWarningLookAway = { spell_id = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
	NewSpecialWarningInterruptCount = { spell_id = "", filter = "HasInterrupt", option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
	NewSpecialWarningMove = { spell_id = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
	NewSpecialWarning = { text = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
    NewSpellAnnounce = { spell_id = "", color = 3, icon = true, filter = ""},
	NewCastAnnounce = { spell_id = "", color = 3},
	NewSpecialWarningDefensive = {spell_id = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 2},
	NewSpecialWarningTaunt = {spell_id = "", filter = "Tank", option_name = false, option_version = false, run_sound = 1, has_voice = 2},
    NewSpecialWarningAdds = { spell_id = "", filter = true, option_name = false, option_version = false, run_sound = 1, has_voice = 2 },
}

--Define timer types for the behavior system
DBM_BEHAVIOR.TIMER_TYPE = {
	NewCDTimer = "NewCDTimer",
	NewBerserkTimer = "NewBerserkTimer",
	NewCastTimer = "NewCastTimer",
	NewBuffFadesTimer = "NewBuffFadesTimer"
}
--Define some warning default parameters for the behavior system
DBM_BEHAVIOR.TIMER_CREATION_ARG_ORDER = {
	"timing", "spell_id", "text", "option_default",
	"option_name", "color_type", "texture", "icon",
	"keep", "countdown", "countdown_max", "r", "g", "b",
	"requires_combat", "is_priority"
}
DBM_BEHAVIOR.TIMER_DEFAULT_PARAMS = {
    NewCDTimer = {timing = DBM_BEHAVIOR.TIMER_DISABLED, spell_id = "", text = false, option_default = true, option_name = false, color_type = 2, texture = false, icon = false},
	NewBerserkTimer = {timing = DBM_BEHAVIOR.TIMER_DISABLED},
	NewCastTimer = {timing = DBM_BEHAVIOR.TIMER_DISABLED, spell_id = "", text = false, option_default = true, option_name = false, color_type = 3, texture = false, icon = false},
	NewBuffFadesTimer = {timing = DBM_BEHAVIOR.TIMER_DISABLED, spell_id = "", text = false, option_default = true, option_name = false, color_type = 2, texture = false, icon = false}
}

DBM_BEHAVIOR.HANDLE_CATEGORIES = {"TIMER_STARTS", "SCAN_TRIGGER", "WARNING_SHOW", "PLAY_SOUND"}
--This table is for immidiate use, do not ever cache it
DBM_BEHAVIOR.EVENT_REUSE_TABLE = {}

--Known events fired internally start patterns
DBM_BEHAVIOR.INTERNAL_EVENTS = {
	ON_COMBAT_START = false, 
	ON_SCAN = false,
	PHASE_START_1 = false,
	PHASE_START_2 = false,
	PHASE_START_3 = false,
	PHASE_START_4 = false,
	PHASE_START_5 = false,
	PHASE_START_6 = false,
	PHASE_START_7 = false,
	PHASE_START_8 = false,
	PHASE_START_9 = false,
	MANUAL_CAST_MONITOR = false,
	MANUAL_NEW_ENTITY = false,
}

--Phase announcment sounds
DBM_BEHAVIOR.PHASE_ANNOUNCMENT_SOUND = {
	[DBM_BEHAVIOR.PHASES.PHASE_ONE] = "pone",
	[DBM_BEHAVIOR.PHASES.PHASE_TWO] = "ptwo",
	[DBM_BEHAVIOR.PHASES.PHASE_THREE] = "pthree",
	[DBM_BEHAVIOR.PHASES.PHASE_FOUR] = "pfour",
	[DBM_BEHAVIOR.PHASES.PHASE_FIVE] = "pfive",
	[DBM_BEHAVIOR.PHASES.PHASE_SIX] = "psix",
	[DBM_BEHAVIOR.PHASES.PHASE_SEVEN] = "pseven",
	[DBM_BEHAVIOR.PHASES.PHASE_EIGHT] = "peight",
	[DBM_BEHAVIOR.PHASES.PHASE_NINE] = "pnine",
}

--Give the update types ids
DBM_BEHAVIOR.UPDATE_SUBTYPE = {
	TIMER = 1,
	WARNING = 2,
	PLAY = 3
}

--Tie together the default arguments and behavior arguments
local function MakeBehaviourArgs(event, behavior_table, default_parameters, arg_order)
	local args = {}
	--Define like this so lua respects the ordering
	for _, name in ipairs(arg_order) do
		--Check if the call takes that argumetn
		if default_parameters[name] ~= nil then
			--Check if the default is overriden in behavior
			if behavior_table[name] ~= nil then
				table.insert(args, behavior_table[name])
			--Use the default value
			else
				table.insert(args, default_parameters[name])
			end
		end
	end
	return args
end

local function KeyOptionWithDifficulty(spell_behavior, difficulty)
	--If DEFAULT is created, there is only one instance of the spell
	if difficulty ~= "DEFAULT" and spell_behavior then
		local option_name = spell_behavior.option_name
		local difficulty_key = " (" .. DBM_BEHAVIOR.DIFFICULTY_PRETTY_PRINT[difficulty] .. ")"
		if option_name then
			spell_behavior.option_name = option_name .. difficulty_key
		end
	end
end

--Tries to create a warning based on the given behavior table
local function TryCreateDbmWarning(spell_behavior, spell_id, difficulty, boss_mod)
	local engine = DBM_BEHAVIOR
	local warning = spell_behavior.WARNING
	--Check the datas existence
	if warning ~= nil then
		local warning_type = warning.type
		local method = engine.WARNING_TYPE[warning_type]
		--Check type and methods existence ([nil]==nil)
		if method ~= nil then
			--Create the warning args, set the spell_id override
			KeyOptionWithDifficulty(warning, difficulty)
			warning.spell_id = warning.spell_id or spell_id
			local creation_args = MakeBehaviourArgs(
				warning_type, warning, 
				engine.WARNING_DEFAULT_PARAMS[warning_type], engine.WARNING_CREATION_ARG_ORDER
			)
			--Create the warning
			warning.DBM = boss_mod[method](boss_mod, unpack(creation_args))
		end
	end
end

--Tries to create a timer based on the given behavior table
local function TryCreateDbmTimer(spell_behavior, spell_id, difficulty, boss_mod)
	local engine = DBM_BEHAVIOR
	local timer = spell_behavior.TIMER
	--Check the datas existence
	if timer ~= nil then
		local timer_type = timer.type
		local method = engine.TIMER_TYPE[timer_type]
		--Check type and methods existence ([nil]==nil)
		if method ~= nil then
			--Create the timer args, set the spell_id override
			KeyOptionWithDifficulty(timer, difficulty)
			timer.spell_id = timer.spell_id or spell_id
			local creation_args = MakeBehaviourArgs(
				timer_type, timer, 
				engine.TIMER_DEFAULT_PARAMS[timer_type], engine.TIMER_CREATION_ARG_ORDER
			)
			--Create the timer
			timer.DBM = boss_mod[method](boss_mod, unpack(creation_args))
		end
	end
end

--Take the event argumentation and normalize them into one format
local function NormalizeArgumentation(event, ...)
	local args = ...
	if type(args) == "table" then
		return args
	end
	local _, event, _, destGUID, destName, _, spellId, spellName, spellSchool, amount = ...
	--3.3.5 LUA runs on single thread. This table is for immidiate use and not cached
	local reuse_table = DBM_BEHAVIOR.EVENT_REUSE_TABLE
	reuse_table.event = event
	reuse_table.destGUID = destGUID
	reuse_table.destName = destName
	reuse_table.amount = amount
	reuse_table.spellId = spellId
	reuse_table.spellName = spellName
	reuse_table.spellSchool = spellSchool
	return reuse_table
end

--Appends handlers to the boss mod for possible internal events
local function RegisterInternalDispatchers(boss_mod, trigger_name, encounter_spells, trigger_data, spell_id, difficulty, engine, utility)
	--Special case manual cast monitor
	if trigger_name == "MANUAL_CAST_MONITOR" and encounter_spells ~= nil then
		--Store the spell
		local spell_name = utility.SpellIdToName(encounter_spells, spell_id, difficulty)
		if spell_name ~= nil then
			boss_mod.cast_monitor_spells = boss_mod.cast_monitor_spells or {}
			boss_mod.cast_monitor_spells[spell_name] = true
		end
	--BossTargetscan function
	elseif trigger_name == "ON_SCAN" then
		local spell_scan_func = "ON_SCAN" .. spell_id
		--Attach the scan function to the boss_mod as requried by dbm
		boss_mod[spell_scan_func] = function(self, target_name)
			if target_name == self.player_name then
				engine.HandleModelUpdate(spell_id, "ON_SCAN", self, {destName = target_name})
			end
		end
	elseif trigger_name == "MANUAL_NEW_ENTITY" and trigger_data.entity ~= nil then
		boss_mod.entity_monitor_entities = boss_mod.entity_monitor_entities or {}
		boss_mod.entity_monitor_entities[trigger_data.entity] = true
	end
end

--Appends handlers for the Combatlog events coming from DBM
local function RegisterExternalDispatchers(boss_mod, trigger_name, internal_events, engine)
	local event_name = trigger_name
	local internal_event_lookup = internal_events[event_name]
	--Emote triggered event
	local emote_events = {
		CHAT_MSG_MONSTER_SAY = true,
		CHAT_MSG_MONSTER_YELL = true,
		CHAT_MSG_MONSTER_EMOTE = true,
		CHAT_MSG_RAID_BOSS_EMOTE = true,
		CHAT_MSG_RAID_BOSS_WHISPER = true
	}
	if boss_mod[event_name] == nil and emote_events[event_name] then
		boss_mod[event_name] = function(self, msg, npc, _, _, target)
			DBM_BEHAVIOR.HandleModelEvent(event_name, self, {message = msg, sender = npc, target = target})
		end
	--If internal event not blocked and boss mod doesnt have existing handle
	elseif boss_mod[event_name] == nil and internal_event_lookup ~= false then
		--Attach handlers to boss mod, capture trigger name as the events name
		boss_mod[event_name] = function(self, ...)
			local args = NormalizeArgumentation(event_name, ...)
			engine.HandleModelUpdate(args.spellId, event_name, self, args)
		end
	end
end

--Injects getters for dbm objects
local function InjectDBMAccessors(spell_behavior, spell_id, difficulty, boss_mod)
	--Getter for warning DBM
	spell_behavior.GetWarning = function()
		local warning = spell_behavior.WARNING
		if warning ~= nil then
			return warning.DBM
		end
	end
	--Getter for timer DBM
	spell_behavior.GetTimer = function()
		local timer = spell_behavior.TIMER
		if timer ~= nil then
			return timer.DBM
		end
	end
	--Show warning functionality
	spell_behavior.Show = function(...)
		local warning = spell_behavior.GetWarning()
		if warning then
			warning:Show(...)
		end
	end
	--Start timer functionality
	spell_behavior.Start = function(...)
		local timer = spell_behavior.GetTimer()
		if timer then
			timer:Start(...)
		end
	end
	--Stop timer functionality
	spell_behavior.Stop = function(...)
		local timer = spell_behavior.GetTimer()
		if timer then
			timer:Stop(...)
		end
	end
end

--Append handler functions to the dbm mod
local function RegisterBehaviorDispatchers(spell_behavior, spell_id, difficulty, boss_mod)
	local engine = DBM_BEHAVIOR
	local utility = DBM_KFU
	local handle_categories = engine.HANDLE_CATEGORIES
	local internal_events = engine.INTERNAL_EVENTS
	local encounter_spells = boss_mod.SPELLS
	--Inject getters
	InjectDBMAccessors(spell_behavior, spell_id, difficulty, boss_mod)
	--Run trough each handle containing category
	for _, category_name in ipairs(handle_categories) do
		local category = spell_behavior[category_name]
		if category ~= nil then
			--If we have the handle category in data, go trough it
			for trigger_name, trigger_data in pairs(category) do
				--Deal with combatlog events coming from dbm
				RegisterExternalDispatchers(boss_mod, trigger_name, internal_events, engine)
				--Deal with ON_SCAN and MANUAL_CAST_MONITOR
				RegisterInternalDispatchers(boss_mod, trigger_name, encounter_spells, trigger_data, spell_id, difficulty, engine, utility)
			end
		end
	end
end

--Appends the given spell to the look table spell_id => spell_key
local function AppendLookUps(boss_mod, spell_id, spell_key, context_name, event)
	--SPELL_ID => SPELL_KEY
	boss_mod.SPELL_LOOKUP = boss_mod.SPELL_LOOKUP or {}
	boss_mod.SPELL_LOOKUP[spell_id] = spell_key
	--SPELL_KEY,EVENT => CONTEXT NAME
	boss_mod.CONTEXT_LOOKUP = boss_mod.CONTEXT_LOOKUP or {}
	boss_mod.CONTEXT_LOOKUP[spell_key] = boss_mod.CONTEXT_LOOKUP[spell_key] or {}
	boss_mod.CONTEXT_LOOKUP[spell_key][event] = boss_mod.CONTEXT_LOOKUP[spell_key][event] or {}
	boss_mod.CONTEXT_LOOKUP[spell_key][event][context_name] = true
end

--Go trough the category and pull out event/spell id combos 
local function SolveRegistrationNeeds(
	category, spell_key, context_name, boss_mod, internal_events, registration_needs, loop_difficulties, utility
)
	--Go trough the categories events
	for event, _ in pairs(category) do 
		local has_handler = boss_mod[event] ~= nil
		local is_internal = internal_events[event] ~= nil
		--Go trough the possible spell difficulty levels
		for _, diff_index in ipairs(loop_difficulties) do
			local spell_id = utility.SpellKeyToId(boss_mod.SPELLS, spell_key, diff_index)
			--Do we have spell?
			if spell_id ~= nil then
				--Always populate run time look ups
				AppendLookUps(boss_mod, spell_id, spell_key, context_name, event)
				--Only populate DBM event handlers for Combatlog events, (Manual is internal)
				if has_handler and not is_internal then
					registration_needs[event] = registration_needs[event] or {}
					registration_needs[event][spell_id] = true
				end
			end
		end
	end
end

-- Register events automatically based on the behavior definitions
local function RegisterSpellEvents(boss_mod)
	local registration_needs = {}
	local engine = DBM_BEHAVIOR
	local utility = DBM_KFU
	local internal_events = engine.INTERNAL_EVENTS
	local handle_categories = engine.HANDLE_CATEGORIES
	local behavior_model = boss_mod.BEHAVIOR
	local loop_difficulties = {
		"DEFAULT",
		DBM_BEHAVIOR.DIFFICULTY.NORMAL_10,
		DBM_BEHAVIOR.DIFFICULTY.NORMAL_25,
		DBM_BEHAVIOR.DIFFICULTY.HEROIC_10,
		DBM_BEHAVIOR.DIFFICULTY.HEROIC_25
	}

	--Run trough the behavior model and pick out events and spell ids tied to them, [spell_key] => {SPELL_BEHAVIOR}
	for spell_key, behavior_array in pairs(behavior_model) do
		--Loop trough different contexes
		for context_name, spell_behavior in pairs(behavior_array) do
			-- Loop trough the potential difficulty specific behaviors, [DIFFICULTY] => {DBM_DETAILS}
			for difficulty, dbm_details in pairs(spell_behavior) do
				local difficulty_behavior = spell_behavior[difficulty]
				--Go trough each category holding events
				for _, category_name in ipairs(handle_categories) do
					local category = difficulty_behavior[category_name]
					if category ~= nil then
						--Pull out the Spellids/events. Register spells to key lookup
						SolveRegistrationNeeds(
							category, spell_key, context_name, boss_mod, internal_events, 
							registration_needs, loop_difficulties, utility
						)
					end
				end
			end
		end
	end
	--Generate registration strings
	local registration_strings = {}
	for event, spell_ids  in pairs(registration_needs) do
		local unique_spell_ids = {}
		for spell_id, _ in pairs(registration_needs[event]) do
			if spell_id ~= DBM_BEHAVIOR.SPELL_UNKNOWN_ID then
				table.insert(unique_spell_ids, spell_id)
			end
		end
		table.insert(registration_strings, utility.EventString(event, unpack(unique_spell_ids)))
	end
	--Register everything to DBM in one go
	boss_mod:RegisterEventsInCombat(unpack(registration_strings))
end

--Creates the dbm objects for the given settings
local function CreateBehavior(dbm_details, spell_id, difficulty, boss_mod)
	if spell_id ~= nil then 
		--Create warnings
		TryCreateDbmWarning(dbm_details, spell_id, difficulty, boss_mod)
		--Create timers
		TryCreateDbmTimer(dbm_details, spell_id, difficulty, boss_mod)
		--Append handlers to the mod
		RegisterBehaviorDispatchers(dbm_details, spell_id, difficulty, boss_mod)
	end
end

--Create the behaviors for the difficulty levels
local function CreateBehaviorForDifficulties(spell_behavior, boss_mod, spell_key)
	local utility = DBM_KFU
	local engine = DBM_BEHAVIOR
	local missing_behaviors = {}
	-- Loop trough the potential difficulty specific behaviors, [DIFFICULTY] => {DBM_DETAILS}
	for _, difficulty in pairs(engine.DIFFICULTY) do
		local dbm_details = spell_behavior[difficulty]
		local spell_id = utility.SpellKeyToId(boss_mod.SPELLS, spell_key, difficulty)
		--We have a valid difficult behavior override
		if dbm_details ~= nil then
			CreateBehavior(dbm_details, spell_id, difficulty, boss_mod)
		else
			missing_behaviors[difficulty] = true
		end
	end
	return missing_behaviors
end

--Expand the DEFAULT behavior per missing difficulty level
local function ExpandDefaultBehavior(missing_behaviors, spell_behavior, boss_mod, spell_key)
	local default_behavior = spell_behavior.DEFAULT
	--We need a default behavior to expand
	if default_behavior == nil then
		return
	end

	local utility = DBM_KFU
	local default_is_referenced = false
	local default_sid = utility.SpellKeyToId(boss_mod.SPELLS, spell_key)
	--Strat being to link to the default behavior, rather than creation
	for missing_diff, _ in pairs(missing_behaviors) do
		--Solve the spell id for this difficulty
		local spell_id = utility.SpellKeyToId(boss_mod.SPELLS, spell_key, missing_diff)
		if spell_id ~= default_sid then
			--Spell id and DBM are tied to together. We need new table to accomidate that
			spell_behavior[missing_diff] = utility.CopyTable(default_behavior)
			CreateBehavior(spell_behavior[missing_diff], spell_id, missing_diff, boss_mod)
		else
			--Link it to the default behavior
			default_is_referenced = true
			spell_behavior[missing_diff] = default_behavior
		end
	end
	--Did someone link to default behavior?
	if default_is_referenced then
		CreateBehavior(default_behavior, default_sid, "DEFAULT", boss_mod)
	end
end

--Create the boss model from the given behavior table
function DBM_BEHAVIOR.CreateBossModel(boss_mod)
	--Check if we can find data to create the model
	if boss_mod == nil then
		return
	end
	
	local utility = DBM_KFU
	local engine = DBM_BEHAVIOR
	local behavior_model = boss_mod.BEHAVIOR
	if behavior_model ~= nil then
		-- Loop trough per spell trough the behaviors table, [spell_key] => {SPELL_BEHAVIOR}
		for spell_key, behavior_array in pairs(behavior_model) do
			for context_name, spell_behavior in pairs(behavior_array) do
				--We need to create behavior for every difficulty that exists.
				--There is no load barrier when switching difficulties.
				--Create the "override" behaviors per difficulty
				local missing_behaviors = CreateBehaviorForDifficulties(
					spell_behavior, boss_mod, spell_key
				)
				--Expand the DEFAULT behavior per difficulty that does not have specific behavior override
				ExpandDefaultBehavior(missing_behaviors, spell_behavior, boss_mod, spell_key)
			end
		end
		--Register combat events
		RegisterSpellEvents(boss_mod)
	end
end

--Handle any triggering of timers
local function HandleTimerUpdate(spell_id, spell_mapping, behavior, event, boss_mod, context, args)
	local timer_data = behavior.TIMER
	local utility = DBM_KFU
	local start_events = behavior.TIMER_STARTS
	--Do we have a timer data?
	if timer_data == nil or start_events == nil then
		return
	end

	--Get DBM and timer start data
	local timer = timer_data.DBM
	local trigger_data = start_events[event]
	--Do we have timer and data for this event?
	if timer ~= nil and trigger_data ~= nil then
		--Has a override func been defined
		if trigger_data.override ~= nil then
			trigger_data.override(boss_mod, trigger_data, timer, args, context)
		--Accept the judgement of a condition func
		elseif 
			trigger_data.condition == nil or
			trigger_data.condition(boss_mod, trigger_data, args, spell_id, DBM_BEHAVIOR.UPDATE_SUBTYPE.TIMER, context)
		then
			local injection = args[trigger_data.inject] or 0
			--Try starting the timer
			utility.TryStartTimer(
				timer,
				utility.GetTiming(boss_mod.TIMINGS, boss_mod.difficulty, boss_mod.phase, spell_mapping, event, context),
				injection
			)
		end
	end
end

--Handle any triggering of warnings
local function HandleWarningUpdate(spell_id, spell_mapping, behavior, event, boss_mod, context, args)
	local warning_data = behavior.WARNING
	local show_events = behavior.WARNING_SHOW
	--Do we have warning data?
	if warning_data == nil or show_events == nil then
		return
	end

	--Get DBM and Show data
	local trigger_data = show_events[event]
	local warning = warning_data.DBM
	--Do we have dbm and data for this event
	if warning ~= nil and trigger_data ~= nil then
		--Has a override func been defined
		if trigger_data.override ~= nil then
			trigger_data.override(boss_mod, trigger_data, warning, args, context)
		--Accept the judgement of a condition func
		elseif 
			trigger_data.condition == nil or
			trigger_data.condition(boss_mod, trigger_data, args, spell_id, DBM_BEHAVIOR.UPDATE_SUBTYPE.WARNING, context)
		then
			--Show warning
			local injection = args[trigger_data.inject]
			warning:Show(injection)
		end
	end
end

--Handle any triggering of sounds
local function HandlePlayUpdate(spell_id, spell_mapping, behavior, event, boss_mod, context, args)
	local warning_data = behavior.WARNING
	local play_events = behavior.PLAY_SOUND
	--Do we have ability to play sound and event data
	if warning_data == nil or play_events == nil then
		return
	end
	--Get the DBM and play trigger data
	local warning = warning_data.DBM
	local trigger_data = play_events[event]
	--Do we have warning, data for this event and a sound file to play?
	if warning ~= nil and trigger_data ~= nil then
		local sound_id = trigger_data.sound
		if sound_id ~= nil then
			--Has a override func been defined
			if trigger_data.override ~= nil then
				trigger_data.override(boss_mod, trigger_data, warning, args, context)
			--Accept the judgement of a condition func
			elseif 
				trigger_data.condition == nil or
				trigger_data.condition(boss_mod, trigger_data, args, spell_id, DBM_BEHAVIOR.UPDATE_SUBTYPE.PLAY, context)
			then
				--Play the warning
				warning:Play(sound_id)
			end
		end
	end
end

--Handle any triggering of sounds
local function HandleScanTrigger(spell_id, spell_mapping, behavior, event, boss_mod, args)
	local scan_event_id = "ON_SCAN"
	local scan_triggers = behavior.SCAN_TRIGGER
	local source_guid = args.sourceGUID
	local engine = DBM_BEHAVIOR
	local scan_frequency = 0.25
	local scan_attempts = 15
	--Never loop and check if we have needed data
	if event == scan_event_id or scan_triggers == nil or source_guid == nil then
		return
	end

	--Get frequency data and start scanning
	local trigger_data = scan_triggers[event]
	--Check if we have indeed hit a event that requries scanning
	if trigger_data ~= nil then
		--Let behaviour override these if wanted
		scan_frequency = trigger_data.frequency or scan_frequency
		scan_attempts = trigger_data.scan_attempts or scan_attempts
		--Append spell scan func
		local spell_scan_func = scan_event_id .. spell_id
		--Start scanning
		boss_mod:BossTargetScanner(source_guid, spell_scan_func, scan_frequency, scan_attempts)
	end
end

--Handle boss model update
function DBM_BEHAVIOR.HandleModelUpdate(spell_id, event, boss_mod, args, spell_key)
	--Solve Spell_id and Spell_mapping (spell_key)
	spell_id = spell_id or DBM_KFU.SpellKeyToId(boss_mod.SPELLS, spell_key, boss_mod.difficulty)
	local spell_mapping = spell_key or boss_mod.SPELL_LOOKUP[spell_id]
	local spell_behaviors = boss_mod.BEHAVIOR[spell_mapping]
	--Solve the contexes that have the event in them
	local context_lookup = boss_mod.CONTEXT_LOOKUP[spell_mapping][event]
	--We have the data we need?
	if spell_behaviors == nil or context_lookup == nil then 
		return 
	end
	
	--Run trough the contexts
	for context_name, _ in pairs(context_lookup) do
		local spell_context = spell_behaviors[context_name]
		--Respect the difficulty overrides for behaviors
		local context_behavior = spell_context[boss_mod.difficulty] or spell_context["DEFAULT"]
		--Do we have a behavior defined for this spell?
		if context_behavior ~= nil then
			HandleTimerUpdate(spell_id, spell_mapping, context_behavior, event, boss_mod, context_name, args)
			HandleWarningUpdate(spell_id, spell_mapping, context_behavior, event, boss_mod, context_name, args)
			HandlePlayUpdate(spell_id, spell_mapping, context_behavior, event, boss_mod, context_name, args)
			HandleScanTrigger(spell_id, spell_mapping, context_behavior, event, boss_mod, args)
		end
	end
end

--Handle model event
function DBM_BEHAVIOR.HandleModelEvent(event, boss_mod, args)
	for spell_key, _ in pairs(boss_mod.BEHAVIOR) do
		DBM_BEHAVIOR.HandleModelUpdate(nil, event, boss_mod, args, spell_key)
	end
end

--Create phase warnings for possible phases
local function CreatePhasingDBM(boss_mod, max_phases)
	boss_mod.phase_warnings = {}
	local boss_name = DBM_KFU.GetBossName(boss_mod)
	local max_warnings = max_phases - 1
	--create max_phases-1 transit soon warnings
	for phase_id = 1, max_warnings do
		local option_name = boss_name .. ": Warn phase " .. (phase_id + 1) .. " soon"
		boss_mod.phase_warnings[phase_id] = boss_mod:NewPrePhaseAnnounce(phase_id + 1, nil, nil, nil, option_name)
	end
	--Create the phase announcer
	local option_name = boss_name .. ": Phase start warning"
	boss_mod.phase_announcer = boss_mod:NewPhaseAnnounce(2, 2, nil, nil, option_name, nil, nil, 2)
end

--Initialize the phase monitoring system
function DBM_BEHAVIOR.InitPhaseMonitor(boss_mod, boss_unit, max_phases)
	--Check that we have the required data
	if boss_mod.PHASE_TRANSITION_THRESHOLDS == nil then
		return
	end
	--Store boss unit id and create phase warnings
	boss_mod.boss_unit_id = boss_unit
	boss_mod.phase_warning_triggerd = false
	CreatePhasingDBM(boss_mod, max_phases)
	--Append the health functions to the boss mod
	if boss_mod.UNIT_HEALTH == nil then
		boss_mod.UNIT_HEALTH = function(self, uId)
			if uId == self.boss_unit_id then
				local utility = DBM_KFU
				local engine = DBM_BEHAVIOR
				local health_percentage = utility.GetUnitHealthPercentage(uId)
				if health_percentage then
					engine.ShouldTransitionPhase(self, health_percentage)
				end
			end
		end
	end
end

--Stop monitoring the phase changes
function DBM_BEHAVIOR.StopPhaseMonitor(boss_mod)
	--Stop the manual health monitor
	if boss_mod.boss_health_monitor then
		boss_mod.boss_health_monitor:Cancel()
	--Unregister UNIT_HEALTH
	else
		boss_mod:UnregisterShortTermEvents()
	end
end

--Starts the phase monitor
function DBM_BEHAVIOR.StartPhaseMonitor(boss_mod)
	--Required data exists?
	if boss_mod.PHASE_TRANSITION_THRESHOLDS == nil then
		return
	end
	--Start monitoring the phase
	local utility = DBM_KFU
	local engine = DBM_BEHAVIOR
	--If boss boss unit does not exists, the UNIT_HEALTH events wont fire
	if not UnitExists(boss_mod.boss_unit_id) then
		DBM_KFU.Debug("Monitoring boss health manually")
		--Work around the issue by doing manual health monitoring
		boss_mod.boss_health_monitor = utility.MonitorBossHealth(
			boss_mod.creatureId, function(health) engine.ShouldTransitionPhase(boss_mod, health) end
		)
	else
		--If boss unit exists we prefer to use the DBM system, register us to it
		boss_mod:RegisterShortTermEvents(
			utility.EventString("UNIT_HEALTH", boss_mod.boss_unit_id)
		)
	end
end

--Handles the logic of warning and transiting the phases
function DBM_BEHAVIOR.ShouldTransitionPhase(boss_mod, boss_health)
	local utility = DBM_KFU
	local engine = DBM_BEHAVIOR
	local treshold_table = boss_mod.PHASE_TRANSITION_THRESHOLDS
	--We need a treshold table
	if treshold_table == nil then
		return
	end

	--Get the phase specific section
	local transition_table = utility.GetTransitionThreshold(
		treshold_table, boss_mod.difficulty, boss_mod.phase
	)
	if transition_table ~= nil then
		local phase_warning = boss_mod.phase_warnings[boss_mod.phase]
		--Should we transition the phase?
		if boss_health <= transition_table.THRESHOLD then
			engine.TransitPhase(boss_mod, transition_table.NEXT, transition_table)
		--Should we give pre warning?
		elseif 
			transition_table.WARNING ~= nil and
			boss_health <= transition_table.WARNING and
			phase_warning ~= nil and
			not boss_mod.phase_warning_triggerd
		then
			boss_mod.phase_warning_triggerd = true
			phase_warning:Show()
			if transition_table.PLAY_WARNING == nil or
			   transition_table.PLAY_WARNING 
			then
				phase_warning:Play("nextphasesoon")
			end
		end
	end

end

--Handle the phase transitions
function DBM_BEHAVIOR.TransitPhase(boss_mod, next_phase, threshold_data)
	local engine = DBM_BEHAVIOR
	boss_mod.phase = next_phase
	boss_mod.phase_warning_triggerd = false
	if threshold_data.PLAY_ANNOUNCEMENT == nil or
	   threshold_data.PLAY_ANNOUNCEMENT
	then
		boss_mod.phase_announcer:Play(engine.PHASE_ANNOUNCMENT_SOUND[boss_mod.phase])
	end
	DBM_KFU.Debug("DBM_BEHAVIOR: Phase " .. boss_mod.phase)
	engine.HandleModelEvent("PHASE_START_" .. boss_mod.phase, boss_mod, {})
end

--Starts the manual spell casting monitor
function DBM_BEHAVIOR.StartNewEntityMonitor(boss_mod)
	--Do we have entities to monitor for?
	if boss_mod.entity_monitor_entities == nil then
		return
	end
	--Start the cast monitor	
	local utility = DBM_KFU
	local engine = DBM_BEHAVIOR
	boss_mod.new_entity_monitor = utility.MonitorNewEntities(
		boss_mod.creatureId, boss_mod.entity_monitor_entities,
		function(entity_name)
			engine.HandleModelEvent("MANUAL_NEW_ENTITY", boss_mod, {entity = entity_name})
		end
	)
end

--Stop the manual spell casting monitor
function DBM_BEHAVIOR.StopNewEntityMonitor(boss_mod)
	--Stop the manual entity monitor
	if boss_mod.new_entity_monitor then
		boss_mod.new_entity_monitor:Cancel()
	end
end

--Starts the manual spell casting monitor
function DBM_BEHAVIOR.StartSpellCastingMonitor(boss_mod)
	--Do we have spells to monitor for?
	if boss_mod.cast_monitor_spells == nil then
		return
	end
	--Start the cast monitor	
	local utility = DBM_KFU
	local engine = DBM_BEHAVIOR
	boss_mod.boss_casting_monitor = utility.MonitorBossCasting(
		boss_mod.creatureId, boss_mod.cast_monitor_spells,
		function(spell_name) 
			local spell_id = utility.SpellNameToId(boss_mod.SPELLS, spell_name, boss_mod.difficulty)
			if spell_id ~= nil then
				engine.HandleModelUpdate(spell_id, "MANUAL_CAST_MONITOR", boss_mod, {})
			end
		end
	)
end

--Stop the manual spell casting monitor
function DBM_BEHAVIOR.StopSpellCastingMonitor(boss_mod)
	--Stop the manual casting monitor
	if boss_mod.boss_casting_monitor then
		boss_mod.boss_casting_monitor:Cancel()
	end
end

--Get mission critical data for the fight
function DBM_BEHAVIOR.CombatStartFetchData(boss_mod)
	boss_mod.difficulty = DBM:GetCurrentInstanceDifficulty() or DBM_BEHAVIOR.DIFFICULTY.HEROIC_25
	boss_mod.phase = DBM_BEHAVIOR.PHASES.PHASE_ONE
	boss_mod.player_name = UnitName("player")
	boss_mod.player_guid = UnitGUID("player")
	boss_mod.player_can_kick = DBM_KFU.KnowsInteruptSpell()
	boss_mod.player_can_dispel = DBM_KFU.CanCleanseType("magic")
	boss_mod.player_can_decurse = DBM_KFU.CanCleanseType("curse")
	boss_mod.player_can_cleanse_disease = DBM_KFU.CanCleanseType("disease")
	boss_mod.player_can_cleanse_poison = DBM_KFU.CanCleanseType("poison")
end

--Common conditions, Are we a tank?
function DBM_BEHAVIOR.IsTank(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod:IsTank()
end

--Common conditions, Are we a healer?
function DBM_BEHAVIOR.IsHealer(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod:IsHealer()
end

--Common conditions, Are we a dps?
function DBM_BEHAVIOR.IsDps(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod:IsDps()
end

--Common conditions, Can we kick?
function DBM_BEHAVIOR.CanKick(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod.player_can_kick
end

--Common conditions, Can we dispell magic?
function DBM_BEHAVIOR.CanDispel(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod.player_can_dispel
end

--Common conditions, Do we not have ability to dispell?
function DBM_BEHAVIOR.CanNotDispel(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return not boss_mod.player_can_dispel
end

--Common conditions, Can we decurse?
function DBM_BEHAVIOR.CanDecurse(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod.player_can_decurse
end

--Common conditions, Can we dispell magic?
function DBM_BEHAVIOR.CanCleanseDisease(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod.player_can_cleanse_disease
end

--Common conditions, Can we dispell magic?
function DBM_BEHAVIOR.CanCleansePoison(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return boss_mod.player_can_cleanse_poison
end

--Common conditions, Are we either the target or source of the spell (Spells that bind two player together)
function DBM_BEHAVIOR.IsTargetOrDest(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return args.destGUID == boss_mod.player_guid or args.sourceGUID == boss_mod.player_guid
end

--Common conditions, Something happening to us
function DBM_BEHAVIOR.OnSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return args.destGUID == boss_mod.player_guid
end

--Common conditions, Something happening to us
function DBM_BEHAVIOR.NotOnSelfAndIsTank(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return args.destGUID ~= boss_mod.player_guid and boss_mod:IsTank()
end

--Common conditions, Something happening to us
function DBM_BEHAVIOR.DestIsSelf(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return args.destName == boss_mod.player_name
end

--Common conditions, DBM antispam
function DBM_BEHAVIOR.AntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	--Key the antispam with combo of spell_id + subtype
	local anti_spam_key = spell_id + update_subtype
	if context then
		anti_spam_key = context .. anti_spam_key
	end
	return boss_mod:AntiSpam(trigger_data.antispam_duration, anti_spam_key)
end

--Common conditions, Something happening to us and dbm antispam
function DBM_BEHAVIOR.OnSelfAntiSpam(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	--Key the antispam with combo of spell_id + subtype
	local anti_spam_key = spell_id + update_subtype
	if context then
		anti_spam_key = context .. anti_spam_key
	end
	return args.destGUID == boss_mod.player_guid and boss_mod:AntiSpam(trigger_data.antispam_duration, anti_spam_key)
end

--Common conditions, Checks if the stack amount exceeds the threshold
function DBM_BEHAVIOR.StackHigh(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return trigger_data.threshold ~= nil and
		   args.amount ~= nil and
		   args.amount >= trigger_data.threshold
end

--Common conditions, Checks if the stack amount exceeds the threshold
function DBM_BEHAVIOR.BossMessage(boss_mod, trigger_data, args, spell_id, update_subtype, context)
	return trigger_data.message ~= nil and
		   args.message ~= nil and
		   args.message:find(trigger_data.message)
end