local mod	= DBM:NewMod("Maexxna", "DBM-Naxx", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(15952)
mod:SetEncounterID(1116)
mod:RegisterCombat("combat")
mod:SetUsedIcons(6, 7, 8)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 28622 29484 54125 9250571 9250572 9250573 9250574 9250572",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

--TODO, verify nax40 web wrap timer
local warnWebWrap		= mod:NewTargetNoFilterAnnounce(28622, 2)
local warnWebSpraySoon	= mod:NewSoonAnnounce(29484, 1)
local warnWebSprayNow	= mod:NewSpellAnnounce(29484, 3)
local warnSpidersSoon	= mod:NewAnnounce("WarningSpidersSoon", 2, 17332)
local warnSpidersNow	= mod:NewAnnounce("WarningSpidersNow", 4, 17332)

local specWarnWebWrap	= mod:NewSpecialWarningSwitch(28622, "RangedDps", nil, nil, 1, 2)
local yellWebWrap		= mod:NewYellMe(28622)
mod:AddSetIconOption("WebWrappedIcons", 28622, true, 5, {6,7,8})

local timerWebSpray		= mod:NewNextTimer(40, 29484, nil, nil, nil, 2)
local timerWebWrap		= mod:NewNextTimer(30, 28622, nil, "RangedDps|Healer", nil, 3)
local timerSpider		= mod:NewTimer(29.5, "TimerSpider", 17332, nil, nil, 1)

local emoteSpiderlings = "Spiderlings appear on the web!"

mod.vb.WebWrappedIcon = 8

function mod:OnCombatStart(delay)
	warnWebSpraySoon:Schedule(35 - delay)
	timerWebSpray:Start(40 - delay)
	timerWebWrap:Start(18 - delay)
	warnSpidersSoon:Schedule(20.2 - delay)
	timerSpider:Start(27 - delay)
	self.vb.WebWrappedIcon = 8
end

function mod:OnCombatEnd(wipe)
	if not wipe then
		if DBT:GetBar(L.ArachnophobiaTimer) then
			DBT:CancelBar(L.ArachnophobiaTimer)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(28622,9250571,9250572) then -- Web Wrap
		self.vb.WebWrappedIcon = 8
		if self.Options.WebWrappedIcons then
			self:ScanForMobs(args.sourceGUID, 2, self.vb.WebWrappedIcon, 1, nil, 15, "WebWrappedIcons")
		end
		self.vb.WebWrappedIcon = self.vb.WebWrappedIcon - 1	
		warnWebWrap:CombinedShow(0.5, args.destName)		
		if self:AntiSpam(3, 1) then
			specWarnWebWrap:Show()
			--timerWebWrap:Start()
			-- if self:IsDifficulty("normal25") then
				-- timerWebWrap:Start()
			-- else
				-- timerWebWrap:Start(20)
			-- end
		end
		if args.destName == UnitName("player") then
			yellWebWrap:Yell()
		elseif not DBM:UnitDebuff("player", args.spellName) and self:AntiSpam(3, 2) then
			specWarnWebWrap:Play("killwebs")
		end
	elseif args:IsSpellID(29484, 54125,9250573,9250574) and self:AntiSpam(3, 3) then -- Web Spray
		warnWebSprayNow:Show()
		warnWebSpraySoon:Schedule(35)
		timerWebSpray:Start()
		warnSpidersSoon:Schedule(25.2)
		timerSpider:Start()
		timerWebWrap:Start(20)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == emoteSpiderlings then
		self:SendSync("Spiderlings")
	end
end

function mod:OnSync(event)
	if event == "Spiderlings" then
		warnSpidersNow:Show()
		--warnSpidersSoon:Schedule(20.2)
		--timerSpider:Start()
	end
end
