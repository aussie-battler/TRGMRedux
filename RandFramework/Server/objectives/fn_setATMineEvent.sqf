params ["_posOfAO",["_isFullMap",false]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

_currentATFieldPos = [_posOfAO , 1000, 1700, 100, 0, 0.4, 0,TRGM_VAR_AreasBlackList,[[0,0,0],[0,0,0]]] call TRGM_GLOBAL_fnc_findSafePos;

if (!(isNil "IsTraining") || _isFullMap) then {
    _currentATFieldPos = [_posOfAO , 30000, 1700, 100, 0, 0.4, 0,TRGM_VAR_AreasBlackList,[[0,0,0],[0,0,0]]] call TRGM_GLOBAL_fnc_findSafePos;
};

if (_currentATFieldPos select 0 != 0) then {

    TRGM_VAR_ATFieldPos pushBack _currentATFieldPos;

    _minesPlaced = false;
    _iCountMines = 0;
    while {!_minesPlaced} do {

        _xPos = (_currentATFieldPos select 0)-100;
        _yPos = (_currentATFieldPos select 1)-100;
        _randomPos = [_xPos+(random 200),_yPos+(random 200),0];
//APERSMine ATMine
        _objMine = createMine [selectRandom["ATMine"], _randomPos, [], 0];
        if ("TEST" isEqualTo "FALSE") then {
            _markerstrcache = createMarker [format ["CacheLoc%1",_iCountMines],_randomPos];
            _markerstrcache setMarkerShape "ICON";
            _markerstrcache setMarkerType "hd_dot";
            _markerstrcache setMarkerText "";
        };
        _iCountMines = _iCountMines + 1;
        if (_iCountMines >= 50) then {_minesPlaced = true};
    };

    if (random 1 < .20) then {
        [_currentATFieldPos,200,250] spawn TRGM_SERVER_fnc_createWaitingAmbush;
    };

    if (random 1 < .20) then {
    //if (true) then {
        _mainVeh = createVehicle [selectRandom (call FriendlyScoutVehicles),_currentATFieldPos,[],0,"NONE"];
        _mainVeh setDir (floor random 360);
        clearItemCargoGlobal _mainVeh;
        if (random 1 < .50) then {_mainVeh setHit ["wheel_1_1_steering",1];};
            if (random 1 < .50) then {_mainVeh setHit ["wheel_1_2_steering",1];};
            if (random 1 < .50) then {_mainVeh setHit ["wheel_2_1_steering",1];};
            if (random 1 < .50) then {_mainVeh setHit ["wheel_2_2_steering",1];};
            if (((_mainVeh getHit "wheel_1_1_steering") < 0.5) && ((_mainVeh getHit "wheel_1_2_steering") < 0.5) && ((_mainVeh getHit "wheel_2_1_steering") < 0.5) && ((_mainVeh getHit "wheel_2_2_steering") < 0.5)) then {
                _mainVeh setHit ["wheel_1_1_steering",1];
        };

        _pos1 = _mainVeh getPos [5,(floor random 360)];
        _pos2 = _mainVeh getPos [5,(floor random 360)];
        _group = createGroup TRGM_VAR_FriendlySide;
        _sUnitType = selectRandom (call FriendlyCheckpointUnits);

        _guardUnit1 = _group createUnit [_sUnitType,_pos1,[],0,"NONE"];
        doStop [_guardUnit1];
        _guardUnit1 setDir (floor random 360);
         [_guardUnit1,"WATCH","ASIS"] call BIS_fnc_ambientAnimCombat;

         _guardUnit2 = _group createUnit [_sUnitType,_pos2,[],0,"NONE"];
        doStop [_guardUnit2];
        _guardUnit2 setDir (floor random 360);
         [_guardUnit2,"WATCH","ASIS"] call BIS_fnc_ambientAnimCombat;

        [_guardUnit1, ["Ask if needs assistance",{
            _guardUnit1 = _this select 0;
            if (alive _guardUnit1) then {
                ["We are stranded in the middle of an AT mine area.  please help move this car ovrt 100 meters in any direction from here!"] call TRGM_GLOBAL_fnc_notify;
            }
            else {
                ["Is there a reason you are trying to talk to a dead guy??"] call TRGM_GLOBAL_fnc_notify;
            }
        },[_guardUnit1]]] remoteExec ["addAction", 0, true];

         [_mainVeh,_guardUnit1,_group] spawn {
             _mainVeh = _this select 0;
             _guardUnit1 = _this select 1;
             _group = _this select 2;
             _bWaiting = true;
            _bWaveDone = false;
            while {_bWaiting} do {
                if (!(alive _mainVeh)) then {
                    _bWaiting = false;
                }
                else {
                    if (!_bWaveDone) then {
                        _nearUnits = nearestObjects [(getPos _guardUnit1), ["Man","Car","Helicopter"], 100];
                        //(driver ((nearestObjects [(getPos box1), ["car"], 20]) select 0)) in switchableUnits
                          {
                              if ((driver _x) in switchableUnits || (driver _x) in playableUnits) then {
                                  _bWaveDone = true;

                                //[] spawn {};
                                [[_guardUnit1,_group],{
                                    _guardUnit1 = _this select 0;
                                    _group = _this select 1;
                                    _guardUnit1 enableAI "anim";
                                      _guardUnit1 switchMove "";
                                      _guardUnit1 setBehaviour "CARELESS";
                                    _group setSpeedMode "FULL";
                                    _guardUnit1 setUnitPos "UP";
                                }] remoteExec ["spawn", 0];
                                sleep 0.5;
                                if (alive _guardUnit1) then {
                                    _dirToPlayer = ([_guardUnit1, _x] call BIS_fnc_DirTo);
                                    _moveToPos = _guardUnit1 getPos [6,_dirToPlayer];
                                    _guardUnit1 doMove _moveToPos;
                                    sleep 3;
                                    _guardUnit1 setDir _dirToPlayer;
                                    [_guardUnit1, ""] remoteExec ["switchMove", 0];
                                    sleep 0.1;
                                    [_guardUnit1, "Acts_JetsShooterNavigate_loop"] remoteExec ["switchMove", 0];
                                    _guardUnit1 disableAI "anim";
                                    [_guardUnit1] spawn {
                                        _guardUnit1 = _this select 0;
                                        waitUntil {sleep 2; !alive(_guardUnit1)};
                                        [_guardUnit1, ""] remoteExec ["switchMove", 0];
                                    };
                                    sleep 20;
                                    _guardUnit1 enableAI "anim";
                                    _guardUnit1 switchMove "";
                                };
                              };
                               if (_bWaveDone) exitWith {true};
                          } forEach _nearUnits;
                      };
                      if (_bWaveDone) then {
                          if ((_mainVeh distance _guardUnit1) > 100) then {
                              ["Thank you for your help"] call TRGM_GLOBAL_fnc_notifyGlobal;
                              [_guardUnit1] remoteExecCall ["removeAllActions", 0];
                              [0.2, "Helped a stranded friendly"] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
                              _bWaiting = false;
                          };
                      };
                };
                if (_bWaiting) then {
                    sleep 1;
                };
            };
        };
    };
};

true;