scope ArchmageAI
    globals
        private constant integer HERO_ID = 'H00Y'
		
		private HeroAI_Itemset array Itemsets	
        private group enumGroup = CreateGroup()
    endglobals
    
    private struct AI extends array
        // The following two methods will print out debug messages only when the events
        // are enabled
        method onAttacked takes unit attacker returns nothing
            //debug call BJDebugMsg("Abomination attacked by " + GetUnitName(attacker))
        endmethod
        
        method onAcquire takes unit target returns nothing
            //debug call BJDebugMsg("Abomination acquires " + GetUnitName(target))
        endmethod
        
        method assaultEnemy takes nothing returns nothing  
            //debug call BJDebugMsg("Abomination assault Enemy.")
			call .defaultAssaultEnemy()
        endmethod
        
        // Cast wind walk if there's an enemy nearby
        method loopActions takes nothing returns nothing
            call .defaultLoopActions()
        endmethod
        
        // A custom periodic method is defined for this hero as the AI constantly
        // searches for units that have their backs to her in order to use Backstab.
        static method onLoop takes nothing returns nothing
        
		endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Holy Chain
			call RegisterHeroAISkill(HERO_ID, 1, 'A08M')
			call RegisterHeroAISkill(HERO_ID, 5, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A08M') 
			// Trappy Swap
			call RegisterHeroAISkill(HERO_ID, 2, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A07N') 
			// Refreshing Aura
			call RegisterHeroAISkill(HERO_ID, 3, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A07M') 
			// Fireworks
			call RegisterHeroAISkill(HERO_ID, 6, 'A07K')
			call RegisterHeroAISkill(HERO_ID, 12, 'A07K')
			call RegisterHeroAISkill(HERO_ID, 18, 'A07K')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			// This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', BELT_OF_GIANT_STRENGTH, 1) // REPLACE
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', BELT_OF_GIANT_STRENGTH, 1) // REPLACE
				call Itemsets[1].addItem('u001', TWIN_AXE, 1) // REPLACE
				call Itemsets[1].addItem('u003', BLOOD_PLATE_ARMOR, 1) // REPLACE
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5) 
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', BELT_OF_GIANT_STRENGTH, 1) // REPLACE
				call Itemsets[2].addItem('u001', TWIN_AXE, 1) // REPLACE
				call Itemsets[2].addItem('u003', BLOOD_PLATE_ARMOR, 1) // REPLACE
				call Itemsets[2].addItem('u003', SPEAR_OF_VENGEANCE, 1) // REPLACE
			endif

			set .itemBuild = Itemsets[.aiLevel]
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope