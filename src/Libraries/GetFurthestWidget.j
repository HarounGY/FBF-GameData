/*****************************************************************************
*
*    GetFurthestWidget v1.0.0.0
*       by pred1980
*
*    Allows finding of furthest widget with ease.
*
******************************************************************************
*
*    private constant boolean UNITS_MODULE
*    private constant boolean GROUP_MODULE
*    private constant boolean ITEMS_MODULE
*    private constant boolean DESTS_MODULE
*       choose which modules should or should not be implemented
*
*    private constant real START_DISTANCE
*    private constant real FINAL_DISTANCE
*       defined start and final distances for search iterations within generic GetFurthest functions
*       if final value is reached, enumeration is performed on whole map
*
******************************************************************************
*
*    Functions:
*
*       Units:
*
*          function GetFurthestUnit takes real x, real y, boolexpr filter returns unit
*             returns unit furthest to coords(x, y)
*
*          function GetFurthestUnitInRange takes real x, real y, real radius, boolexpr filter returns unit
*             returns unit furthest to coords(x, y) within range radius
*
*          function GetFurthestUnitInGroup takes real x, real y, group g returns unit
*             returns unit furthest to coords(x, y) within group g
*
*       Group:
*
*          function GetFurthestNUnitsInRange takes real x, real y, real radius, integer n, group dest, boolexpr filter returns nothing
*             adds up to N units, furthest to coords(x, y) within range radius to group dest
*
*          function GetFurthestNUnitsInGroup takes real x, real y, integer n, group source, group dest returns nothing
*             adds up to N units, furthest to coords(x, y) within group source to group dest
*
*       Items:
*
*          function GetFurthestItem takes real x, real y, boolexpr filter returns item
*             returns item furthest to coords(x, y)
*
*          function GetFurthestItemInRange takes real x, real y, real radius, boolexpr filter returns item
*             returns item furthest to coords(x, y) within range radius
*
*       Destructables:
*
*          function GetFurthestDestructable takes real x, real y, boolexpr filter returns destructable
*             returns destructable furthest to coords(x, y)
*
*          function GetFurthestDestructableInRange takes real x, real y, real radius, boolexpr filter returns destructable
*             returns destructable furthest to coords(x, y) within range radius
*
*****************************************************************************/
library GetFurthestWidget

    globals
        private constant boolean UNITS_MODULE = true
        private constant boolean GROUP_MODULE = true
        private constant boolean ITEMS_MODULE = true
        private constant boolean DESTS_MODULE = true

        private constant real START_DISTANCE  = 800
        private constant real FINAL_DISTANCE  = 3200
    endglobals

    globals
        private real distance = 0
        private real coordX = 0
        private real coordY = 0
    endglobals

    private keyword furthestDestructable
    private keyword furthestItem
    private keyword furthestUnit

    private function default takes real x, real y returns nothing
        static if DESTS_MODULE then
            set furthestDestructable = null
        endif
        static if ITEMS_MODULE then
            set furthestItem = null
        endif
        static if UNITS_MODULE then
            set furthestUnit = null
        endif

        set distance = 0
        set coordX = x
        set coordY = y
    endfunction

    private function calcDistance takes real x, real y returns real
        local real dx = x - coordX
        local real dy = y - coordY
        return ( (dx*dx + dy*dy) / 10000 )
    endfunction

    static if UNITS_MODULE then
        //! runtextmacro DEFINE_GFW_UNIT_MODULE()
    endif
    static if GROUP_MODULE then
        //! runtextmacro DEFINE_GFW_GROUP_MODULE()
    endif
    static if ITEMS_MODULE then
        //! runtextmacro DEFINE_GFW_MODULE("Item", "item")
    endif
    static if DESTS_MODULE then
        //! runtextmacro DEFINE_GFW_MODULE("Destructable", "destructable")
    endif

//! textmacro DEFINE_GFW_UNIT_MODULE
    globals
        private unit furthestUnit = null
    endglobals

    private function cbEnumUnits takes unit u returns nothing
        local real dist = calcDistance(GetUnitX(u), GetUnitY(u))
        if ( dist > distance ) then
            set furthestUnit = u
            set distance = dist
        endif
    endfunction

    private function enumUnits takes nothing returns nothing
        call cbEnumUnits(GetEnumUnit())
    endfunction

    function GetFurthestUnit takes real x, real y, boolexpr filter returns unit
        local real r = START_DISTANCE
        local unit u
        call default(x, y)

        loop
            if ( r > FINAL_DISTANCE ) then
                call GroupEnumUnitsInRect(bj_lastCreatedGroup, bj_mapInitialPlayableArea, filter)
                exitwhen true
            else
                call GroupEnumUnitsInRange(bj_lastCreatedGroup, x, y, r, filter)
                exitwhen FirstOfGroup(bj_lastCreatedGroup) != null
            endif
            set r = 2*r
        endloop

        loop
            set u = FirstOfGroup(bj_lastCreatedGroup)
            exitwhen u == null
            call cbEnumUnits(u)
            call GroupRemoveUnit(bj_lastCreatedGroup, u)
        endloop

        return furthestUnit
    endfunction

    function GetFurthestUnitInRange takes real x, real y, real radius, boolexpr filter returns unit
        local unit u
        call default(x, y)

        if ( radius >= 0 ) then
            call GroupEnumUnitsInRange(bj_lastCreatedGroup, x, y, radius, filter)
            loop
                set u = FirstOfGroup(bj_lastCreatedGroup)
                exitwhen u == null
                call cbEnumUnits(u)
                call GroupRemoveUnit(bj_lastCreatedGroup, u)
            endloop
            set u = null
        endif

        return furthestUnit
    endfunction

    function GetFurthestUnitInGroup takes real x, real y, group g returns unit
        call default(x, y)
        call ForGroup(g, function enumUnits)
        return furthestUnit
    endfunction
//! endtextmacro

//! textmacro DEFINE_GFW_GROUP_MODULE
    globals
        private unit array sorted
        private real array vector
        private integer count = 0
    endglobals

    private function cbSaveUnits takes unit u returns nothing
        set count = count + 1
        set sorted[count] = u
        set vector[count] = calcDistance(GetUnitX(u), GetUnitY(u))
    endfunction

    private function saveUnits takes nothing returns nothing
        call cbSaveUnits(GetEnumUnit())
    endfunction

    private function sortUnits takes integer lo, integer hi returns nothing
        local integer i = lo
        local integer j = hi
        local real pivot = vector[(lo+hi)/2]
        loop
            loop
                exitwhen vector[i] >= pivot
                set i = i + 1
            endloop
            loop
                exitwhen vector[j] <= pivot
                set j = j - 1
            endloop

            exitwhen i > j
            // use index 0 as temp variable
            set vector[0] = vector[i]
            set vector[i] = vector[j]
            set vector[j] = vector[0]

            // set unit array accordingly
            set sorted[0] = sorted[i]
            set sorted[i] = sorted[j]
            set sorted[j] = sorted[0]
            set i = i + 1
            set j = j - 1
        endloop

        if ( lo < j ) then
            call sortUnits(lo, j)
        endif
        if ( hi > i ) then
            call sortUnits(i, hi)
        endif
    endfunction

    function GetFurthestNUnitsInRange takes real x, real y, real radius, integer n, group dest, boolexpr filter returns nothing
        local unit u
        call default(x, y)

        if ( radius >= 0 )then
            call GroupEnumUnitsInRange(bj_lastCreatedGroup, x, y, radius, filter)
            loop
                set u = FirstOfGroup(bj_lastCreatedGroup)
                exitwhen u == null
                call cbSaveUnits(u)
                call GroupRemoveUnit(bj_lastCreatedGroup, u)
            endloop

            set u = null
            call sortUnits(1, count)

            loop
                exitwhen count < 1 or sorted[count] == null
                if ( count <= n ) then
                    call GroupAddUnit(dest, sorted[count])
                endif
                set sorted[count] = null
                set count = count - 1
            endloop
        endif
    endfunction

    function GetFurthestNUnitsInGroup takes real x, real y, integer n, group source, group dest returns nothing
        local integer i = 0
        call default(x, y)

        call ForGroup(source, function saveUnits)
        call sortUnits(1, count)

        loop
            exitwhen count < 1 or sorted[count] == null
            if ( count <= n ) then
                call GroupAddUnit(dest, sorted[count])
            endif
            set sorted[count] = null
            set count = count - 1
        endloop
    endfunction
//! endtextmacro

//! textmacro DEFINE_GFW_MODULE takes NAME, TYPE
    globals
        private $TYPE$ furthest$NAME$ = null
    endglobals

    private function enum$NAME$s takes nothing returns nothing
        local $TYPE$ temp = GetEnum$NAME$()
        local real dist = calcDistance(Get$NAME$X(temp), Get$NAME$Y(temp))

        if ( dist < distance ) then
            set furthest$NAME$ = temp
            set distance = dist
        endif

        set temp = null
    endfunction

    function GetFurthest$NAME$ takes real x, real y, boolexpr filter returns $TYPE$
        local real r = START_DISTANCE
        call default(x, y)

        loop
            if ( r > FINAL_DISTANCE ) then
                call Enum$NAME$sInRect(bj_mapInitialPlayableArea, filter, function enum$NAME$s)
                exitwhen true
            else
                call SetRect(bj_isUnitGroupInRectRect, x-r, y-r, x+r, y+r)
                call Enum$NAME$sInRect(bj_isUnitGroupInRectRect, filter, function enum$NAME$s)
                exitwhen furthest$NAME$ != null
            endif
            set r = 2*r
        endloop

        return furthest$NAME$
    endfunction

    function GetFurthest$NAME$InRange takes real x, real y, real radius, boolexpr filter returns $TYPE$
        call default(x, y)
        if ( radius > 0 ) then
            call SetRect(bj_isUnitGroupInRectRect, x-radius, y-radius, x+radius, y+radius)
            call Enum$NAME$sInRect(bj_isUnitGroupInRectRect, filter, function enum$NAME$s)
        endif
        return furthest$NAME$
    endfunction
//! endtextmacro

endlibrary