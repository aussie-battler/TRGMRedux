// private _fnc_scriptName = "MISSIONS_fnc_secureAndResupplyMission";
//These are only ever called by the server!

//MISSION 17: Secure and resupply area

MISSION_fnc_CustomRequired = { //used to set any required details for the AO (example, a wide open space or factory nearby)... if this is not found in AO, the engine will scrap the area and loop around again with a different location
    //be careful about using this, some maps may not have what you require, so the engine will never satisfy the requirements here (example, if no airports are on a map and that is what you require)
    private ["_objectiveMainBuilding", "_centralAO_x", "_centralAO_y", "_result", "_flatPos"];
    _objectiveMainBuilding = _this select 0;
    _centralAO_x = _this select 1;
    _centralAO_y = _this select 2;

    _result = true; //always returing true, because we have in custom vars "_RequiresNearbyRoad" which will take care of our checks
    _result; //return value
};

MISSION_fnc_CustomVars = { //This is called before the mission function is called below, and the variables below can be adjusted for your mission
    _RequiresNearbyRoad = false;
    _roadSearchRange = 100; //this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _allowFriendlyIns = false;
    _MissionTitle = localize "STR_TRGM2_ClearAreaMissionTitle"; //this is what shows in dialog mission selection
};

MISSION_fnc_CustomMission = { //This function is the main script for your mission, some if the parameters passed in must not be changed!!!
    /*
     * Parameter Descriptions
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     * _markerType                 : The marker type to be used, you can set the type of marker below, but if the player has selected to hide mission locations, then your marker will not show.
     * _objectiveMainBuilding      : DO NOT EDIT THIS VALUE (this is the main building location selected within your AO)
     * _centralAO_x                : DO NOT EDIT THIS VALUE (this is the X coord of the AO)
     * _centralAO_y                : DO NOT EDIT THIS VALUE (this is the Y coord of the AO)
     * _roadSearchRange            : DO NOT EDIT THIS VALUE (this is the search range for a valid road, set previously in MISSION_fnc_CustomVars)
     * _bCreateTask                : DO NOT EDIT THIS VALUE (this is determined by the player, if the player selected to play a hidden mission, the task is not created!)
     * _iTaskIndex                 : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the index of the task used to determine mission/task completion!)
     * _bIsMainObjective           : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the boolean if the mission is a Heavy or Standard mission!)
     * _args                       : These are additional arguments that might be required for the mission, for an example, see the Destroy Vehicles Mission.
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    params ["_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];
    if (_markerType != "empty") then { _markerType = "hd_objective"; }; // Set marker type here...

    _sTaskDescription = selectRandom[localize "STR_TRGM2_ClearAreaMissionDescription"]; //adjust this based on veh? and man? if van then if car then?

    _mainObjPos = getPos _objectiveMainBuilding;

    //spawn checkpoint with flag
    _thisAreaRange = 100;
    _checkPointGuidePos = _mainObjPos;
    _flatPos = _mainObjPos;
    _flatPos = [_checkPointGuidePos, 0, 50, 10, 0, 0.2, 0, [
        [getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]
    ] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas, [_mainObjPos, _mainObjPos]] call TRGM_GLOBAL_fnc_findSafePos;
    if !(_flatPos isEqualTo _mainObjPos) then {
        _thisPosAreaOfCheckpoint = _flatPos;
        _thisRoadOnly = true;
        _thisSide = TRGM_VAR_EnemySide;
        _thisUnitTypes = [(call sRifleman), (call sRifleman), (call sRifleman), (call sMachineGunMan), (call sEngineer), (call sEngineer), (call sMedic), (call sAAMan)];
        _thisAllowBarakade = true;
        _thisIsDirectionAwayFromAO = true;
        [_mainObjPos, _thisPosAreaOfCheckpoint, _thisAreaRange, _thisRoadOnly, _thisSide, _thisUnitTypes, _thisAllowBarakade, _thisIsDirectionAwayFromAO, false, (call UnarmedScoutVehicles), 50] spawn TRGM_SERVER_fnc_setCheckpoint;
    };

    //create flag and give its id
    _flag = selectRandom EnemyFlags createVehicle _flatPos;
    _flagName = format["ObjFlag%1", _iTaskIndex];
    _flag setVariable[_flagName, _flag, true];
    missionNamespace setVariable[format["SupplyDropped_%1", _iTaskIndex], 0, true];
    missionNamespace setVariable[_flagName, _flag, true];
    _flag setflagAnimationPhase 1;
    _flag setFlagTexture "\A3\Data_F\Flags\flag_red_CO.paa";
    _flag setVariable["TRGM_VAR_flagSide", TRGM_VAR_EnemySide, true];
    _flag setVariable ["ObjectiveParams", [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    missionNamespace setVariable [format ["missionObjectiveParams%1", _iTaskIndex], [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];

    //attach hold action to lowerflag and call supplydrop
    [
        _flag, // Object the action is attached to
        localize "STR_TRGM2_FlagLowerCallSupply", // Title of the action
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa", // Idle icon shown on screen
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa", // Progress icon shown on screen
        "_this distance _target < 35 && _target getVariable [""TRGM_VAR_flagSide"", TRGM_VAR_EnemySide] != TRGM_VAR_FriendlySide", // Condition for the action to be shown
        "_caller distance _target < 35", // Condition for the action to progress
        {}, // Code executed when action starts
        {
            params ["_flag", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];
            _relProgress = _progress / _maxProgress;
            [
                [_flag, _relProgress], {
                    if ((_this select 1) < 0.5) then {
                        (_this select 0) setFlagAnimationPhase(1 - (2 * (_this select 1)));
                    } else {
                        if ((_this select 1) isEqualTo 0.5) then {
                            (_this select 0) setFlagTexture "\A3\Data_F\Flags\flag_blue_CO.paa"
                        };
                        (_this select 0) setFlagAnimationPhase((2 * (_this select 1)) - 1);
                    };
                }
            ] remoteExec["call"];
        }, // Code executed on every progress tick
        {
            params ["_flag", "_caller", "_actionId", "_arguments"];
            _arguments
            params ["_iTaskIndex"];
            _flag setVariable["TRGM_VAR_flagSide", TRGM_VAR_FriendlySide, true];
            _flag setVariable["Lowered", true, true];
        }, // Code executed on completion
        {
            params ["_flag", "_caller", "_actionId", "_arguments"];
            _flag setFlagAnimationPhase 1;
            _side = _flag setVariable["TRGM_VAR_flagSide", TRGM_VAR_EnemySide, true];
            _flag setFlagTexture "\A3\Data_F\Flags\flag_red_CO.paa";
        }, // Code executed on interrupted
        [_iTaskIndex], // Arguments passed to the scripts as _this select 3
        6, // Action duration [s]
        100, // Priority
        false, // Remove on completion
        false // Show in unconscious state
    ] remoteExec["BIS_fnc_holdActionAdd", 0, true]; // MP compatible implementation

    [_flag, _iTaskIndex] spawn {
        params ["_flag", "_iTaskIndex"];
        waitUntil {
            sleep 30;
            _flag getVariable["Lowered", false];
        };

        [_flag, _iTaskIndex] spawn {
            params ["_flag", "_iTaskIndex"];
            while {missionNamespace getVariable[format["SupplyDropped_%1", _iTaskIndex], 0] < 2} do {
                [true, [_flag] call TRGM_GLOBAL_fnc_getRealPos] spawn TRGM_SERVER_fnc_alertNearbyUnits;
                sleep 60;
            };
        };

        private _convoyVehicles = [call sTank1ArmedCar, selectRandom (call UnarmedScoutVehicles), selectRandom (call UnarmedScoutVehicles), selectRandom (call UnarmedScoutVehicles), call sTank1ArmedCar];
        private _convoyStartPos = _flag getRelPos[2000, random 360];
        private _convoyDestPos = [_flag] call TRGM_GLOBAL_fnc_getRealPos;
        [TRGM_VAR_EnemySide, _convoyVehicles, _convoyStartPos, _convoyDestPos] call TRGM_GLOBAL_fnc_createConvoy;
        sleep 10;
        [TRGM_VAR_EnemySide, _flag getRelPos[5000, random 360], [_flag] call TRGM_GLOBAL_fnc_getRealPos, 3, true, false, false, false, false, true, true] spawn TRGM_GLOBAL_fnc_reinforcements;
        sleep 10;

        (format[localize "STR_TRGM2_MinUntilSupplyChopperInArea", "5:00"]) call TRGM_GLOBAL_fnc_notifyGlobal;
        [300, _iTaskIndex] spawn {
            params ["_duration", "_taskIndex"];
            _endTime = _duration + time;
            while {_endTime - time >= 0 && !TRGM_VAR_OverrideSupplyChopperDelay} do {
                _color = "#45f442";//green
                _timeLeft = _endTime - time;
                if (_timeLeft < 16) then {_color = "#eef441";};//yellow
                if (_timeLeft < 6) then {_color = "#ff0000";};//red
                if (_timeLeft < 0) exitWith {};
                _content = parseText format ["Time Until Supplies Drop: <t color='%1'>--- %2 ---</t>", _color, [(_timeLeft/3600),"HH:MM:SS"] call BIS_fnc_timeToString];
                [[_content, _duration + 1, _taskIndex, _taskIndex], {_this spawn TRGM_GUI_fnc_handleNotification}] remoteExec ["call"]; // After the first run, this will only update the text for the notification with index = _taskIndex
            };
        };
        _timeout = 300 + time;
        waitUntil {_timeout - time >= 0 || TRGM_VAR_OverrideSupplyChopperDelay}; //wait 5 mins before supply drop in area
        (localize "STR_TRGM2_SupplyChopperInbound") call TRGM_GLOBAL_fnc_notifyGlobal;

        private _spawnPos = _flag getRelPos[3000, random 360];
        private _exitPos = _flag getRelPos[25000, random 360];
        private _finishedVariable = format["SupplyDropped_%1", _iTaskIndex];
        private _finishedValue = 1;
        private _resupplyUnit = ((allPlayers - (entities "HeadlessClient_F")) select {(_x distance _flag) < 150});
        [_finishedVariable, _finishedValue, TRGM_VAR_FriendlySide, _spawnPos, _exitPos, [_flag] call TRGM_GLOBAL_fnc_getRealPos, _resupplyUnit] spawn TRGM_GLOBAL_fnc_supplyHelicopter;
        waitUntil {
            sleep 2;
            missionNamespace getVariable[format["SupplyDropped_%1", _iTaskIndex], 0] isEqualTo _finishedValue;
        };


        _convoyVehicles = [call sTank1ArmedCar, selectRandom (call UnarmedScoutVehicles), selectRandom (call UnarmedScoutVehicles), selectRandom (call UnarmedScoutVehicles), call sTank1ArmedCar];
        _convoyStartPos = _flag getRelPos[2000, random 360];
        _convoyDestPos = [_flag] call TRGM_GLOBAL_fnc_getRealPos;
        [TRGM_VAR_EnemySide, _convoyVehicles, _convoyStartPos, _convoyDestPos] call TRGM_GLOBAL_fnc_createConvoy;
        sleep 10;
        [TRGM_VAR_EnemySide, _flag getRelPos[5000, random 360], [_flag] call TRGM_GLOBAL_fnc_getRealPos, 3, true, false, false, false, false, true, true] spawn TRGM_GLOBAL_fnc_reinforcements;
        sleep 10;

        (format[localize "STR_TRGM2_MinUntilSupplyChopperInArea", "5:00"]) call TRGM_GLOBAL_fnc_notifyGlobal;
        [300, _iTaskIndex] spawn {
            params ["_duration", "_taskIndex"];
            _endTime = _duration + time;
            while {_endTime - time >= 0 && !TRGM_VAR_OverrideSupplyChopperDelay} do {
                _color = "#45f442";//green
                _timeLeft = _endTime - time;
                if (_timeLeft < 16) then {_color = "#eef441";};//yellow
                if (_timeLeft < 6) then {_color = "#ff0000";};//red
                if (_timeLeft < 0) exitWith {};
                _content = parseText format ["Time Until Supplies Drop: <t color='%1'>--- %2 ---</t>", _color, [(_timeLeft/3600),"HH:MM:SS"] call BIS_fnc_timeToString];
                [[_content, _duration + 1, _taskIndex, _taskIndex], {_this spawn TRGM_GUI_fnc_handleNotification}] remoteExec ["call"]; // After the first run, this will only update the text for the notification with index = _taskIndex
            };
        };
        _timeout = 300 + time;
        waitUntil {_timeout - time >= 0 || TRGM_VAR_OverrideSupplyChopperDelay}; //wait 5 mins before supply drop in area
        (localize "STR_TRGM2_SupplyChopperInbound") call TRGM_GLOBAL_fnc_notifyGlobal;


        _finishedValue = 2;
        [_finishedVariable, _finishedValue, TRGM_VAR_FriendlySide, _spawnPos, _exitPos, [_flag] call TRGM_GLOBAL_fnc_getRealPos, _resupplyUnit] spawn TRGM_GLOBAL_fnc_supplyHelicopter;
        waitUntil {
            sleep 2;
            missionNamespace getVariable[format["SupplyDropped_%1", _iTaskIndex], 0] isEqualTo _finishedValue;
        };


        [_flag] spawn TRGM_SERVER_fnc_updateTask;
    };
};

publicVariable "MISSION_fnc_CustomRequired";
publicVariable "MISSION_fnc_CustomVars";
publicVariable "MISSION_fnc_CustomMission";