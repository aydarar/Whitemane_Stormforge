local mod	= DBM:NewMod("Malygos", "DBM-EyeOfEternity")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(28859)
mod:SetEncounterID(734)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

--mod:RegisterCombat("yell", L.YellPull)
mod:RegisterCombat("combat")
mod:SetWipeTime(45)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 60936 57407 9250851 9250852",
	"SPELL_CAST_START 56505",
	"SPELL_CAST_SUCCESS 57430",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)
-- General
local enrageTimer				= mod:NewBerserkTimer(615)
local timerAchieve				= mod:NewAchievementTimer(360, 1875)

-- Stage One
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(1))
local warnSummonPowerSpark		= mod:NewSpellAnnounce(56140, 2, 59381)
local warnVortex				= mod:NewSpellAnnounce(56105, 3)
local warnVortexSoon			= mod:NewSoonAnnounce(56105, 2)

local timerSummonPowerSpark		= mod:NewNextTimer(21, 56140, nil, nil, nil, 1, 59381, DBM_COMMON_L.DAMAGE_ICON)
local timerVortex				= mod:NewCastTimer(13.5, 56105, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerVortexCD				= mod:NewNextTimer(78, 56105, nil, nil, nil, 2)

-- Stage Two
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(2))
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnBreathInc				= mod:NewSoonAnnounce(56505, 3)

local specWarnBreath			= mod:NewSpecialWarningSpell(56505, nil, nil, nil, 2, 2)

local timerBreath				= mod:NewBuffActiveTimer(8, 56505, nil, nil, nil, 5) --lasts 5 seconds plus 3 sec cast.
local timerBreathCD				= mod:NewCDTimer(70, 56505, nil, nil, nil, 2)
local timerIntermission			= mod:NewPhaseTimer(22)

-- Stage Three
mod:AddTimerLine(DBM_CORE_L.SCENARIO_STAGE:format(3))
local warnPhase3				= mod:NewPhaseAnnounce(3)
local warnSurge					= mod:NewTargetAnnounce(60936, 3)
local warnStaticField			= mod:NewTargetNoFilterAnnounce(57430, 3)

local specWarnSurge				= mod:NewSpecialWarningDefensive(60936, nil, nil, nil, 1, 2)
local specWarnP3SurgeOfPowerSoon= mod:NewSpecialWarningYou(60936, nil, nil, nil, 1, 2)
local specWarnStaticField		= mod:NewSpecialWarningYou(57430, nil, nil, nil, 1, 2)
local specWarnStaticFieldNear	= mod:NewSpecialWarningClose(57430, nil, nil, nil, 1, 2)
local yellStaticField			= mod:NewYellMe(57430)

local timerStaticFieldCD		= mod:NewCDTimer(14, 57430, nil, nil, nil, 3, nil, nil, true)
--local timerAttackable			= mod:NewTimer(24, "Malygos Wipes Debuffs") -- Not enough info nor locales on the code from previous contributor to know what this is intended for. Disabled for now
local specWarnArcaneBreath		= mod:NewSpecialWarningMoveAway(9250852, nil, nil, nil, 1, 2)

local tableBuild = false
local guids = {}

local yell_Vortex = "Watch helplessly as your hopes are swept away..."
local nextVortex = 0
local syncSpam = 1

mod:AddSetIconOption("SparkIcons", 9250852, true, 5, {8})
mod.vb.SparkIcon = 8

mod:AddSetIconOption("ArcaneBreathIcons", 9250852, true, 5, {1, 2, 3, 4, 5, 6, 7})
mod.vb.ArcaneBreathIcon = 1

mod:AddRangeFrameOption(12, 9250852)

local function buildGuidTable()
	table.wipe(guids)
	for uId in DBM:GetGroupMembers() do
		local name, server = UnitName(uId)
		local fullName = name .. (server and server ~= "" and ("-" .. server) or "")
		guids[UnitGUID(uId.."pet") or "none"] = fullName
	end
	tableBuild = true
end

function mod:OnCombatStart(delay)
	nextVortex = GetTime()+37-delay
	tableBuild = false
	self:SetStage(1)
	enrageTimer:Start(-delay)
	timerAchieve:Start(-delay)
	timerVortexCD:Start(38-delay)
	timerSummonPowerSpark:Start(19-delay)
	table.wipe(guids)
	self.vb.ArcaneBreathIcon = 1
	mod.vb.SparkIcon = 8
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(60936, 57407) then
		DBM:Debug("SURGE" .. guids[args.destGUID], 2)
		local target = guids[args.destGUID or 0]
		if target then
			warnSurge:CombinedShow(0.5, target)
			if target == UnitName("player") then
				specWarnSurge:Show()
				specWarnSurge:Play("defensive")
			end
		end
	elseif args:IsSpellID(9250851, 9250852) then
		if self.Options.ArcaneBreathIcons then
			self:SetIcon(args.destName, self.vb.ArcaneBreathIcon)
		end
		self.vb.ArcaneBreathIcon = self.vb.ArcaneBreathIcon + 1
		if args:IsPlayer() then			
			specWarnArcaneBreath:Show()
			specWarnArcaneBreath:Play("bombrun")	
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(12)
		end				
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 56505 then--His deep breath
		specWarnBreath:Show()
		specWarnBreath:Play("findshield")
		timerBreath:Start()
		timerBreathCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 57430 then -- Static Field
		if not tableBuild then
			buildGuidTable()
		end
		
		local announcetarget = guids[args.destGUID]
		if announcetarget == UnitName("player") then
			specWarnStaticField:Show()
			specWarnStaticField:Play("runaway")
			yellStaticField:Yell()
		elseif announcetarget and self:CheckNearby(13, announcetarget) and self:AntiSpam(0.5, "SField") then
			specWarnStaticFieldNear:Show(announcetarget)
			specWarnStaticFieldNear:Play("runaway")
		else
			warnStaticField:Show(announcetarget)
		end
		
		timerStaticFieldCD:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	--Secondary pull trigger, so we can detect combat when he's pulled while already in combat (which is about 99% of time)
	if (msg == L.YellPull or msg:find(L.YellPull)) and not self:IsInCombat() then
		DBM:StartCombat(self, 0)
	elseif msg == yell_Vortex or msg:find(yell_Vortex) then
		self:SendSync("Vortex") -- Syncing to help unlocalized clients
	elseif msg:sub(0, L.YellPhase2:len()) == L.YellPhase2 then
		self:SendSync("Phase2")
	elseif msg == L.YellBreath or msg:find(L.YellBreath) then
		self:SendSync("BreathSoon")
	elseif msg:sub(0, L.YellPhase3:len()) == L.YellPhase3 then
		self:SendSync("Phase3")
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg,sourceName)
	if msg == L.EmoteSpark or msg:find(L.EmoteSpark) then
		self:SendSync("Spark")
	elseif msg == L.EmoteSurge or msg:find(L.EmoteSurge) or msg == L.EmoteSurge:gsub("%%s", sourceName) then -- emote isn't working quite right on Whitemane PTR, using another method
		self:SendSync("MalygosSurge", UnitName("player"), syncSpam)
		syncSpam = syncSpam % 2 + 1 -- dummy alternating arg to bypass DBM's 8-second sync antispam (hardcoded in :SendSync()). needed as Surge happens more often than that on Whitemane PTR
	end
end

function mod:OnSync(event, arg)
	if not self:IsInCombat() then return end
	if event == "Spark" then
		warnSummonPowerSpark:Show()
		self:ScanForMobs(30084, 20, self.vb.SparkIcon , 1, nil, 8, "SparkIcons")
		local t = GetTime()
		if t+21 >= nextVortex then
			timerSummonPowerSpark:Start(nextVortex+33-t)
		else
			timerSummonPowerSpark:Start()
		end
	elseif event == "Vortex" then
		timerVortexCD:Start()
		warnVortexSoon:Schedule(75)
		warnVortex:Show()
		timerVortex:Start()
		nextVortex = GetTime()+80
	elseif event == "Phase2" then
		self:SetStage(2)
		timerSummonPowerSpark:Cancel()
		timerVortexCD:Cancel()
		warnVortexSoon:Cancel()
		warnPhase2:Show()
		timerIntermission:Start()
		timerBreathCD:Start(78)
	elseif event == "BreathSoon" then
		warnBreathInc:Show()
	elseif event == "Phase3" then
		self:SetStage(3)
		warnPhase3:Show()
		self:Schedule(6, buildGuidTable)
		timerBreathCD:Cancel()
		timerStaticFieldCD:Start(13)
	elseif event == "MalygosSurge" then
		warnSurge:CombinedShow(0.2, arg)
		if arg == UnitName("player") then
			specWarnP3SurgeOfPowerSoon:Show()
			specWarnP3SurgeOfPowerSoon:Play("findshield")
		end
	end
end
