params ["_vehicle","_checkToMissionNumber"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


(_checkToMissionNumber isEqualTo (_vehicle getVariable ["missionNr",-1]));