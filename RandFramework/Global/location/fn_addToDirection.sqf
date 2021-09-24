
params ["_origDirection","_addToDirection"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


if (isNil "_origDirection" || isNil "_addToDirection") exitWith {};

private _iResult = _origDirection + _addToDirection;
if (_iResult > 360) then {
    _iResult = _iResult - 360;
};
if (_origDirection+_addToDirection < 0) then {
    _iResult = 360 + _iResult;
};
_iResult;
