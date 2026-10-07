local mod	= DBM:NewMod("Heigan", "DBM-Naxx", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(15936)
mod:SetEncounterID(1112)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 9250691",
)
mod:RegisterCombat("combat_yell", L.Pull)

local warnTeleportSoon			= mod:NewAnnounce("WarningTeleportSoon", 2, 46573)
local warnTeleportNow			= mod:NewAnnounce("WarningTeleportNow", 3, 46573)
local warnPlagueCloudEnd		= mod:NewEndAnnounce(30122, 1)

local timerTeleport				= mod:NewTimer(90, "TimerTeleport", 46573, nil, nil, 6)
local timerPlagueCloud			= mod:NewBuffActiveTimer(45, 30122, nil, nil, nil, 6)
local nextGauntlet				= mod:NewNextTimer(15, "Next Gauntlet Teleport", nil, nil, nil, 6)

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(9250691) then
		nextGauntlet:Start()
	end
end

function mod:DancePhase()
	nextGauntlet:Cancel()
	timerPlagueCloud:Start()
	warnTeleportSoon:Schedule(35, 10)
	warnPlagueCloudEnd:Schedule(45)
	self:ScheduleMethod(45, "BackInRoom", 88)
	self:SetStage(2)
end

function mod:BackInRoom(time)
	timerTeleport:Show(time)
	warnTeleportSoon:Schedule(time - 15, 15)
	warnTeleportNow:Schedule(time)
	self:ScheduleMethod(time, "DancePhase")
	nextGauntlet:Start()
	self:SetStage(1)
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	nextGauntlet:Start(15-delay)
	self:BackInRoom(90 - delay)
end
