scope DarkRangerAI
    globals
        private constant integer HERO_ID = 'N00J'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Crippling Arrow */
		private constant integer CA_SPELL_ID = 'A0AJ'
		private constant integer CA_BUFF_ID = 'B013'
		private constant string CA_ORDER = "deathanddecay"
		private integer array CA_Chance
		private real array CA_Cooldown
		private timer CA_Timer
		private real CA_RADIUS = 700
		private integer CA_Hero_Chance = 85
		private integer CA_Normal_Chance = 15
		
		/* XY */
		private constant integer XY_SPELL_ID = 'XYXY'
		private constant string XY_ORDER = "xxx"
		private integer array XY_Chance
		private real array XY_Cooldown
		private timer XY_Timer		

		/* XZ */
		private constant integer XZ_SPELL_ID = 'XZXZ'
		private constant string XZ_ORDER = "xxx"
		private integer array XZ_Chance
		private real array XZ_Cooldown
		private timer XZ_Timer
    endglobals
    
    private struct AI extends array
	
		private static method CA_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
	
		private method doCripplingArrow takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, CA_SPELL_ID) - 1
			local unit u
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, CA_RADIUS, Filter(function thistype.CA_Filter))
			
			loop
				set u = GetRandomUnitFromGroup(enumGroup)
				exitwhen (u == null)
				// deals bonus damage if the target is already affected by an arrow.
				if (GetUnitAbilityLevel(u, CA_BUFF_ID) > 0) then
					set abilityCasted = IssuePointOrder(.hero, CA_ORDER, GetUnitX(u), GetUnitY(u))
				else
					if ((GetRandomInt(0,100) <= CA_Hero_Chance) and /*
					*/	(IsUnitType(u, UNIT_TYPE_HERO))) then
						set abilityCasted = IssuePointOrder(.hero, CA_ORDER, GetUnitX(u), GetUnitY(u))
					else
						if (GetRandomInt(0,100) <= CA_Normal_Chance) then
							set abilityCasted = IssuePointOrder(.hero, CA_ORDER, GetUnitX(u), GetUnitY(u))
						endif
					endif
				endif
				
				if (abilityCasted) then
					call TimerStart(CA_Timer, CA_Cooldown[level], false, null)
					call GroupClear(enumGroup)
				else
					call GroupRemoveUnit(enumGroup, u)
				endif
			endloop
			
			set u = null
			
			return abilityCasted
		endmethod
		
		private method doXY takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, XY_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(XY_Timer, XY_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doXZ takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, XZ_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(XZ_Timer, XZ_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Crippling Arrow */
				if ((GetRandomInt(0,100) <= CA_Chance[.aiLevel]) and /*
				*/ (TimerGetRemaining(CA_Timer) == 0.0)) then
					set abilityCasted = doCripplingArrow()
				endif
				
				/* XY */
				if ((GetRandomInt(0,100) <= XY_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(XY_Timer) == 0.0)) then
					set abilityCasted = doXY()
				endif
				
				/* XZ */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= XZ_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(XZ_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doXZ()					
				endif
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Ghost Form
			call RegisterHeroAISkill(HERO_ID, 1, 'A071')
			call RegisterHeroAISkill(HERO_ID, 5, 'A071') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A071') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A071') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A071') 
			// Crippling Arrow
			call RegisterHeroAISkill(HERO_ID, 2, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A0AJ') 
			// Snipe
			call RegisterHeroAISkill(HERO_ID, 3, 'A075') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A075') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A075') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A075') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A075') 
			// Coup de Grace
			call RegisterHeroAISkill(HERO_ID, 6, 'A076')
			call RegisterHeroAISkill(HERO_ID, 12, 'A076')
			call RegisterHeroAISkill(HERO_ID, 18, 'A076')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', UNHOLY_ICON, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', UNHOLY_ICON, 1)
				call Itemsets[1].addItem('u001', DARK_PLATES, 1)
				call Itemsets[1].addItem('u003', NECROMANCERS_ROBE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', UNHOLY_ICON, 1)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
				call Itemsets[2].addItem('u003', ARCANE_FLARE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Crippling Arrow
			set CA_Chance[0] = 20
			set CA_Chance[1] = 30
			set CA_Chance[2] = 40
			
			set CA_Timer = NewTimer()
			set CA_Cooldown[0] = 8.0
			set CA_Cooldown[1] = 8.0
			set CA_Cooldown[2] = 8.0
			set CA_Cooldown[3] = 8.0
			set CA_Cooldown[4] = 8.0
			
			// XY
			set XY_Chance[0] = 10
			set XY_Chance[1] = 20
			set XY_Chance[2] = 20
			
			set XY_Timer = NewTimer()
			set XY_Cooldown[0] = 150.0
			set XY_Cooldown[1] = 150.0
			set XY_Cooldown[2] = 150.0
			set XY_Cooldown[3] = 150.0
			set XY_Cooldown[4] = 150.0
			
			// XZ
			set XZ_Chance[0] = 10
			set XZ_Chance[1] = 20
			set XZ_Chance[2] = 20
			
			set XZ_Timer = NewTimer()
			set XZ_Cooldown[0] = 150.0
			set XZ_Cooldown[1] = 150.0
			set XZ_Cooldown[2] = 150.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope