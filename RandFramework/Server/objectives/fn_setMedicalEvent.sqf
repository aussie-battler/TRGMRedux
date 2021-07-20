
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
call TRGM_SERVER_fnc_initMissionVars;
_requiredItemIndex = selectRandom [0,1,2];
requiredItemsCount = [10,5,2] select _requiredItemIndex;
RequestedMedicalItem = ["FirstAidKit","FirstAidKit","Medikit"] select _requiredItemIndex;
RequestedMedicalItemName = ["First Aid Kits","First Aid Kits","Medikit"] select _requiredItemIndex;

if (isClass(configFile >> "CfgPatches" >> "ace_medical")) then {
    RequestedMedicalItem = ["ACE_bloodIV","ACE_quikclot","ACE_surgicalKit"] select _requiredItemIndex;
    requiredItemsCount = [5,5,2] select _requiredItemIndex;
    RequestedMedicalItemName = ["Blood IV (1000ml)","Basic Field Dressing (QuikClot)","Surgical Kits"] select _requiredItemIndex;
};
publicVariable "requiredItemsCount";
publicVariable "RequestedMedicalItem";
publicVariable "RequestedMedicalItemName";

_bloodPools = ["BloodPool_01_Large_New_F","BloodSplatter_01_Large_New_F"];

//use IDAP with police car???
_posOfAO =  _this select 0;

_nearLocations = nearestLocations [_posOfAO, ["NameCity","NameCityCapital","NameVillage"], 2500];
if (!(isNil "IsTraining") || TRGM_VAR_MainIsHidden) then {
    _nearLocations = nearestLocations [_posOfAO, ["NameCity","NameCityCapital","NameVillage"], 30000];
};

_eventLocationPos = nil;
{
    _xLocPos = locationPosition selectRandom _nearLocations;
    if (_xLocPos distance _posOfAO > 1000) then {
        _nearestRoads = _xLocPos nearRoads 150;
        _eventLocationPos = getPos (selectRandom _nearestRoads);
        //[str(_xLocPos distance _posOfAO)] call TRGM_GLOBAL_fnc_notify;
    };
} forEach _nearLocations;
if (isNil("_eventLocationPos")) then {
    _nearestRoads = _posOfAO nearRoads 5000;
    if (!(isNil "IsTraining") || TRGM_VAR_MainIsHidden) then {
        _nearestRoads = _posOfAO nearRoads 30000;
    };
    _eventLocationPos = getPos (selectRandom _nearestRoads);
    //["B"] call TRGM_GLOBAL_fnc_notify;
};


if (random 1 < .20) then {
    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingAmbush;
    if (random 1 < .33) then {
        [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
    };
};
if (random 1 < .20) then {
    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
};
if (random 1 < .33) then {
    [_eventLocationPos] spawn TRGM_SERVER_fnc_createEnemySniper;
};


_thisAreaRange = 50;
_iteration = 1;

while {_iteration <= 2} do {
    //[str(_iteration)] call TRGM_GLOBAL_fnc_notify;
    if (_iteration isEqualTo 2) then {
        _thisAreaRange = 50;
    };
    //[str(_thisAreaRange)] call TRGM_GLOBAL_fnc_notify;

    _nearestRoads = _eventLocationPos nearRoads _thisAreaRange;

    _nearestRoad = nil;
    _roadConnectedTo = nil;


    _connectedRoad = nil;
    _direction = nil;
    //["2"] call TRGM_GLOBAL_fnc_notify;
    //sleep 1;

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
        _roadBlockSidePos = _nearestRoad getPos [10, ([_direction,90] call TRGM_GLOBAL_fnc_addToDirection)];

        _mainVeh = createVehicle [selectRandom Ambulances,_roadBlockPos,[],0,"NONE"];
        _mainVeh setVehicleLock "LOCKED";
        _mainVehDirection =  ([_direction,(selectRandom[0,-10,10,170,180,190])] call TRGM_GLOBAL_fnc_addToDirection);
        _mainVeh setDir _mainVehDirection;
        clearItemCargoGlobal _mainVeh;
        [
            _mainVeh,
            ["CivAmbulance",1],
            ["Door_1_source",1,"Door_2_source",0,"Door_3_source",0,"Door_4_source",1,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",1,"ladder_hide",1,"spare_tyre_holder_hide",1,"spare_tyre_hide",1,"reflective_tape_hide",0,"roof_rack_hide",0,"LED_lights_hide",0,"sidesteps_hide",0,"rearsteps_hide",0,"side_protective_frame_hide",1,"front_protective_frame_hide",1,"beacon_front_hide",0,"beacon_rear_hide",0]
        ] call BIS_fnc_initVehicle;

        if (_iteration isEqualTo 1) then {
            [_mainVeh] spawn {
                _mainVeh = _this select 0;
                while{ (alive _mainVeh)} do {
                    playSound3D ["A3\Sounds_F\sfx\radio\" + selectRandom TRGM_VAR_FriendlyRadioSounds + ".wss",_mainVeh,false,getPosASL _mainVeh,0.5,1,0];
                    sleep selectRandom [10,15,20,30];
                };
            };

            if (TRGM_VAR_MainIsHidden) then {
                //Here... store location and type, so can learn this from intel
            };

            if (!(isNil "IsTraining")) then {
                _markerEventMedi = createMarker [format["_markerEventMedi%1",(floor(random 360))], ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos)];
                _markerEventMedi setMarkerShape "ICON";
                _markerEventMedi setMarkerType "hd_dot";
                _markerEventMedi setMarkerText "Medical Situation";
            }
            else {
                //if (random 1 < .25) then {
                //if (true) then {
                    _markerEventMedi = createMarker [format["_markerEventMedi%1",(floor(random 360))], ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos)];
                    _markerEventMedi setMarkerShape "ICON";
                    _markerEventMedi setMarkerType "hd_dot";
                    _markerEventMedi setMarkerText (localize "STR_TRGM2_distressSignal_civilian");
                //};
            };

        };

if (random 1 < .50) then {
    [_mainVeh] spawn {
        _mainVeh = _this select 0;
        while{ (alive _mainVeh)} do {

            _flareposX = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos) select 0;
            _flareposY = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos) select 1;
            _flare1 = "F_40mm_red" createvehicle [_flareposX+20,_flareposY+20, 250]; _flare1 setVelocity [0,0,-10];

            sleep selectRandom [600];
        }

    };
};

if (isnil "fncMedicalFlashLights") then {
    fncMedicalFlashLights = {
        params ["_mainVeh"];
        [_mainVeh] spawn {
            _mainVeh = _this select 0;
            _lightleft = "#lightpoint" createVehicle ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
            _lightleft setLightColor [255, 0, 0]; //red
            _lightleft setLightBrightness 0.03;
            _lightleft setLightAmbient [0.5,0.5,0.8];
            _lightleft lightAttachObject [_mainVeh, [0, 1, 1]];
            _leftRed = true;
            while{ (alive _mainVeh)} do
            {
             if(_leftRed) then
            {
               _leftRed = false;
               _lightleft setLightColor [0, 0, 255];
               //_lightright setLightColor [255, 0, 0];
            }
            else
            {
               _leftRed = true;
               _lightleft setLightColor [255, 0, 0];
               //_lightright setLightColor [0, 0, 255];
            };
             sleep 0.1;
            };
        };

    };
    publicVariable "fncMedicalFlashLights";
};

if (isnil "fncMedicalParamedicLight") then {
    fncMedicalParamedicLight = {
        params ["_downedCivMedic"];
        _medicLight = "#lightpoint" createVehicle ([_downedCivMedic] call TRGM_GLOBAL_fnc_getRealPos);
        _medicLight setLightColor [255, 255, 255]; //red
        _medicLight setLightBrightness 0.03;
        _medicLight setLightAmbient [0.5,0.5,0.8];
        _medicLight lightAttachObject [_downedCivMedic, [0, 1, 1]];

    };
    publicVariable "fncMedicalParamedicLight";
};

        [_mainVeh] remoteExec ["fncMedicalFlashLights", 0, true];


        _vehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
        _backOfVehArea = _vehPos getPos [5,([_mainVehDirection,(selectRandom[170,180,190])] call TRGM_GLOBAL_fnc_addToDirection)];
        //_direction is direction of road
        //_mainVehDirection is direction of first veh
        //use these to lay down guys, cones, rubbish, barriers, lights etc...

        //[str(_backOfVehArea)] call TRGM_GLOBAL_fnc_notify;
        _group = createGroup civilian;

        _downedCiv = [_group, selectRandom sCivilian,_backOfVehArea,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
        _downedCiv setDamage 0.8;
        [_downedCiv, "Acts_CivilInjuredGeneral_1"] remoteExec ["switchMove", 0];
        //_downedCiv playMoveNow "Acts_CivilInjuredGeneral_1"; //"AinjPpneMstpSnonWrflDnon";
        _downedCiv disableAI "anim";
        _downedCivDirection = (floor(random 360));
        _downedCiv setDir (_downedCivDirection);
        _downedCiv addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}];
        _bloodPool1 = createVehicle [selectRandom _bloodPools, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 0, "CAN_COLLIDE"];
        _bloodPool1 setDir (floor(random 360));
        if (true) then {
            _trialDir = (floor(random 360));
            _trialPos = (getPos _bloodPool1) getPos [3,_trialDir];
            _bloodTrail1 = createVehicle ["BloodTrail_01_New_F", _trialPos, [], 0, "CAN_COLLIDE"];
            _bloodTrail1 setDir _trialDir;
        };

        [_downedCiv] spawn {
            _downedCiv = _this select 0;
            while{ (alive _downedCiv)} do {
                _downedCiv say3D selectRandom WoundedSounds;
                sleep selectRandom [2,2.5,3];
            }

        };



        //Paramedics object1 attachTo [object2, offset, memPoint]
        //_group = createGroup civilian;
        _downedCivMedic = [_group, selectRandom Paramedics,_backOfVehArea,[],0,"CAN_COLLIDE"] call TRGM_GLOBAL_fnc_createUnit;
        _downedCivMedic playmove "Acts_TreatingWounded02";
        _downedCivMedic disableAI "anim";
        _downedCivMedic attachTo [_downedCiv, [0.5,-0.3,-0.1]];
        _downedCivMedic setDir 270;
        _downedCivMedic addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_paramedicKilled;}]; //ParamedicKilled


        [_downedCivMedic] remoteExec ["fncMedicalParamedicLight", 0, true];

        if (_iteration isEqualTo 1) then {
            [_downedCivMedic, ["Ask if needs assistance",{[format["Please can you supply us with %1 * %2.  Place them in this vehicle!",requiredItemsCount,RequestedMedicalItemName]] call TRGM_GLOBAL_fnc_notify;},[_downedCivMedic]]] remoteExec ["addAction", 0, true];
            //_downedCivMedic addAction ["Ask if needs assistance",{[format["Please can you supply us with %1 * %2.  Place them in this vehicle!",requiredItemsCount,RequestedMedicalItemName]] call TRGM_GLOBAL_fnc_notify;}];
            //_RequestedMedicalItem = "Item_FirstAidKit";
            [_mainVeh,_downedCivMedic] spawn {
                _mainVeh = _this select 0;
                _downedCivMedic = _this select 1;
                _completed = false;
                while{(alive _mainVeh && !_completed)} do {
                    _VanillaItemCount = {RequestedMedicalItem isEqualTo _x} count (itemcargo _mainVeh);
                    _AceItemCount = {RequestedMedicalItem isEqualTo _x} count (itemcargo _mainVeh);
                    //{"ACE_bloodIV" isEqualTo _x} count (itemcargo cursorTarget)
                    //[format["TEST: %1", _AceItemCount]] call TRGM_GLOBAL_fnc_notify;
                    if (_VanillaItemCount >= requiredItemsCount || _AceItemCount >= requiredItemsCount) then {
                        ["Thank you, this should help us get things under control"] call TRGM_GLOBAL_fnc_notifyGlobal;
                        _completed = true;
                        removeAllActions _downedCivMedic;
                        [0.3, "Assited with medical emergency"] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
                    };
                    sleep selectRandom [2];
                };
            };

            _Crater = createVehicle ["Crater", _backOfVehArea, [], 20, "CAN_COLLIDE"];

            _downedCivMedic2 = [_group, selectRandom sCivilian,_backOfVehArea,[],8,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _downedCivMedic2 playmove "Acts_CivilListening_2";
            _downedCivMedic2 disableAI "anim";
            _downedCivMedic2 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_paramedicKilled;}]; //ParamedicKilled

            //_RequestedMedicalItems

            _downedCiv2 = [_group, selectRandom Paramedics,([_downedCivMedic2] call TRGM_GLOBAL_fnc_getRealPos),[],2,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _downedCiv2 playmove "Acts_CivilTalking_2";
            _downedCiv2 disableAI "anim";
            _downedCiv2 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}]; //ParamedicKilled
            _directionFromMed2ToCiv2 = [_downedCivMedic2, _downedCiv2] call BIS_fnc_DirTo;
            _downedCivMedic2 setDir _directionFromMed2ToCiv2;
            _directionFromCiv2ToMed2 = [_downedCiv2, _downedCivMedic2] call BIS_fnc_DirTo;
            _downedCiv2 setDir _directionFromCiv2ToMed2;
        };
        if (_iteration isEqualTo 2) then {
            _downedCiv2 = [_group, selectRandom sCivilian,_backOfVehArea,[],8,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _downedCiv2 playmove "Acts_CivilHiding_2";
            _downedCiv2 disableAI "anim";
            _downedCiv2 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}]; //ParamedicKilled
            _directionFromCiv2ToMed2 = [_downedCiv2, _downedCiv] call BIS_fnc_DirTo;
            _downedCiv2 setDir _directionFromCiv2ToMed2;

            _downedCiv3 = [_group, selectRandom sCivilian,_backOfVehArea,[],25,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _downedCiv3 playmove "Acts_CivilShocked_1";
            _downedCiv3 disableAI "anim";
            _downedCiv3 setDir (floor(random 360));
            _downedCiv3 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}]; //ParamedicKilled
        };

        _rubbish1 = createVehicle [selectRandom TRGM_VAR_MedicalMessItems, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 1.5, "CAN_COLLIDE"];
        _rubbish1 setDir (floor(random 360));

        _rubbish2 = createVehicle [selectRandom TRGM_VAR_MedicalMessItems, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 1.5, "CAN_COLLIDE"];
        _rubbish2 setDir (floor(random 360));

        _medicalBox1 = createVehicle [selectRandom TRGM_VAR_MedicalBoxes, (_downedCiv getpos [2,(floor(random 360))]), [], 0, "CAN_COLLIDE"];
        _medicalBox1 setDir (floor(random 360));
        clearItemCargoGlobal _medicalBox1;


        //_upRoadPos = _vehPos getpos [10,_direction];
        _nearestRoadsPoint2 = _vehPos nearRoads 25;
        _maxRoads2 = count _nearestRoadsPoint2;
        _selIndex = selectRandom [0,(_maxRoads2-1)];
        _nearestRoad2 = _nearestRoadsPoint2 select 0;
        _roadConnectedTo2 = roadsConnectedTo _nearestRoad2;
        if (count _roadConnectedTo > 0) then {
            _connectedRoad2 = _roadConnectedTo2 select 0;
            _direction2 = [_nearestRoad2, _connectedRoad2] call BIS_fnc_DirTo;

            //[str(getpos _nearestRoad2)] call TRGM_GLOBAL_fnc_notify;

            _conelight1 = createVehicle [selectRandom TRGM_VAR_ConesWithLight, (_nearestRoad2 getpos [3,[_direction2,90] call TRGM_GLOBAL_fnc_addToDirection]), [], 0, "CAN_COLLIDE"];
            _conelight1 enableSimulation false;
            _conelight1 setDir (floor(random 360));
            _conelight2 = createVehicle [selectRandom TRGM_VAR_ConesWithLight, (_nearestRoad2 getpos [3,[_direction2,270] call TRGM_GLOBAL_fnc_addToDirection]), [], 0, "CAN_COLLIDE"];
            _conelight2 enableSimulation false;
            _conelight2 setDir (floor(random 360));
        };

        _flatPos = nil;
        _flatPos = [_vehPos , 10, 15, 10, 0, 0.3, 0,[],[[0,0,0],[0,0,0]],selectRandom CivCars] call TRGM_GLOBAL_fnc_findSafePos;



        _buildings = nearestObjects [_vehPos, TRGM_VAR_BasicBuildings, 100];
        //[str(count _buildings)] call TRGM_GLOBAL_fnc_notify;
        if (count _buildings < 5 && _iteration isEqualTo 1) then {
            _car1 = createVehicle [selectRandom CivCars, _flatPos, [], 0, "CAN_COLLIDE"];
            _car1 setDamage [1,false];
            _car1 setDir (floor(random 360));
            _objFlame1 = createVehicle ["test_EmptyObjectForFireBig", _flatPos, [], 0, "CAN_COLLIDE"];

        };

        if (_iteration isEqualTo 1 && random 1 < .50) then {
            _flatPosPolice1 = nil;
            _flatPosPolice1 = [_vehPos , 30, 50, 10, 0, 0.5, 0,[],[[0,0,0],[0,0,0]],selectRandom PoliceVehicles] call TRGM_GLOBAL_fnc_findSafePos;
            _carPolice = createVehicle [selectRandom PoliceVehicles, _flatPosPolice1, [], 0, "NONE"];
            _manPolice = [createGroup civilian, selectRandom Police,([_carPolice] call TRGM_GLOBAL_fnc_getRealPos),[],15,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _manPolice setDir (floor(random 360));
            [_manPolice] call TRGM_GLOBAL_fnc_makeNPC;
    //Police

        };
        //CivCars

        //TRGM_VAR_ConesWithLight
        //TRGM_VAR_Cones
        //Paramedics
        //"MedicalGarbage_01_Bandage_F" createVehicle ([player] call TRGM_GLOBAL_fnc_getRealPos);
        if (_iteration isEqualTo 1) then {
            _sidePos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
            _iCount = selectRandom[0,0,0,0,1];
            //_iCount = 1;
            //if (!_bIsMainObjective) then {_iCount = selectRandom [0,1];};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            while {_iCount > 0} do {
                _thisAreaRange = 100;
                _checkPointGuidePos = _sidePos;
                _iCount = _iCount - 1;
                _flatPos = nil;
                _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    _thisPosAreaOfCheckpoint = _flatPos;
                    _thisRoadOnly = true;
                    _thisSide = TRGM_VAR_EnemySide;
                    _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    _thisAllowBarakade = true;
                    _thisIsDirectionAwayFromAO = true;
                    [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100] spawn TRGM_SERVER_fnc_setCheckpoint;
                };
            };
            //spawn inner sentry
            _iCount = selectRandom[0,0,0,0,1];
            //_iCount = 1;
            //if (!_bIsMainObjective) then {_iCount = selectRandom [0,1];};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            while {_iCount > 0} do {
                _thisAreaRange = 100;
                _checkPointGuidePos = _sidePos;
                _iCount = _iCount - 1;
                _flatPos = nil;
                _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    _thisPosAreaOfCheckpoint = _flatPos;
                    _thisRoadOnly = false;
                    _thisSide = TRGM_VAR_EnemySide;
                    _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    _thisAllowBarakade = false;
                    _thisIsDirectionAwayFromAO = true;
                    [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100] spawn TRGM_SERVER_fnc_setCheckpoint;
                };
            };

        };
    };



    _iteration = _iteration + 1;
};




true;

