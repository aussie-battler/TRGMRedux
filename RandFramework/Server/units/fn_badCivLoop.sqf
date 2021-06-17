params ["_badCiv"];
format["%1 called by %2", _fnc_scriptName, _fnc_scriptNameParent] call TRGM_GLOBAL_fnc_log;

(_badCiv getVariable "armament") params ["_gun","_magazine","_amount"];

_bFired = false;
_bActivated = false;

// continiously watch for players and decide to engage or not
while {alive _badCiv && !_bFired} do {
    {
        if ((_x in playableUnits)) then {
            if (random 1 < .33) then {
                //load armament

                if (!_bActivated) then {
                    _bActivated = true;
                    _grpName = createGroup east;
                    [_badCiv] joinSilent _grpName;

                    [_badCiv] call TRGM_SERVER_fnc_badCivApplyAssingnedArmament;

                    _badCiv allowFleeing 0;
                };
                _cansee = [objNull, "VIEW"] checkVisibility [eyePos _badCiv, eyePos _x];
                if (_cansee > 0.2) then {
                    _badCiv doTarget _x;
                    _badCiv commandFire _x; //LOCAL - ?

                    sleep 3;
                    _badCiv fire _gun;
                    sleep 1;
                    _badCiv fire _gun;
                    sleep 1;
                    _badCiv fire _gun;
                    _bFired = true;
                };

            };
        };

    } forEach (nearestObjects [([_badCiv] call TRGM_GLOBAL_fnc_getRealPos),["Man"],10]);
    sleep 2;
};


true;