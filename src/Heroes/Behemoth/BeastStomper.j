scope BeastStomper initializer init
    /*
     * Description: Octar slams the ground, stunning and damaging nearby enemy units.
     * Changelog: 
     *     25.10.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
     *
     */
    globals
        private constant integer SPELL_ID = 'A00D'
        private constant real DAMAGE_PER_LEVEL = 50
        private constant integer RADIUS = 250
        private constant real JUMP_DURATION = 0.4
        private string SOUND = "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.wav"
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 1.5
    endglobals

    private struct BeastStomper
        unit caster
        group targets
        timer t
        static thistype tempthis = 0
        
        static method damage takes unit source, unit target returns nothing
            local real dmg = GetUnitAbilityLevel(source, SPELL_ID) * DAMAGE_PER_LEVEL
            set DamageType = SPELL
            call DamageUnitPhysical(source, target, dmg)
        endmethod
        
        static method jump takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real d = 200
            local real a = AngleBetweenCords(GetUnitX(.tempthis.caster), GetUnitY(.tempthis.caster), GetUnitX(u), GetUnitY(u))  
            local real dur = JUMP_DURATION
            local real x1 = GetUnitX(u)
            local real y1 = GetUnitY(u)
            local real x2 = PolarProjectionX(x1, d, a)
            local real y2 = PolarProjectionY(y1, d, a)
            local real c = 1.0
            local real r = 200
            local string sfx2 = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
            
            call Jump(u, dur, x2, y2, c, r, "", sfx2, "")
            call damage(.tempthis.caster, u)
            
            set u = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not /*
			*/	   IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not /*
			*/     IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not /*
			*/     IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .targets = NewGroup()
            set .t = NewTimer()
            set .tempthis = this
            
            call Sound.runSoundOnUnit(SOUND, .caster)
            call GroupEnumUnitsInRange( .targets, GetUnitX(.caster), GetUnitY(.caster), RADIUS, function thistype.group_filter_callback )
            call ForGroup( .targets, function thistype.jump )
            call SetTimerData(.t, this)
            call TimerStart(.t, 0.3, false, function thistype.onJumpEnd)
            
            return this
        endmethod
        
        static method onJumpEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call ForGroup( this.targets, function thistype.stunTargets )
        endmethod
        
        static method stunTargets takes nothing returns nothing
            call Stun_UnitEx(GetEnumUnit(), STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            
            if ( CountUnitsInGroup(.tempthis.targets) == 0 ) then
                call .tempthis.destroy()
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            call ReleaseTimer( .t )
            set .targets = null
            set .t = null
            set .caster = null
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call BeastStomper.create( GetTriggerUnit() )
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
		call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        call Preload(STUN_EFFECT)
		call Sound.preload(SOUND)
		
		set t = null
    endfunction
endscope