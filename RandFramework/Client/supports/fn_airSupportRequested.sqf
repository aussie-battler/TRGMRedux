
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
[0.1,localize "STR_TRGM2_AirSupportRequested_Text"] spawn TRGM_GLOBAL_fnc_adjustBadPoints;