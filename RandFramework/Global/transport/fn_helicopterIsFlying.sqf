params ["_vehicle"];
format["%1 called by %2", _fnc_scriptName, _fnc_scriptNameParent] call TRGM_GLOBAL_fnc_log;

!((isTouchingGround _vehicle) || {((([_vehicle] call TRGM_GLOBAL_fnc_getRealPos) select 2) < 2 && {(speed _vehicle) < 1})});

