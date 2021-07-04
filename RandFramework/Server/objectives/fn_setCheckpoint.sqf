
params [
    "_thisAOPos",
    "_thisPosAreaOfCheckpoint",
    ["_thisAreaRange", 100],
    ["_thisRoadOnly", true],
    ["_thisSide", EAST],
    ["_thisUnitTypes", []],
    ["_thisAllowBarakade", false],
    ["_thisIsDirectionAwayFromAO", true],
    ["_thisIsCheckPoint", false], // only used to store possitions in our checkpointareas and sentryareas arrays
    ["_thisScoutVehicles", []],
    ["_thisAreaAroundCheckpointSpacing", 50],
    ["_AllowAnimation", true],
    ["_AllowVeh", true],
    ["_AllowTurrent", true],
    ["_isForceTents",false]
];
format["%1 called by %2", _fnc_scriptName, _fnc_scriptNameParent] call TRGM_GLOBAL_fnc_log;

if (isNil "_thisAOPos" || isNil "_thisPosAreaOfCheckpoint") exitWith {};

if (_thisUnitTypes isEqualTo []) then {
    _thisUnitTypes = [(call sRifleman), (call sRifleman), (call sRifleman), (call sMachineGunMan), (call sEngineer), (call sEngineer), (call sMedic), (call sAAMan)];
};

if (_thisScoutVehicles isEqualTo []) then {
    _thisScoutVehicles = (call UnarmedScoutVehicles);
};

_startPos = _thisPosAreaOfCheckpoint;
_nearestRoads = _startPos nearRoads _thisAreaRange;

_nearestRoad = nil;
_roadConnectedTo = nil;


_connectedRoad = nil;
_direction = nil;

_PosFound = false;
_iAttemptLimit = 5;

if (_thisRoadOnly) then {

    while {!_PosFound && _iAttemptLimit > 0 && count _nearestRoads > 0} do {
        _nearestRoad = selectRandom _nearestRoads;
        _roadConnectedTo = roadsConnectedTo _nearestRoad;
        if (count _roadConnectedTo isEqualTo 2) then {


            _connectedRoad = _roadConnectedTo select 0;
            _generalDirection = [_thisAOPos, _nearestRoad] call BIS_fnc_DirTo;
            _direction1 = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
            _direction2 = _direction1-180;
            if (_direction2 < 0) then {_direction2 = _direction2 + 360};
            _direction = 0;

            _dif1 = 0;
            _dif1A = _direction1 - _generalDirection;
            if (_dif1A < 0) then {_dif1A = _dif1A + 360};
            _dif1B = _generalDirection - _direction1;
            if (_dif1B < 0) then {_dif1B = _dif1B + 360};
            if (_dif1A < _dif1B) then {
                _dif1 = _dif1A;
            }
            else {
                _dif1 = _dif1B;
            };

            _dif2 = 0;
            _dif2A = _direction2 - _generalDirection;
            if (_dif2A < 0) then {_dif2A = _dif2A + 360};
            _dif2B = _generalDirection - _direction2;
            if (_dif2B < 0) then {_dif2B = _dif2B + 360};
            if (_dif2A < _dif2B) then {
                _dif2 = _dif2A;
            }
            else {
                _dif2 = _dif2B;
            };



            //[format["AOAwayDir:%1 - dir1:%2 - dir2:%3  \nDif1:%4 - dif2:%5",_generalDirection,_direction1,_direction2,_dif1,_dif2]] call TRGM_GLOBAL_fnc_notify;
            //sleep 5;


            if (_dif1 < _dif2) then {
                _direction = _direction1
            }
            else {
                _direction = _direction2
            };
            _PosFound = true;

        }
        else {
            //run loop again
            //["Too many roads"] call TRGM_GLOBAL_fnc_notify;

            _iAttemptLimit = _iAttemptLimit - 1;
        };
    };
};

if (!_thisRoadOnly || !_PosFound) then {
    _thisRoadOnly = false;
    _thisIsCheckPoint = false;
    _generalDirection = [_thisAOPos, _thisPosAreaOfCheckpoint] call BIS_fnc_DirTo;
    _dirAdd = 0;
    if (random 1 < .50) then {
        _dirAdd = floor(random 40);
    }
    else {
        _dirAdd = -floor(random 40);
    };
    _direction = ([_generalDirection,_dirAdd] call TRGM_GLOBAL_fnc_addToDirection);
    _PosFound = true;
    //[format["DIR:%1",_direction]] call TRGM_GLOBAL_fnc_notify;
    //sleep 3;
};

if (_PosFound) then {



    if (!_thisIsDirectionAwayFromAO) then {
        _direction = ([_direction,180] call TRGM_GLOBAL_fnc_addToDirection);
    };
    _RoadSideBarricadesHigh = ["Land_Barricade_01_4m_F"];
    _RoadSideBarricadesLow = ["Land_BagFence_Long_F","Land_BagBunker_Small_F"];
    _FullRoadBarricades = ["Land_Barricade_01_10m_F"];
    _DefensiveObjects = ["Land_Barricade_01_4m_F","Land_BagFence_Long_F"];

    _initItem = nil;
    _BarrierToUse = "";

    _iBarricadeType = selectRandom ["HIGH","FULL","LOW","LOW"];

    _roadBlockPos =  nil;
    _roadBlockSidePos = nil;

    _NoRoadsOrBuildingsNear = false;

    if (_thisRoadOnly) then {
        _roadBlockPos =  getPos _nearestRoad;
        _roadBlockSidePos = _nearestRoad getPos [10, ([_direction,90] call TRGM_GLOBAL_fnc_addToDirection)];
    }
    else {
        _flatPos = nil;
        _flatPos = [_thisPosAreaOfCheckpoint , 0, 50, 20, 0, 0.2, 0,[],[_thisPosAreaOfCheckpoint,_thisPosAreaOfCheckpoint]] call TRGM_GLOBAL_fnc_findSafePos;
        _roadBlockPos = _flatPos;
        _roadBlockSidePos = _flatPos;
        _allRoadsNear = _flatPos nearRoads 500;
        _nearestHouseCount = count(nearestObjects [_flatPos, ["building"],400]);
        if (count _allRoadsNear isEqualTo 0 && _nearestHouseCount isEqualTo 0) then {_NoRoadsOrBuildingsNear = true;};
    };

    if ({_x distance _roadBlockPos < 250 && side _x != _thisSide} count allUnits > 0) exitWith {false;};

    if (_thisIsCheckPoint && _thisSide isEqualTo TRGM_VAR_EnemySide) then {
        //TRGM_VAR_CheckPointAreas
        TRGM_VAR_CheckPointAreas = TRGM_VAR_CheckPointAreas + [[_roadBlockPos,_thisAreaAroundCheckpointSpacing]]; //the ,_thisAreaAroundCheckpointSpacing is for when we use TRGM_GLOBAL_fnc_findSafePos to make sure no other road block is within 100 meters
        publicVariable "TRGM_VAR_CheckPointAreas";
    }
    else {
        if (_thisSide isEqualTo TRGM_VAR_EnemySide) then {
        //TRGM_VAR_SentryAreas
            TRGM_VAR_SentryAreas = TRGM_VAR_SentryAreas + [[_roadBlockPos,_thisAreaAroundCheckpointSpacing]];
            publicVariable "TRGM_VAR_SentryAreas"
        };
    };

    if (_thisSide isEqualTo TRGM_VAR_FriendlySide) then {
        TRGM_VAR_friendlySentryCheckpointPos = TRGM_VAR_friendlySentryCheckpointPos + [_roadBlockPos];
        publicVariable "TRGM_VAR_friendlySentryCheckpointPos";
    };



    _slope = abs(((getTerrainHeightASL _roadBlockSidePos)) - ((getTerrainHeightASL  _roadBlockPos)));
    if (_slope > 0.6) then {
        _iBarricadeType = "FULL"; //if slope too much, then bunker and other barricades on side of road will have gap on one side
    };

    _nearestHouseObjectDist = (nearestObject [_roadBlockSidePos, "building"]) distance _roadBlockSidePos;
    //_nearestWallObjectDist = (nearestObject [_roadBlockSidePos, "wall"]) distance _roadBlockSidePos;
    //[format["nearestWallObjectDist: %1",_nearestHouseObjectDist]] call TRGM_GLOBAL_fnc_notify;
    //sleep 2;
    if (_nearestHouseObjectDist < 10) then {
        _iBarricadeType = "FULL"; //if slope too much, then bunker and other barricades on side of road will have gap on one side
    };
    if (_NoRoadsOrBuildingsNear) then {
        _iBarricadeType = "LOW";
    };
    if (!_thisAllowBarakade) then {
        _iBarricadeType = "NONE";
    };

    if (_iBarricadeType isEqualTo "HIGH") then {
        _initItem = selectRandom _RoadSideBarricadesHigh createVehicle _roadBlockSidePos;
        _initItem setDir ([_direction,180] call TRGM_GLOBAL_fnc_addToDirection);
    };
    if (_iBarricadeType isEqualTo "FULL") then {
        _initItem = selectRandom _FullRoadBarricades createVehicle _roadBlockPos;
        _initItem setDir ([_direction,180] call TRGM_GLOBAL_fnc_addToDirection);
    };
    if (_iBarricadeType isEqualTo "LOW") then {
        _initItem = selectRandom _RoadSideBarricadesLow createVehicle _roadBlockSidePos;
        _initItem setDir ([_direction,180] call TRGM_GLOBAL_fnc_addToDirection);

        if (_thisSide isEqualTo TRGM_VAR_EnemySide && _AllowTurrent) then {
            _NearTurret1 = createVehicle [selectRandom (call CheckPointTurret), _initItem getPos [1,_direction+180], [], 0, "CAN_COLLIDE"];
            _NearTurret1 setDir (_direction);
            createVehicleCrew _NearTurret1;
            crew vehicle _NearTurret1 joinSilent createGroup _thisSide;
        };
    };
    if (_iBarricadeType isEqualTo "NONE") then {  //if none, then either use flag or defensive object
        //FlagCarrierTakistan_EP1, FlagCarrierTKMilitia_EP1
        if (!(isOnRoad _roadBlockSidePos) && random 1 < .50) then {
            _initItem = selectRandom _DefensiveObjects createVehicle _roadBlockSidePos;
            _initItem setDir ([_direction,180] call TRGM_GLOBAL_fnc_addToDirection);
        }
        else {
            _initItem = "Land_HelipadEmpty_F" createVehicle _roadBlockSidePos;
            _initItem setDir ([_direction,180] call TRGM_GLOBAL_fnc_addToDirection);
        };

    };
    if (!TRGM_VAR_ISUNSUNG) then {
        if (_iBarricadeType != "NONE" && random 1 < .50) then {
            [_initItem,_thisSide] spawn {
                _initItem = _this select 0;
                _thisSide = _this select 1;
                while {alive(_initItem)} do {
                    _soundToPlay = selectRandom TRGM_VAR_EnemyRadioSounds;
                    if (_thisSide isEqualTo TRGM_VAR_FriendlySide) then {_soundToPlay = selectRandom TRGM_VAR_FriendlyRadioSounds};
                    playSound3D ["A3\Sounds_F\sfx\radio\" + _soundToPlay + ".wss",_initItem,false,getPosASL _initItem,0.5,1,0];
                    sleep selectRandom [10,15,20,30];
                };
            };
        };
    };

    _bHasParkedCar = false;
    _ParkedCar = nil;
    if (_AllowVeh && (random 1 < .75 || _thisSide isEqualTo TRGM_VAR_FriendlySide)) then {
        _behindBlockPos = _initItem getPos [10,([_direction,180] call TRGM_GLOBAL_fnc_addToDirection)];
        _flatPos = nil;
        _flatPos = [_behindBlockPos , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],selectRandom _thisScoutVehicles] call TRGM_GLOBAL_fnc_findSafePos;
        _ParkedCar = selectRandom _thisScoutVehicles createVehicle _flatPos;
        _ParkedCar setDir (floor(random 360));
        sleep 0.1;
        if (damage _ParkedCar > 0) then {
            _bHasParkedCar = false;
            deleteVehicle _ParkedCar;
        };
        _bHasParkedCar = true;
    };
    if (_NoRoadsOrBuildingsNear) then {
        if (random 1 < .75 || _isForceTents) then {
            _behindBlockPos = _initItem getPos [15,([_direction,180] call TRGM_GLOBAL_fnc_addToDirection)];
            _flatPos = nil;
            _flatPos = [_behindBlockPos , 0, 15, 10, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Land_TentA_F"] call TRGM_GLOBAL_fnc_findSafePos;
            _Tent1 = "Land_TentA_F" createVehicle _flatPos;
            _Tent1 setDir (floor(random 360));

            _flatPos2 = nil;
            _flatPos2 = [([_Tent1] call TRGM_GLOBAL_fnc_getRealPos) , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Land_TentA_F"] call TRGM_GLOBAL_fnc_findSafePos;
            _Tent2 = "Land_TentA_F" createVehicle _flatPos2;
            _Tent2 setDir (floor(random 360));

            _flatPos3 = nil;
            _flatPos3 = [([_Tent1] call TRGM_GLOBAL_fnc_getRealPos) , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Campfire_burning_F"] call TRGM_GLOBAL_fnc_findSafePos;
            _Tent3 = "Campfire_burning_F" createVehicle _flatPos2;
            _Tent3 setDir (floor(random 360));

            _flatPos4 = nil;
            _flatPos4 = [([_Tent1] call TRGM_GLOBAL_fnc_getRealPos) , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Land_WoodPile_F"] call TRGM_GLOBAL_fnc_findSafePos;
            _Tent4 = "Land_WoodPile_F" createVehicle _flatPos2;
            _Tent4 setDir (floor(random 360));

        }
    };
    _behindBlockPos2 = _initItem getPos [3,([_direction,180] call TRGM_GLOBAL_fnc_addToDirection)];
    if (random 1 < .75) then {

        _flatPos = nil;
        _flatPos = [_behindBlockPos2 , 0, 5, 7, 0, 0.5, 0,[],[_behindBlockPos2,_behindBlockPos2],"Land_PortableLight_single_F"] call TRGM_GLOBAL_fnc_findSafePos;
        _FloodLight = "Land_PortableLight_single_F" createVehicle _flatPos;
        _FloodLight setDir (([_direction,180] call TRGM_GLOBAL_fnc_addToDirection));
    };
    //Land_PortableLight_single_F

    if (TRGM_VAR_ISUNSUNG) then {
        if (random 1 < .66) then {
            _flatPos = nil;
            _flatPos = [_behindBlockPos2 , 0, 5, 7, 0, 0.5, 0,[],[_behindBlockPos2,_behindBlockPos2]] call TRGM_GLOBAL_fnc_findSafePos;
            _radio = nil;
            if (_thisSide isEqualTo TRGM_VAR_FriendlySide) then {
                _radio = selectRandom ["uns_radio2_radio","uns_radio2_transitor","uns_radio2_transitor02"] createVehicle _flatPos;
            }
            else {
                _radio = selectRandom ["uns_radio2_transitor_NVA","uns_radio2_transitor_NVA","uns_radio2_nva_radio","uns_radio2_recorder"] createVehicle _flatPos;
            };
            _radio setDir (([_direction,180] call TRGM_GLOBAL_fnc_addToDirection));
        };
    };


    //_pos1 = _initItem getPos [3,100];
    _pos1 = _initItem getPos [3,([_direction,100] call TRGM_GLOBAL_fnc_addToDirection)];

    _pos2 = _initItem getPos [4,([_direction,80] call TRGM_GLOBAL_fnc_addToDirection)];
    _group = createGroup _thisSide;
    _group setFormDir _direction;

    _sUnitType = selectRandom _thisUnitTypes;
    _guardUnit1 = _group createUnit [_sUnitType,_pos1,[],0,"NONE"];
    doStop [_guardUnit1];
    _guardUnit1 setDir (_direction);
     if (_AllowAnimation) then {[_guardUnit1,"WATCH","ASIS"] call BIS_fnc_ambientAnimCombat;};
    //["HMM2"] call TRGM_GLOBAL_fnc_notify;
    if (random 1 < .66) then {
        _sUnitType = selectRandom _thisUnitTypes;
        _guardUnit2 = _group createUnit [_sUnitType,_pos2,[],0,"NONE"];
        doStop [_guardUnit2];
        _guardUnit2 setDir (_direction);
        //[_guardUnit2,"STAND","ASIS"] call BIS_fnc_ambientAnimCombat;
    }
    else {
        _pos3 = [_behindBlockPos2 , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos2,_behindBlockPos2]] call TRGM_GLOBAL_fnc_findSafePos;
        _pos4 = [_behindBlockPos2 , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos2,_behindBlockPos2]] call TRGM_GLOBAL_fnc_findSafePos;


        _chatDir1 = [_pos3, _pos4] call BIS_fnc_DirTo;
        _chatDir2 = [_pos4, _pos3] call BIS_fnc_DirTo;

        _group2 = createGroup _thisSide;
        _group2 setFormDir _chatDir1;
        _group3 = createGroup _thisSide;
        _group3 setFormDir _chatDir2;

        _sUnitType = selectRandom _thisUnitTypes;
        _guardUnit3 = _group2 createUnit [_sUnitType,_pos3,[],0,"NONE"];
        doStop [_guardUnit3];
        _guardUnit3 setDir (_chatDir1);

        _sUnitType = selectRandom _thisUnitTypes;
        _guardUnit4 = _group3 createUnit [_sUnitType,_pos4,[],0,"NONE"];
        doStop [_guardUnit4];
        _guardUnit4 setDir (_chatDir2);


        //[_guardUnit3,"STAND","ASIS"] call BIS_fnc_ambientAnimCombat;

        if (_AllowAnimation) then {
            if (!_bHasParkedCar) then {
                [_guardUnit4,"STAND_IA","ASIS"] call BIS_fnc_ambientAnimCombat;
            }
            else {
                _LeanDir = ([direction _ParkedCar,45] call TRGM_GLOBAL_fnc_addToDirection);
                _group3 setFormDir _LeanDir;
                doStop [_guardUnit4];
                _guardUnit4 setDir (_LeanDir);
                sleep 0.1;
                _LeanPos = _ParkedCar getPos [1,_LeanDir];
                sleep 0.1;
                _guardUnit4 setPos _LeanPos;
                sleep 0.1;
                [_guardUnit4,"LEAN","ASIS"] call BIS_fnc_ambientAnimCombat;
            };
        };
    };

    _group4 = createGroup _thisSide;
    _sCheckpointGuyName = format["objCheckpointGuyName%1",(floor(random 999999))];


    _pos5 = [_behindBlockPos2 , 0, 10, 10, 0, 0.5, 0,[],[_behindBlockPos2,_behindBlockPos2],_sUnitType] call TRGM_GLOBAL_fnc_findSafePos;

    _guardUnit5 = _group4 createUnit [_sUnitType,_pos5,[],0,"NONE"];
    _guardUnit5 setVariable [_sCheckpointGuyName, _guardUnit5, true];
    missionNamespace setVariable [_sCheckpointGuyName, _guardUnit5];
    if (_thisSide isEqualTo TRGM_VAR_FriendlySide) then {
        _isHiddenObj = false;
        _mainAOPos = TRGM_VAR_ObjectivePossitions select 0;
        if (! isNil "_mainAOPos") then {
            if (_mainAOPos in TRGM_VAR_HiddenPossitions ) then {
                _isHiddenObj = true;
            };
        };

        if (!_isHiddenObj) then {
            [_guardUnit5, [localize "STR_TRGM2_setCheckpoint_Ask", {_this spawn TRGM_SERVER_fnc_speakToFriendlyCheckpoint;}, [_pos5], 0, true, true, "", "_this isEqualTo player && alive _target"]] remoteExec ["addAction", 0, true];
            if (random 1 < .25 && _thisSide isEqualTo TRGM_VAR_FriendlySide) then {
                _test = nil;
                _test = createMarker [format["MrkFriendCheckpoint%1%2",_roadBlockPos select 0, _roadBlockPos select 1], _roadBlockPos];
                _test setMarkerShape "ICON";
                _test setMarkerType "b_inf";
                _test setMarkerText (localize "STR_TRGM2_setCheckpoint_MarkerText");
            };
        };
    };
    TRGM_LOCAL_fnc_walkingGuyLoop = {
        _objManName = _this select 0;
        _thisInitPos = _this select 1;
        _objMan = missionNamespace getVariable _objManName;

        group _objMan setSpeedMode "LIMITED";
        group _objMan setBehaviour "SAFE";

        while {alive(_objMan) && {behaviour _objMan isEqualTo "SAFE"}} do {
            [_objManName,_thisInitPos,_objMan,35] spawn TRGM_SERVER_fnc_hvtWalkAround;
            sleep 2;
            waitUntil {sleep 1; speed _objMan < 0.5};
            sleep 10;
        };
    };
    [_sCheckpointGuyName,_pos5] spawn TRGM_LOCAL_fnc_walkingGuyLoop;
};


true;