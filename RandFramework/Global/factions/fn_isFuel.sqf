// private _fnc_scriptName = "TRGM_GLOBAL_fnc_isFuel";
params[["_className", "", [objNull, ""]]];
// format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



switch (typeName _className) do {
    case ("OBJECT") : {_className = typeOf _className};
};

if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith {false};

getNumber(configFile >> "CfgVehicles" >> _className >> "transportFuel") > 0;