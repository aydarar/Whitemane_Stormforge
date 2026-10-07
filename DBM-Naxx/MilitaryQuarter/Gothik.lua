local mod	= DBM:NewMod("Gothik", "DBM-Naxx", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(16060)
mod:SetEncounterID(1109)
mod:SetUsedIcons(1, 2, 3, 4)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 9250699 9250700",
	"SPELL_AURA_APPLIED 9250699 9250700",
	"SPELL_AURA_REMOVED 9250699 9250700",	
	"UNIT_DIED",
	"UNIT_HEALTH_UNFILTERED"
)

--TODO, sync infoframe from classic era version?
--(source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
local warnWaveNow		= mod:NewAnnounce("WarningWaveSpawned", 3, nil, false)
local warnWaveSoon		= mod:NewAnnounce("WarningWaveSoon", 2)
local warnRiderDown		= mod:NewAnnounce("WarningRiderDown", 4)
local warnKnightDown	= mod:NewAnnounce("WarningKnightDown", 2)
local warnPhase2		= mod:NewPhaseAnnounce(2, 3)
local warnLowHP			= mod:NewAnnounce("WarnGothikLow", 2)

local timerPhase2		= mod:NewTimer(270, "TimerPhase2", 27082, nil, nil, 6)
local timerWave			= mod:NewTimer(20, "TimerWave", 5502, nil, nil, 1)
local timerGate			= mod:NewTimer(150, "Gate Opens", 9484)
local timerTeleport		= mod:NewTimer(25, "TimerTeleport", 31569)
local specWarnShadowDebuff = mod:NewSpecialWarningYou(9250700, nil, nil, nil, 1, 2)

local timerNextDebuff	= mod:NewCDTimer(30, 9250700, nil, nil, nil, 5)

mod:AddSetIconOption("SoulConvergenceIcons", 9250700, true, 5, {1, 2, 3, 4})
mod.vb.SoulConvergenceIcon = 1

local warned_lowhp = false
mod.vb.wave = 0
local wavesNormal = {
	{2, L.Trainee, timer = 20},
	{2, L.Trainee, timer = 20},
	{2, L.Trainee, timer = 10},
	{1, L.Knight, timer = 10},
	{2, L.Trainee, timer = 15},
	{1, L.Knight, timer = 5},
	{2, L.Trainee, timer = 20},
	{1, L.Knight, 2, L.Trainee, timer = 10},
	{1, L.Rider, timer = 10},
	{2, L.Trainee, timer = 5},
	{1, L.Knight, timer = 15},
	{2, L.Trainee, 1, L.Rider, timer = 10},
	{2, L.Knight, timer = 10},
	{2, L.Trainee, timer = 10},
	{1, L.Rider, timer = 5},
	{1, L.Knight, timer = 5},
	{2, L.Trainee, timer = 20},
	{1, L.Rider, 1, L.Knight, 2, L.Trainee, timer = 15},
	{2, L.Trainee},
}

local wavesHeroic = {
	{3, L.Trainee, timer = 20},
	{3, L.Trainee, timer = 20},
	{3, L.Trainee, timer = 10},
	{2, L.Knight, timer = 10},
	{3, L.Trainee, timer = 15},
	{2, L.Knight, timer = 5},
	{3, L.Trainee, timer = 20},
	{3, L.Trainee, 2, L.Knight, timer = 10},
	{3, L.Trainee, timer = 10},
	{1, L.Rider, timer = 5},
	{3, L.Trainee, timer = 15},
	{1, L.Rider, timer = 10},
	{2, L.Knight, timer = 10},
	{1, L.Rider, timer = 10},
	{1, L.Rider, 3, L.Trainee, timer = 5},
	{1, L.Knight, 3, L.Trainee, timer = 5},
	{1, L.Rider, 3, L.Trainee, timer = 20},
	{1, L.Rider, 2, L.Knight, 3, L.Trainee},
}

local waves = wavesNormal

local function StartPhase2(self)
	self:SetStage(2)
	if self:IsDifficulty("normal25") then
		timerTeleport:Start()
	else
		timerTeleport:Start(20)
	end
end

local function getWaveString(wave)
	local waveInfo = waves[wave]
	if #waveInfo == 2 then
		return L.WarningWave1:format(unpack(waveInfo))
	elseif #waveInfo == 4 then
		return L.WarningWave2:format(unpack(waveInfo))
	elseif #waveInfo == 6 then
		return L.WarningWave3:format(unpack(waveInfo))
	end
end

local function NextWave(self)
	self.vb.wave = self.vb.wave + 1
	warnWaveNow:Show(self.vb.wave, getWaveString(self.vb.wave))
	local timer = waves[self.vb.wave].timer
	if timer then
		timerWave:Start(timer, self.vb.wave + 1)
		warnWaveSoon:Schedule(timer - 3, self.vb.wave + 1, getWaveString(self.vb.wave + 1))
		self:Schedule(timer, NextWave, self)
	end
end

function mod:OnCombatStart()
	self:SetStage(1)
	if self:IsDifficulty("normal25","heroic25","heroic10") then
		waves = wavesHeroic
	else
		waves = wavesNormal
	end
	self.vb.wave = 0
	timerGate:Start()
	timerPhase2:Start()
	warnPhase2:Schedule(270)
	timerWave:Start(25, self.vb.wave + 1)
	warnWaveSoon:Schedule(22, self.vb.wave + 1, getWaveString(self.vb.wave + 1))
	self:Schedule(25, NextWave, self)
	self:Schedule(270, StartPhase2, self)
	timerNextDebuff:Start()
	self.vb.SoulConvergenceIcon = 1 
end

function mod:OnTimerRecovery()
	if self:IsDifficulty("normal25") then
		waves = wavesHeroic
	else
		waves = wavesNormal
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(9250699,9250700) then
		if self.Options.SoulConvergenceIcons then
			self:SetIcon(args.destName, self.vb.SoulConvergenceIcon)
		end
		self.vb.SoulConvergenceIcon = self.vb.SoulConvergenceIcon + 1
		if args:IsPlayer() then
			specWarnShadowDebuff:Show()
			specWarnShadowDebuff:Play("linegather")
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(9250699,9250700) and self.Options.SoulConvergenceIcons then
		self:SetIcon(args.destName, 0)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(9250699,9250700) then
		timerNextDebuff:Start()
		self.vb.SoulConvergenceIcon = 1
	end
end

function mod:UNIT_DIED(args)
	if bit.band(args.destGUID:sub(0, 5), 0x00F) == 3 then
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 16126 then -- Unrelenting Rider
			warnRiderDown:Show()
		elseif cid == 16125 then -- Unrelenting Deathknight
			warnKnightDown:Show()
		end
	end
end

function mod:UNIT_HEALTH_UNFILTERED(uId)
	if uId == "boss1" and not warned_lowhp and self:GetUnitCreatureId(uId) == 16060 and UnitHealth(uId) / UnitHealthMax(uId) < 0.3 then
		warned_lowhp = true
		warnLowHP:Show()
		timerTeleport:Cancel()
	end
end