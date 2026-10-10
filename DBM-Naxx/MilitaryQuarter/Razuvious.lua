local mod	= DBM:NewMod("Razuvious", "DBM-Naxx", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20251206163020")
mod:SetCreatureID(16061)
mod:SetEncounterID(1113)

mod:RegisterCombat("combat_yell", L.Yell1, L.Yell2, L.Yell3, L.Yell4)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 55543 29107 29060 29061 26613 9250696 9250608 9250609",
	"SPELL_AURA_APPLIED 605",
	"UNIT_DIED"
)

local warnShoutNow		= mod:NewSpellAnnounce(29107, 1, "Interface\\Icons\\Ability_Warrior_Rampage")
local warnShoutSoon		= mod:NewSoonAnnounce(29107, 3, "Interface\\Icons\\Ability_Warrior_Rampage")
local warnShieldWall	= mod:NewAnnounce("WarningShieldWallSoon", 3, 29061, nil, nil, nil, 29061)
local warnKnife			= mod:NewTargetNoFilterAnnounce(9250609, 2) -- Frostmourne custom

local timerShout		= mod:NewNextTimer(15, 29107, nil, nil, nil, 2, "Interface\\Icons\\Ability_Warrior_Rampage")
local timerTaunt		= mod:NewCDTimer(20, 29060, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerShieldWall	= mod:NewBuffActiveTimer(20, 29061, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerMindControl	= mod:NewBuffActiveTimer(60, 605, nil, nil, nil, 6)
local timerUnbalanced   = mod:NewNextTimer(30, 26613, nil, nil, nil, 1)
local timerKnifeCD		= mod:NewNextTimer(10, 9250609, nil, nil, nil, 3) -- Frostmourne custom, log 2026-10-06: 35.5, then every 10.0-10.1

mod:AddRangeFrameOption(12, 9250696) -- Disciplinary Shout (Frostmourne custom)
mod:AddBoolOption("Distance2Boss", true, "misc") -- distance to boss status 20 yd
DBM:GetModLocalization("Razuvious"):SetOptionLocalization({Distance2Boss = "Show distance to boss status (20 yd) - needs DBM-Distance2Boss"})


function mod:OnCombatStart(delay)
	timerKnifeCD:Start(35.5 - delay)	
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(12)
	end
	if self.Options.Distance2Boss and DBM.Distance2Boss then
		DBM.Distance2Boss:Show(20)
	end	
	if self:IsDifficulty("normal25", "heroic25", "heroic10") then
		timerShout:Start(15 - delay)
		warnShoutSoon:Schedule(10 - delay)
	else
		timerShout:Start(25 - delay)
		warnShoutSoon:Schedule(20 - delay)
	end
		timerUnbalanced:Start(30 - delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if args:IsSpellID(55543, 29107, 9250696) 	then  -- Disrupting Shout
		warnShoutNow:Show()
		if self:IsDifficulty("normal25", "heroic25", "heroic10") then
			timerShout:Start()
			warnShoutSoon:Schedule(10)
		else
			timerShout:Start(25)
			warnShoutSoon:Schedule(20)
		end
	elseif spellId == 29060 then -- Taunt
		timerTaunt:Start(20, args.sourceGUID)
	elseif spellId == 29061 and self:AntiSpam(2, 1) then -- ShieldWall
		timerShieldWall:Start(20, args.sourceGUID)
		warnShieldWall:Schedule(15)
	elseif args:IsSpellID(9250608, 9250609) then -- Jagged Knife (Frostmourne custom)
		timerKnifeCD:Start()		
	elseif args:IsSpellID(26613) 	then  -- Unbalanced Strike
		timerUnbalanced:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 605 and args:IsSrcTypePlayer() then -- Mind Control
		timerMindControl:Start(nil, args.sourceName)
	elseif args:IsSpellID(9250608, 9250609) then -- Jagged Knife (Frostmourne custom)
		warnKnife:Show(args.destName)		
	end
end

function mod:UNIT_DIED(args)
	local guid = args.destGUID
	local cid = self:GetCIDFromGUID(guid)
	if cid == 16803 then--Deathknight Understudy
		timerTaunt:Stop(args.destGUID)
		timerShieldWall:Stop(args.destGUID)
	end
end
