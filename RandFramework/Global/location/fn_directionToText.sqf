params [
    ["_direction",-1,[0]],  // direction 0 to 360
    ["_words",false,[false]] // use word style instead of acronyms
];

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (_direction < 0 ||_direction > 360) exitWith { ""; };

private _val = round(_direction/45);
if (_words) then {
    switch(_val) do {
        case 8;
        case 0: {localize "STR_TRGM2_location_fndirectionToText_N_Word"};
        case 1: {localize "STR_TRGM2_location_fndirectionToText_NE_Word"};
        case 2: {localize "STR_TRGM2_location_fndirectionToText_E_Word"};
        case 3: {localize "STR_TRGM2_location_fndirectionToText_SE_Word"};
        case 4: {localize "STR_TRGM2_location_fndirectionToText_S_Word"};
        case 5: {localize "STR_TRGM2_location_fndirectionToText_SW_Word"};
        case 6: {localize "STR_TRGM2_location_fndirectionToText_W_Word"};
        case 7: {localize "STR_TRGM2_location_fndirectionToText_NW_Word"};
    };
} else {
    switch(_val) do {
        case 8;
        case 0: {localize "STR_TRGM2_location_fndirectionToText_N"};
        case 1: {localize "STR_TRGM2_location_fndirectionToText_NE"};
        case 2: {localize "STR_TRGM2_location_fndirectionToText_E"};
        case 3: {localize "STR_TRGM2_location_fndirectionToText_SE"};
        case 4: {localize "STR_TRGM2_location_fndirectionToText_S"};
        case 5: {localize "STR_TRGM2_location_fndirectionToText_SW"};
        case 6: {localize "STR_TRGM2_location_fndirectionToText_W"};
        case 7: {localize "STR_TRGM2_location_fndirectionToText_NW"};
    };
};