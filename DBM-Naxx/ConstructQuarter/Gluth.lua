local mod	= DBM:NewMod("Gluth", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250929220131")
mod:SetCreatureID(15932)
mod:SetEncounterID(1108)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 28371 54427",
	"SPELL_AURA_REMOVED 28371 54427",
	"SPELL_CAST_SUCCESS 28375 9250703 9250704 25646"
)

local warnEnrage		= mod:NewTargetNoFilterAnnounce(54427, 3, nil , "Healer|Tank|RemoveEnrage", 2)
local warnDecimateSoon	= mod:NewSoonAnnounce(28374, 2)
local warnDecimateNow	= mod:NewSpellAnnounce(28374, 3)

local specWarnEnrage	= mod:NewSpecialWarningDispel(54427, "RemoveEnrage", nil, nil, 1, 6)

local timerEnrage		= mod:NewBuffActiveTimer(8, 54427, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)
local timerEnrageCD		= mod:NewCDTimer(30, 54427, nil, nil, nil, 5)
local timerDecimate		= mod:NewCDTimer(105, 28374, nil, nil, nil, 2)
local enrageTimer		= mod:NewBerserkTimer(480)
local timerFearCD		= mod:NewCDTimer(20, 9250704, nil, nil, nil, 2)
local timerHealingDebuff= mod:NewNextTimer(8, 25646, nil, nil, nil, 1)

function mod:OnCombatStart(delay)
	enrageTimer:Start(480 - delay)
	timerEnrageCD:Start(30 - delay)
	timerDecimate:Start(- delay)
	timerFearCD:Start(-delay)
	warnDecimateSoon:Schedule(100 - delay)
	timerHealingDebuff:Start(10- delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(28371, 54427) then
		if self.Options.SpecWarn54427dispel then
			local class = self:UnitClass()
			if class == "HUNTER" or class == "ROGUE" then
				specWarnEnrage:Play("dispelboss")
			else
				specWarnEnrage:Play("enrage")
			end
			specWarnEnrage:Show(args.destName)
		else
			warnEnrage:Show(args.destName)
		end
		timerEnrage:Start()
		timerEnrageCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(28371, 54427) then
		timerEnrage:Stop()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 28375 and self:AntiSpam(20) then
		warnDecimateNow:Show()
		timerDecimate:Start()
		warnDecimateSoon:Schedule(100)
	elseif args.spellName == "Terrifying Roar" then	
		timerFearCD:Start(20)
	elseif args:IsSpellID(25646) then
		timerHealingDebuff:Start()		
	end
end
