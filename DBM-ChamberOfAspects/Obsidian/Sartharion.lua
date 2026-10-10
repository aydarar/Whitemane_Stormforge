local mod	= DBM:NewMod("Sartharion", "DBM-ChamberOfAspects", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,normal25"

mod:SetRevision("20250929220131")
mod:SetCreatureID(28860)
mod:SetEncounterID(742)
mod:SetUsedIcons(8)

mod:RegisterCombat("yell", L.YellSarthPull)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 56908 58956 9250871 9250872",
	"SPELL_CAST_SUCCESS 57579 59127",
	"SPELL_AURA_APPLIED 57491 9250867 9250868",
	"SPELL_AURA_REMOVED 9250867 9250868",	
	"SPELL_DAMAGE 59128",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_EMOTE",
	"UNIT_DIED"
)

local warnFissure				= mod:NewTargetNoFilterAnnounce(59127, 4)
local warnBreathSoon			= mod:NewSoonAnnounce(58956, 2, nil, "Tank|Healer")
local warnTenebron				= mod:NewAnnounce("WarningTenebron", 2, 61248)
local warnShadron				= mod:NewAnnounce("WarningShadron", 2, 58105)
local warnVesperon				= mod:NewAnnounce("WarningVesperon", 2, 61251)
local warnTenebronWhelpsSoon	= mod:NewAnnounce("WarningWhelpsSoon", 1, 1022, false)
local warnShadronPortalSoon		= mod:NewAnnounce("WarningPortalSoon", 1, 11420, false)
local warnVesperonPortalSoon	= mod:NewAnnounce("WarningReflectSoon", 1, 57988, false)

local specWarnFireWall			= mod:NewSpecialWarning("WarningFireWall", nil, nil, nil, 2, 2)
local specWarnVesperonPortal	= mod:NewSpecialWarning("WarningVesperonPortal", false, nil, nil, 1, 7)
local specWarnTenebronPortal	= mod:NewSpecialWarning("WarningTenebronPortal", false, nil, nil, 1, 7)
local specWarnShadronPortal		= mod:NewSpecialWarning("WarningShadronPortal", false, nil, nil, 1, 7)
local specWarnFissureYou		= mod:NewSpecialWarningYou(59127, nil, nil, nil, 3, 2)
local specWarnFissureClose		= mod:NewSpecialWarningClose(59127, nil, nil, nil, 2, 8)
local yellFissure				= mod:NewYellMe(59127)

local timerFissure				= mod:NewTargetTimer(5, 59128, nil, nil, 2, 3)--Cast timer until Void Blast. it's what happens when shadow fissure explodes.
local timerBreath				= mod:NewCDTimer(20, 58956, nil, "Tank|Healer", nil, 5)
local timerWall					= mod:NewNextTimer(25, 43113, nil, nil, nil, 2)
local timerTenebron				= mod:NewTimer(45, "TimerTenebron", 61248, nil, nil, 1)
local timerShadron				= mod:NewTimer(88, "TimerShadron", 58105, nil, nil, 1)
local timerVesperon				= mod:NewTimer(138, "TimerVesperon", 61251, nil, nil, 1)
local timerTenebronWhelps		= mod:NewTimer(80, "TimerTenebronWhelps", 1022)
local timerShadronPortal		= mod:NewTimer(132, "TimerShadronPortal", 11420)
local timerVesperonPortal		= mod:NewTimer(168, "TimerVesperonPortal", 57988)
--local timerTwighlightBlackout	= mod:NewNextTimer(15, 9250867, nil, nil, nil, 2)
local yellTwighlightBlackout	= mod:NewYellMe(9250867,"Stack at me!")
local timerBlackoutCD			= mod:NewNextTimer(50, 9250868, nil, nil, nil, 3)
local timerBlackout				= mod:NewTargetTimer(15, 9250868, nil, nil, nil, 5)

mod:AddBoolOption("AnnounceFails", true, "announce")

mod:GroupSpells(59127, 59128)--Shadow fissure with void blast

mod:AddSetIconOption("TwiglightBlackoutIcons", 9250867, true, 5, {8})
mod.vb.TwiglightBlackoutIcon = 8

local specWarnTwighlightBlackout = mod:NewAnnounce("Stack up on marked player and heal up after! DO NOT dispell or heal marked player until group stacked up on him!", 2)
local vesperonPortalEmote = "You pose no threat, lesser beings! Give me your worst!"

local lastvoids = {}
local lastfire = {}
local tsort, tinsert, twipe = table.sort, table.insert, table.wipe

local function isunitdebuffed(spellName)
	for uId in DBM:GetGroupMembers() do
		local debuff = DBM:UnitDebuff(uId, spellName)
		if debuff then
			return true
		end
	end
	return false
end

local function CheckDrakes(self, delay)
	if self.Options.HealthFrame then
		DBM.BossHealth:Show(L.name)
		DBM.BossHealth:AddBoss(28860, "Sartharion")
	end
	if isunitdebuffed(DBM:GetSpellInfo(61248)) then	-- Power of Tenebron
		timerTenebron:Start(52-5 - delay)
		warnTenebron:Schedule(47-5 - delay)
		timerTenebronWhelps:Start(93.5-5 - delay)
		warnTenebronWhelpsSoon:Schedule(88.5-5 - delay)
		if self.Options.HealthFrame then
			DBM.BossHealth:AddBoss(30452, "Tenebron")
		end
	end
	if isunitdebuffed(DBM:GetSpellInfo(58105)) then	-- Power of Shadron
		timerShadron:Start(90-5 - delay)
		warnShadron:Schedule(85-5 - delay)
		timerShadronPortal:Start(105-5 - delay)
		warnShadronPortalSoon:Schedule(100-5 - delay)
		if self.Options.HealthFrame then
			DBM.BossHealth:AddBoss(30451, "Shadron")
		end
	end
	if isunitdebuffed(DBM:GetSpellInfo(61251)) then	-- Power of Vesperon
		timerVesperon:Start(138-5 - delay)
		warnVesperon:Schedule(133-5 - delay)
		timerVesperonPortal:Start(168-5 - delay)
		warnVesperonPortalSoon:Schedule(163-5 - delay)
		if self.Options.HealthFrame then
			DBM.BossHealth:AddBoss(30449, "Vesperon")
		end
	end
end

local sortedFails = {}
local function sortFails1(e1, e2)
	return (lastvoids[e1] or 0) > (lastvoids[e2] or 0)
end
local function sortFails2(e1, e2)
	return (lastfire[e1] or 0) > (lastfire[e2] or 0)
end

function mod:OnCombatStart(delay)
	--Cache spellnames so a solo player check doesn't fail in CheckDrakes in 8.0+
	self:Schedule(5, CheckDrakes, self, delay)
	timerWall:Start(20-delay)
	warnBreathSoon:Schedule(10-delay)
	timerBreath:Start(15-delay)
	timerBlackoutCD:Start(22-delay)
	
	twipe(lastvoids)
	twipe(lastfire)
	self.vb.TwiglightBlackoutIcon = 8 
end

function mod:OnCombatEnd()
	if not self.Options.AnnounceFails then return end
	if DBM:GetRaidRank() < 1 or not self.Options.Announce then return end

	local voids = ""
	for k, _ in pairs(lastvoids) do
		tinsert(sortedFails, k)
	end
	tsort(sortedFails, sortFails1)
	for _, v in ipairs(sortedFails) do
		voids = voids.." "..v.."("..(lastvoids[v] or "")..")"
	end
	SendChatMessage(L.VoidZones:format(voids), "RAID")
	twipe(sortedFails)
	local fire = ""
	for k, _ in pairs(lastfire) do
		tinsert(sortedFails, k)
	end
	tsort(sortedFails, sortFails2)
	for _, v in ipairs(sortedFails) do
		fire = fire.." "..v.."("..(lastfire[v] or "")..")"
	end
	SendChatMessage(L.FireWalls:format(fire), "RAID")
	twipe(sortedFails)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(56908, 58956, 9250871, 9250872) then -- Flame breath
		warnBreathSoon:Schedule(15)
		timerBreath:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(57579, 59127) then
		timerFissure:Start(args.destName)
		if args:IsPlayer() then
			specWarnFissureYou:Show()
			specWarnFissureYou:Play("targetyou")
			yellFissure:Yell()
		elseif self:CheckNearby(8, args.destName) then
			specWarnFissureClose:Show(args.destName)
			specWarnFissureClose:Play("watchfeet")
		else
			warnFissure:Show(args.destName)
			warnFissure:Play("watchstep")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if self.Options.AnnounceFails and self.Options.Announce and args.spellId == 57491 and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(args.destName) ~= "none" and args.destName then
		lastfire[args.destName] = (lastfire[args.destName] or 0) + 1
		SendChatMessage(L.FireWallOn:format(args.destName), "RAID")
	end
	if args:IsSpellID(9250867,9250868) then
		timerBlackoutCD:Start()
		timerBlackout:Start(args.destName)	
		if self.Options.TwiglightBlackoutIcons then
			self:SetIcon(args.destName, self.vb.TwiglightBlackoutIcon)
		end
		specWarnTwighlightBlackout:Show()
		specWarnTwighlightBlackout:Play("helpsoak")
		if args:IsPlayer() then			
			yellTwighlightBlackout:Yell()
		end
	end	
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(9250867,9250868) then -- Twilight Blackout ended (dispelled or expired)
		timerBlackout:Stop(args.destName)
		if self.Options.TwiglightBlackoutIcons then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destName, _, spellId)
	if self.Options.AnnounceFails and self.Options.Announce and spellId == 59128 and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(destName) ~= "none" and destName then
		lastvoids[destName] = (lastvoids[destName] or 0) + 1
		SendChatMessage(L.VoidZoneOn:format(destName), "RAID")
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, mob)
	if msg == L.Wall or msg:find(L.Wall) then
		self:SendSync("FireWall")
	elseif msg == L.Portal or msg:find(L.Portal) or msg == L.Portal:gsub("%%s", mob) or msg == vesperonPortalEmote then
		if mob == L.NameVesperon then
			self:SendSync("VesperonPortal")
		elseif mob == L.NameTenebron then
			self:SendSync("TenebronPortal")
		elseif mob == L.NameShadron then
			self:SendSync("ShadronPortal")
		end
	end
end
mod.CHAT_MSG_MONSTER_EMOTE = mod.CHAT_MSG_RAID_BOSS_EMOTE

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 31219 then -- Acolyte of Vesperon
		self:SendSync("VesperonAcolyte")
	end
end

function mod:OnSync(event)
	if event == "FireWall" then
		timerWall:Start()
		specWarnFireWall:Show()
		specWarnFireWall:Play("watchwave")
	elseif event == "VesperonPortal" then
		specWarnVesperonPortal:Show()
		specWarnVesperonPortal:Play("newportal")
	elseif event == "TenebronPortal" then
		specWarnTenebronPortal:Show()
		specWarnTenebronPortal:Play("newportal")
	elseif event == "ShadronPortal" then
		specWarnShadronPortal:Show()
		specWarnShadronPortal:Play("newportal")
		--timerShadronPortal:Start(132)
		--warnShadronPortalSoon:Schedule(127)
	elseif event == "VesperonAcolyte" then
		timerVesperonPortal:Start(30)
		warnVesperonPortalSoon:Schedule(25)
	end
end
