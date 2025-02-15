// private _fnc_scriptName = "MISSIONS_fnc_defuseIEDsMission";
//These are only ever called by the server!

//MISSION 13: Defuse IEDs

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
    _RequiresNearbyRoad = true;
    _roadSearchRange = 100; //this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _allowFriendlyIns = false;
    _MissionTitle = localize "STR_TRGM2_IEDMissionTitle"; //this is what shows in dialog mission selection
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
    if (_markerType != "empty") then { _markerType = "hd_unknown"; }; // Set marker type here...

    _compactIedTargets = false;
    if (TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_IEDTARGET_COMPACT_SPACING_IDX isEqualTo 1) then {
        _compactIedTargets = true;
    };
    if (TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_IEDTARGET_COMPACT_SPACING_IDX isEqualTo 0) then {
        _compactIedTargets = random 1 < .50;
    };

    _spacingBetweenTargets = 1500;
    if (_compactIedTargets) then {_spacingBetweenTargets = 150};

    //_MissionTitle = format["Meeting Assassination: %1",name(_mainHVT)];    //you can adjust this here to change what shows as marker and task text
    _sTaskDescription = selectRandom[localize "STR_TRGM2_IEDMissionDescription"]; //adjust this based on veh? and man? if van then if car then?

    _mainObjPos = getPos _objectiveMainBuilding;

    _IEDType = selectRandom ["CAR","RUBBLE"];
    _ieds = nil;
    If (_IEDType isEqualTo "CAR") then {_ieds = CivCars;};
    If (_IEDType isEqualTo "RUBBLE") then {_ieds = TRGM_VAR_IEDFakeClassNames;};

    _IED1 = createVehicle [selectRandom _ieds,[0,0,0],[],0,"NONE"];
    _sTargetName1 = format["objInformant%1",_iTaskIndex];
    _IED1 setVariable [_sTargetName1, _IED1, true];
    missionNamespace setVariable [_sTargetName1, _IED1];
    _IED1 setVariable ["ObjectiveParams", [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    missionNamespace setVariable [format ["missionObjectiveParams%1", _iTaskIndex], [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    [_mainObjPos,100,true,true,_IED1,_IEDType] spawn TRGM_SERVER_fnc_setIEDEvent;

    _IED2 = createVehicle [selectRandom _ieds,[-25,-25,0],[],0,"NONE"];
    _sTargetName2 = format["objInformant2_%1",_iTaskIndex];
    _IED2 setVariable [_sTargetName2, _IED2, true];
    missionNamespace setVariable [_sTargetName2, _IED2];
    [_mainObjPos,_spacingBetweenTargets,true,true,_IED2,_IEDType] spawn TRGM_SERVER_fnc_setIEDEvent;

    _IED3 = createVehicle [selectRandom _ieds,[-50,-50,0],[],0,"NONE"];
    _sTargetName3 = format["objInformant3_%1",_iTaskIndex];
    _IED3 setVariable [_sTargetName3, _IED3, true];
    missionNamespace setVariable [_sTargetName3, _IED3];
    [_mainObjPos,_spacingBetweenTargets,true,true,_IED3,_IEDType] spawn TRGM_SERVER_fnc_setIEDEvent;

    _allIEDs = [_IED1, _IED2, _IED3];
    [_allIEDs] spawn {
        _allIEDs = _this select 0;
        waitUntil { ({_x getVariable ["isDefused", false]} count _allIEDs) isEqualTo (count _allIEDs); };
        [_allIEDs select 0] spawn TRGM_SERVER_fnc_updateTask;
    };
};

publicVariable "MISSION_fnc_CustomRequired";
publicVariable "MISSION_fnc_CustomVars";
publicVariable "MISSION_fnc_CustomMission";