params ["_thisCheckpointUnit", "_caller", "_id", "_thisArrayParams"];
format["%1 called by %2", _fnc_scriptName, _fnc_scriptNameParent] call TRGM_GLOBAL_fnc_log;

if (side _caller isEqualTo TRGM_VAR_FriendlySide) then {

    _CheckpointPos = _thisArrayParams select 0;

    [_thisCheckpointUnit] remoteExec ["removeAllActions", 0, true];


    if (alive _thisCheckpointUnit) then {
        [TRGM_VAR_IntelShownType,"TalkFriendCheckPoint"] spawn TRGM_GLOBAL_fnc_showIntel;

    }
    else {
        ["He doesnt seem to be saying much at this time"] call TRGM_GLOBAL_fnc_notify;
    };


};

true;