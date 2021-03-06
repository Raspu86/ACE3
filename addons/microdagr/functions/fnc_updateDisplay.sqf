﻿/*
 * Author: PabstMirror
 * Updates the display (several times a second) called from the pfeh
 *
 * Arguments:
 * Nothing
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [] call ace_microdagr_fnc_updateDisplay
 *
 * Public: No
 */
#include "script_component.hpp"

private ["_display", "_waypoints", "_posString", "_eastingText", "_northingText", "_numASL", "_aboveSeaLevelText", "_compassAngleText", "_targetPosName", "_targetPosLocationASL", "_bearingText", "_rangeText", "_targetName", "_bearing", "_2dDistanceKm", "_SpeedText", "_playerPos2d", "_wpListBox", "_currentIndex", "_wpName", "_wpPos", "_settingListBox", "_yearString", "_monthSring", "_dayString"];

disableSerialization;
_display = displayNull;
if (GVAR(currentShowMode) == DISPLAY_MODE_DIALOG) then {
    _display = (uiNamespace getVariable [QGVAR(DialogDisplay), displayNull]);
} else {
    _display = (uiNamespace getVariable [QGVAR(RscTitleDisplay), displayNull]);
};
if (isNull _display) exitWith {ERROR("No Display");};

(_display displayCtrl IDC_CLOCKTEXT) ctrlSetText ([daytime, "HH:MM"] call bis_fnc_timeToString);

_waypoints = [] call FUNC(deviceGetWaypoints);

switch (GVAR(currentApplicationPage)) do {
case (APP_MODE_INFODISPLAY): {
        //Easting/Northing:
        _posString = mapGridPosition ACE_player;
        _eastingText = "";
        _northingText = "";
        if (count _posString > 0) then {
            _eastingText = (_posString select [0, ((count _posString)/2)]) + "e";
            _northingText = (_posString select [(count _posString)/2, (count _posString - 1)]) + "n";
        };
        (_display displayCtrl IDC_MODEDISPLAY_EASTING) ctrlSetText _eastingText;
        (_display displayCtrl IDC_MODEDISPLAY_NORTHING) ctrlSetText _northingText;

        //Elevation:
        _numASL = ((getPosASL ace_player) select 2) + GVAR(mapAltitude);
        _aboveSeaLevelText = [_numASL, 5, 0] call CBA_fnc_formatNumber;
        _aboveSeaLevelText = if (_numASL > 0) then {"+" + _aboveSeaLevelText + " MSL"} else {_aboveSeaLevelText + " MSL"};
        (_display displayCtrl IDC_MODEDISPLAY_ELEVATIONNUM) ctrlSetText _aboveSeaLevelText;

        //Heading:
        _compassAngleText = if (GVAR(settingUseMils)) then {
            [(floor ((6400 / 360) * (getDir ace_player))), 4, 0] call CBA_fnc_formatNumber;
        } else {
            ([(floor (getDir ace_player)), 3, 1] call CBA_fnc_formatNumber) + "°" //degree symbol is in UTF-8
        };
        (_display displayCtrl IDC_MODEDISPLAY_HEADINGNUM) ctrlSetText _compassAngleText;

        //Speed:
        (_display displayCtrl IDC_MODEDISPLAY_SPEEDNUM) ctrlSetText format ["%1kph", (round (speed (vehicle ace_player)))];;


        if (GVAR(currentWaypoint) == -1) then {
            _yearString = (date select 0);
            _monthSring = localize (["error","str_january","str_february","str_march","str_april","str_may","str_june","str_july","str_august","str_september","str_october","str_november","str_december"] select (date select 1));
            _dayString = if ((date select 2) < 10) then {"0" + str (date select 2)} else {str (date select 2)};

            (_display displayCtrl IDC_MODEDISPLAY_TIMEDISPLAYGREEN1) ctrlSetText format ["%1-%2-%3", _yearString, _monthSring, _dayString]; //"18-Feb-2010";
            (_display displayCtrl IDC_MODEDISPLAY_TIMEDISPLAYGREEN2) ctrlSetText ([daytime, "HH:MM:SS"] call bis_fnc_timeToString);
        } else {
            _targetPosName = "";
            _targetPosLocationASL = [];
            _bearingText = "----";
            _rangeText = "----";
            _aboveSeaLevelText = "----";
            _targetName = "----";

            if (GVAR(currentWaypoint) == -2) then {
                if (!(GVAR(rangeFinderPositionASL) isEqualTo [])) then {
                    _targetPosName = format ["[%1]", (mapGridPosition GVAR(rangeFinderPositionASL))];
                    _targetPosLocationASL = GVAR(rangeFinderPositionASL);
                };
            } else {
                if (GVAR(currentWaypoint) > ((count _waypoints) - 1)) exitWith {ERROR("bounds");};
                _targetPosName = (_waypoints select GVAR(currentWaypoint)) select 0;
                _targetPosLocationASL = (_waypoints select GVAR(currentWaypoint)) select 1;
            };

            if (!(_targetPosLocationASL isEqualTo [])) then {
                _bearing = [(getPosASL ace_player), _targetPosLocationASL] call BIS_fnc_dirTo;
                _bearingText = if (GVAR(settingUseMils)) then {
                    [(floor ((6400 / 360) * (_bearing))), 4, 0] call CBA_fnc_formatNumber;
                } else {
                    ([(floor (_bearing)), 3, 1] call CBA_fnc_formatNumber) + "°" //degree symbol is in UTF-8
                };
                _2dDistanceKm = (((getPosASL ace_player) select [0,2]) distance (_targetPosLocationASL select [0,2])) / 1000;
                _rangeText = format ["%1km", ([_2dDistanceKm, 1, 1] call CBA_fnc_formatNumber)];
                _numASL = (_targetPosLocationASL select 2) + GVAR(mapAltitude);
                _aboveSeaLevelText = [_numASL, 5, 0] call CBA_fnc_formatNumber;
                _aboveSeaLevelText = if (_numASL > 0) then {"+" + _aboveSeaLevelText + " MSL"} else {_aboveSeaLevelText + " MSL"};
            };

            (_display displayCtrl IDC_MODEDISPLAY_TRACKNUM) ctrlSetText _bearingText;
            (_display displayCtrl IDC_MODEDISPLAY_TARGETRANGENUM) ctrlSetText _rangeText;
            (_display displayCtrl IDC_MODEDISPLAY_TARGETELEVATIONNUM) ctrlSetText _aboveSeaLevelText;
            (_display displayCtrl IDC_MODEDISPLAY_TARGETNAME) ctrlSetText _targetPosName;
        };
    };
case (APP_MODE_COMPASS): {
        //Heading:
        _compassAngleText = if (GVAR(settingUseMils)) then {
            [(floor ((6400 / 360) * (getDir ace_player))), 4, 0] call CBA_fnc_formatNumber;
        } else {
            ([(floor (getDir ace_player)), 3, 1] call CBA_fnc_formatNumber) + "°" //degree symbol is in UTF-8
        };
        (_display displayCtrl IDC_MODECOMPASS_HEADING) ctrlSetText _compassAngleText;

        //Speed:
        _SpeedText = format ["%1kph", (round (speed (vehicle ace_player)))];;
        (_display displayCtrl IDC_MODECOMPASS_SPEED) ctrlSetText _SpeedText;

        if (GVAR(currentWaypoint) == -1) then {
            (_display displayCtrl IDC_MODECOMPASS_BEARING) ctrlSetText "";
            (_display displayCtrl IDC_MODECOMPASS_RANGE) ctrlSetText "";
            (_display displayCtrl IDC_MODECOMPASS_TARGET) ctrlSetText "";
        } else {
            _playerPos2d = (getPosASL ace_player) select [0,2];

            _targetPosName = "";
            _targetPosLocationASL = [];

            if (GVAR(currentWaypoint) == -2) then {
                if (!(GVAR(rangeFinderPositionASL) isEqualTo [])) then {
                    _targetPosName = format ["[%1]", (mapGridPosition GVAR(rangeFinderPositionASL))];
                    _targetPosLocationASL = GVAR(rangeFinderPositionASL);
                };
            } else {
                if (GVAR(currentWaypoint) > ((count _waypoints - 1))) exitWith {ERROR("bounds");};
                _targetPosName = (_waypoints select GVAR(currentWaypoint)) select 0;
                _targetPosLocationASL = (_waypoints select GVAR(currentWaypoint)) select 1;
            };

            _bearing = "---";
            _rangeText = "---";

            if (!(_targetPosLocationASL isEqualTo [])) then {
                _bearing = [(getPosASL ace_player), _targetPosLocationASL] call BIS_fnc_dirTo;
                _bearingText = if (GVAR(settingUseMils)) then {
                    [(floor ((6400 / 360) * (_bearing))), 4, 0] call CBA_fnc_formatNumber;
                } else {
                    ([(floor (_bearing)), 3, 1] call CBA_fnc_formatNumber) + "°" //degree symbol is in UTF-8
                };
                _2dDistanceKm = (((getPosASL ace_player) select [0,2]) distance (_targetPosLocationASL select [0,2])) / 1000;
                _rangeText = format ["%1km", ([_2dDistanceKm, 1, 1] call CBA_fnc_formatNumber)];
            };

            (_display displayCtrl IDC_MODECOMPASS_BEARING) ctrlSetText _bearingText;
            (_display displayCtrl IDC_MODECOMPASS_RANGE) ctrlSetText _rangeText;
            (_display displayCtrl IDC_MODECOMPASS_TARGET) ctrlSetText _targetPosName;
        };
    };

case (APP_MODE_WAYPOINTS): {
        _wpListBox = _display displayCtrl IDC_MODEWAYPOINTS_LISTOFWAYPOINTS;
        _currentIndex = lbCurSel _wpListBox;

        lbClear _wpListBox;
        {
            EXPLODE_2_PVT(_x,_wpName,_wpPos);
            _wpListBox lbAdd _wpName;
            _2dDistanceKm = (((getPosASL ace_player) select [0,2]) distance (_wpPos select [0,2])) / 1000;
            _wpListBox lbSetTextRight [_forEachIndex, (format ["%1km", ([_2dDistanceKm, 1, 1] call CBA_fnc_formatNumber)])];
        } forEach _waypoints;

        _currentIndex = (_currentIndex max 0) min (count _waypoints);
        _wpListBox lbSetCurSel _currentIndex;
    };

case (APP_MODE_SETUP): {
        _settingListBox = _display displayCtrl IDC_MODESETTINGS;
        lbClear _settingListBox;

        _settingListBox lbAdd (localize LSTRING(settingUseMils));
        if (GVAR(settingUseMils)) then {
            _settingListBox lbSetTextRight [0, (localize LSTRING(settingMils))];
        } else {
            _settingListBox lbSetTextRight [0, (localize LSTRING(settingDegrees))];
        };

        _settingListBox lbAdd (localize LSTRING(settingShowWP));
        if (GVAR(settingShowAllWaypointsOnMap)) then {
            _settingListBox lbSetTextRight [1, (localize LSTRING(settingOn))];
        } else {
            _settingListBox lbSetTextRight [1, (localize LSTRING(settingOff))];
        };
    };
};
