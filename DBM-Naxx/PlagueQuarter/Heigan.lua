local mod	= DBM:NewMod("Heigan", "DBM-Naxx", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190516165414")
mod:SetCreatureID(15936)

mod:RegisterCombat("combat_yell", L.Pull)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 9250593"
)

local warnTeleportSoon			= mod:NewAnnounce("WarningTeleportSoon", 2, 46573)
local warnTeleportNow			= mod:NewAnnounce("WarningTeleportNow", 3, 46573)
local warnPlagueCloudEnd		= mod:NewEndAnnounce(30122, 1)

local timerTeleport				= mod:NewTimer(90, "TimerTeleport", 46573, nil, nil, 6)
local timerPlagueCloud			= mod:NewBuffActiveTimer(45, 30122, nil, nil, nil, 6)
-- Frostmourne custom (logs 2026-10-06, three long pulls)
local warnTunnel				= mod:NewAnnounce("WarningTunnel", 3, 46573)
local timerTunnel				= mod:NewTimer(20, "TimerTunnel", 46573, nil, nil, 3)
local timerFeverCD				= mod:NewNextTimer(20, 9250593, nil, nil, nil, 5) -- Decrepit Fever: 12.0, then every 20.0; 12s after each return from the dance

DBM:GetModLocalization("Heigan"):SetWarningLocalization({WarningTunnel = "5 players ported to the tunnel"})
DBM:GetModLocalization("Heigan"):SetTimerLocalization({TimerTunnel = "Tunnel port (5 players)"})
DBM:GetModLocalization("Heigan"):SetOptionLocalization({
	WarningTunnel	= "Announce when 5 players are ported to the tunnel",
	TimerTunnel		= "Show timer for the tunnel port",
})

function mod:DancePhase()
	timerFeverCD:Stop()
	timerTunnel:Stop()
	warnTunnel:Cancel()
	timerPlagueCloud:Start()
	warnTeleportSoon:Schedule(35, 10)
	warnPlagueCloudEnd:Schedule(45)
	self:ScheduleMethod(45, "BackInRoom", 88)
	self:SetStage(2)
end

function mod:BackInRoom(time)
	timerFeverCD:Start(12)
	timerTunnel:Start(20) -- 20s after the pull (three pulls) and 20s after returning from the dance (one pull)
	warnTunnel:Schedule(20)
	timerTeleport:Show(time)
	warnTeleportSoon:Schedule(time - 15, 15)
	warnTeleportNow:Schedule(time)
	self:ScheduleMethod(time, "DancePhase")
	self:SetStage(1)
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self:BackInRoom(90 - delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 9250593 and self.vb.phase == 1 then -- Decrepit Fever
		timerFeverCD:Start()
	end
end
