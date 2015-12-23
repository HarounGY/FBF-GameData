scope MasterNecromancerAI
    globals
        private constant integer HERO_ID = 'U01Q'
		
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
			// Necromancy
			call RegisterHeroAISkill(HERO_ID, 1, 'A05D')
			call RegisterHeroAISkill(HERO_ID, 5, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A05D') 
			// Malicious Curse
			call RegisterHeroAISkill(HERO_ID, 2, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A064') 
			// Despair
			call RegisterHeroAISkill(HERO_ID, 3, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A068') 
			// Dead Souls
			call RegisterHeroAISkill(HERO_ID, 6, 'A08Z')
			call RegisterHeroAISkill(HERO_ID, 12, 'A08Z')
			call RegisterHeroAISkill(HERO_ID, 18, 'A08Z')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			// This is where you would define a custom item build
            set Itemsets[0] = HeroAI_Itemset.create()
			call Itemsets[0].addItemTypeId('I000')
			call Itemsets[0].addItemTypeId('I001')
			set .itemBuild = Itemsets[0] 
			
			call BJDebugMsg("Created Abilities and Itemsets for Master Necromancer")
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope