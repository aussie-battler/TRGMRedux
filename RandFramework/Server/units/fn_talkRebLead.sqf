// private _fnc_scriptName = "TRGM_SERVER_fnc_talkRebLead";
params ["_thisCiv", "_caller"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (side _caller isEqualTo TRGM_VAR_FriendlySide) then {

    [_thisCiv] remoteExec ["removeAllActions", 0, true];

    if (alive _thisCiv) then {

        private _azimuth = _thisCiv getDir _caller;
        _thisCiv setDir _azimuth;
        _thisCiv switchMove "Acts_StandingSpeakingUnarmed";
        sleep 3;
        [TRGM_VAR_IntelShownType,"TalkRebLead"] spawn TRGM_GLOBAL_fnc_showIntel;
        sleep 2;
        [TRGM_VAR_IntelShownType,"TalkRebLead"] spawn TRGM_GLOBAL_fnc_showIntel;
        sleep 10;
        _thisCiv switchMove "";

    }
    else {
        ["This guy doesnt seem to want to speak much in his current state!!!"] call TRGM_GLOBAL_fnc_notify;
    };
};



true;