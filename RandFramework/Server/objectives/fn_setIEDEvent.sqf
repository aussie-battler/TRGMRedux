
params ["_posOfAO",["_roadRange",2000],["_showMarker",false],["_forceTrap",false],["_objIED",nil],["_IEDType",nil],["_isFullMap",false]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (isNil "_IEDType") then {
    _IEDType = selectRandom ["CAR","CAR","RUBBLE"];
};
_ieds = nil;
If (_IEDType isEqualTo "CAR") then {_ieds = CivCars;};
If (_IEDType isEqualTo "RUBBLE") then {_ieds = TRGM_VAR_IEDFakeClassNames;};

_nearestRoads = _posOfAO nearRoads _roadRange;
if ((!(isNil "IsTraining") || _isFullMap) && _roadRange isEqualTo 2000) then {
    _nearestRoads = _posOfAO nearRoads 30000;
};

if (count _nearestRoads > 0) then {

    _eventLocationPos = [0,0,0]; //getPos (selectRandom _nearestRoads);
    _eventPosFound = false;
    _iAttemptLimit = 5;
    if (!isNil "TRGM_VAR_WarzonePos") then {
        while {!_eventPosFound && _iAttemptLimit > 0} do {
            _eventLocationPos = getPos (selectRandom _nearestRoads);
            if (_eventLocationPos distance TRGM_VAR_WarzonePos > 500) then {_eventPosFound = true;};
            _iAttemptLimit = _iAttemptLimit - 1;
        };
    }
    else {
        _eventLocationPos = getPos (selectRandom _nearestRoads);
    };

    if (_eventLocationPos select 0 > 0) then {

        _bIsTrap = random 1 < .33;
        if (_forceTrap) then {
            _bIsTrap = true;
        };
        //_bIsTrap = true;
        _bHasHidingAmbush = false;
        _thisAreaRange = 50;
        _nearestRoads = _eventLocationPos nearRoads _thisAreaRange;

        _nearestRoad = nil;
        _roadConnectedTo = nil;
        _connectedRoad = nil;
        _direction = nil;
        _PosFound = false;
        _iAttemptLimit = 5;

        _direction = nil;
        while {!_PosFound && _iAttemptLimit > 0 && count _nearestRoads > 0} do {
            _nearestRoad = selectRandom _nearestRoads;
            _roadConnectedTo = roadsConnectedTo _nearestRoad;
            if (count _roadConnectedTo > 0) then {
                _connectedRoad = _roadConnectedTo select 0;
                _direction = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
                _PosFound = true;
            }
            else {
                _iAttemptLimit = _iAttemptLimit - 1;
            };
        };
    //[format["A: %1 - %2",_iteration,_eventLocationPos]] call TRGM_GLOBAL_fnc_notify;
        if (_PosFound) then {


            _roadBlockPos =  getPos _nearestRoad;
            _roadBlockSidePos = _nearestRoad getPos [3, ([_direction,90] call TRGM_GLOBAL_fnc_addToDirection)];

            _mainVeh = nil;
            if (isNil "_objIED") then {
                _mainVeh = createVehicle [selectRandom _ieds,_roadBlockSidePos,[],0,"NONE"];
            }
            else {
                _mainVeh = _objIED;
                _mainVeh setPos _roadBlockSidePos;
            };
            _mainVeh setVariable ["isDefused",false];
            //_mainVeh setVehicleLock "LOCKED";
            _mainVehDirection =  ([_direction,(selectRandom[0,-10,10])] call TRGM_GLOBAL_fnc_addToDirection);
            _mainVeh setDir _mainVehDirection;
            clearItemCargoGlobal _mainVeh;

            if (_showMarker) then {
                _markerstrcache = createMarker [format ["IEDLoc%1",_eventLocationPos select 0],([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos)];
                _markerstrcache setMarkerShape "ICON";
                if (_bIsTrap) then {
                    _markerstrcache setMarkerText localize "STR_TRGM2_IEDMarkerText";
                }
                else {
                    _markerstrcache setMarkerText "";
                };
                _markerstrcache setMarkerType "hd_dot";
            };


            [
                _mainVeh,                                            // Object the action is attached to
                localize "STR_TRGM2_IEDSearchIED",                                        // Title of the action
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",    // Idle icon shown on screen
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",    // Progress icon shown on screen
                "_this distance _target < 5",                        // Condition for the action to be shown
                "_caller distance _target < 5",                        // Condition for the action to progress
                {},                                                    // Code executed when action starts
                {
                    _thisVeh = _this select 0;
                    _IEDType = (_this select 3) select 1;
                    _alarmActive = _thisVeh getVariable ["alarmActive",false];
                    if (floor (random 30) isEqualTo 0 && _IEDType isEqualTo "CAR" && !_alarmActive) then {
                        [_thisVeh] spawn {
                            _thisVeh = _this select 0;
                            _thisVeh setVariable ["alarmActive",true, true];
                            _beepLimit = 20;
                            _endLoop = false;
                            while {!_endLoop && alive _thisVeh && _thisVeh getVariable ["alarmActive",false]} do {
                                playSound3D ["a3\sounds_f\weapons\horns\truck_horn_2.wss", _thisVeh];
                                sleep 1;
                                _beepLimit = _beepLimit - 1;
                                if (_beepLimit < 1) then {_endLoop = true;};
                            };
                        };
                    };
                },            // Code executed on every progress tick
                {
                    _thisVeh = _this select 0;
                    _thisPlayer = _this select 1;
                    _bIsTrap = (_this select 3) select 0;
                    if (_thisPlayer getVariable "unitrole" != "Engineer" && random 1 < .60) then {
                        [localize "STR_TRGM2_IEDSearchFailed"] call TRGM_GLOBAL_fnc_notify;
                    }
                    else {
                        if (_bIsTrap) then {
                            [localize "STR_TRGM2_IEDSearchFound"] call TRGM_GLOBAL_fnc_notify;
                            [
                                _thisVeh,                                            // Object the action is attached to
                                localize "STR_TRGM2_IEDDefuse",                                        // Title of the action
                                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",    // Idle icon shown on screen
                                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",    // Progress icon shown on screen
                                "_this distance _target < 5",                        // Condition for the action to be shown
                                "_caller distance _target < 5",                        // Condition for the action to progress
                                {},                                                    // Code executed when action starts
                                {},            // Code executed on every progress tick
                                {
                                    _thisVeh = _this select 0;
                                    _thisPlayer = _this select 1;
                                    _bIsTrap = (_this select 3) select 0;
                                    if (_thisPlayer getVariable "unitrole" != "Engineer" && random 1 < .25) then {
                                        [localize "STR_TRGM2_IEDOhOh"] call TRGM_GLOBAL_fnc_notify;
                                        sleep 1;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 0.6;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 0.5;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 0.4;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 0.3;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 0.2;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 0.1;
                                        playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                        sleep 1;
                                        //BOOM
                                        _type = selectRandom ["Bomb_03_F","Missile_AA_04_F","M_Mo_82mm_AT_LG","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo"];
                                          _li_aaa = _type createVehicle ([_thisVeh] call TRGM_GLOBAL_fnc_getRealPos);
                                        _li_aaa setDamage 1;
                                        sleep 1;
                                        _thisVeh setVariable ["isDefused",true, true];
                                        sleep 4;
                                        [localize "STR_TRGM2_IEDOneWay"] call TRGM_GLOBAL_fnc_notifyGlobal;
                                    }
                                    else {
                                        _thisVeh setVariable ["isDefused",true, true];
                                        [0.2, localize "STR_TRGM2_IEDDefused"] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
                                        removeAllActions _thisVeh;
                                        [localize "STR_TRGM2_IEDDefused"] call TRGM_GLOBAL_fnc_notifyGlobal;
                                    }
                                },                // Code executed on completion
                                {},                                                    // Code executed on interrupted
                                [],                                // Arguments passed to the scripts as _this select 3
                                6,                            // Action duration [s]
                                100,                                                    // Priority
                                false,                                                // Remove on completion
                                false                                                // Show in unconscious state
                            ] remoteExec ["BIS_fnc_holdActionAdd", 0, _thisVeh];    // MP compatible implementation
                        }
                        else {
                            [localize "STR_TRGM2_IEDNoneFound"] call TRGM_GLOBAL_fnc_notify;
                        };
                    }
                },                // Code executed on completion
                {},                                                    // Code executed on interrupted
                [_bIsTrap,_IEDType],                                // Arguments passed to the scripts as _this select 3
                6,                                                    // Action duration [s]
                90,                                                    // Priority
                false,                                                // Remove on completion
                false                                                // Show in unconscious state
            ] remoteExec ["BIS_fnc_holdActionAdd", 0, _mainVeh];    // MP compatible implementation


            _spawnedUnit = nil;
            if (_bIsTrap) then {

                if (random 1 < .25) then {
                    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingAmbush;
                    _bHasHidingAmbush = true;
                };
                if (random 1 < .20) then {
                    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
                };
                if (random 1 < .50) then {
                    [_eventLocationPos] spawn TRGM_SERVER_fnc_createEnemySniper;
                };

                _allowAPTraps = true;
                _mainVehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
                {
                    if (_x distance _mainVehPos < 800) then {
                        _allowAPTraps = false;
                    };
                } forEach TRGM_VAR_ObjectivePossitions;
                if (random 1 < .33 && _allowAPTraps) then {
                    _minesPlaced = false;
                    _iCountMines = 20;
                    _mainVehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
                    while {_iCountMines > 0} do {

                        _xPos = (_mainVehPos select 0)-40;
                        _yPos = (_mainVehPos select 1)-40;
                        _randomPos = [_xPos+(random 80),_yPos+(random 80),0];
                        if (!isOnRoad _randomPos) then {
                            //APERSMine ATMine
                            _objMine = createMine [selectRandom["APERSMine"], _randomPos, [], 0];
                            if ("TEST" isEqualTo "FALSE") then {
                                _markerstrcache = createMarker [format ["IEDMineLoc%1",floor random 999999],_randomPos];
                                _markerstrcache setMarkerShape "ICON";
                                _markerstrcache setMarkerType "hd_dot";
                                _markerstrcache setMarkerText "";
                            };
                        };
                        _iCountMines = _iCountMines - 1;
                    };
                };
            };


            //set veh damage;
            //if (random 1 < .50) then {_mainVeh setHit ["engine",0.75];};
            _mainVeh setFuel 0;
            if (random 1 < .50) then {_mainVeh setHit ["wheel_1_1_steering",1];};
            if (random 1 < .50) then {_mainVeh setHit ["wheel_1_2_steering",1];};
            if (random 1 < .50) then {_mainVeh setHit ["wheel_2_1_steering",1];};
            if (random 1 < .50) then {_mainVeh setHit ["wheel_2_2_steering",1];};
            _mainVeh setDamage selectRandom[0,0.7];

            _bWaiting = true;
            while {_bWaiting} do {


                if (!(alive _mainVeh) || _mainVeh getVariable ["isDefused",false]) then {
                    _bWaiting = false;
                };

                    //_bIsTrap
                  if (_bIsTrap) then {
                      //LandVehicle
                      if (alive _mainVeh) then {
                        _nearUnits = nearestObjects [(_roadBlockSidePos), ["LandVehicle"], 10];
                        {
                            if (((driver _x) in switchableUnits || (driver _x) in playableUnits) && (alive _mainVeh)) then {
                                if (true) then {
                                    _type = selectRandom ["Bomb_03_F","Missile_AA_04_F","M_Mo_82mm_AT_LG","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo"];
                                    _li_aaa = _type createVehicle ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
                                    _li_aaa setDamage 1;
                                    _mainVeh setVariable ["isDefused",true, true];
                                    [localize "STR_TRGM2_IEDOmteresting"] call TRGM_GLOBAL_fnc_notifyGlobal;
                                };
                            };
                            if (!_bWaiting) exitWith {true};
                        } forEach _nearUnits;
                      };
                };

                  if (_bWaiting) then {
                    sleep 1;
                };
            };


        };
    }
    else {
        if (!isNil "_objIED") then {
            deleteVehicle _objIED;
        };
    };
};

true;