/*
 * Author: commy2
 *
 * Drop a dragged object.
 *
 * Argument:
 * 0: Unit that drags the other object (Object)
 * 1: Dragged object to drop (Object)
 *
 * Return value:
 * NONE.
 */
#include "script_component.hpp"

private ["_unit", "_target"];

_unit = _this select 0;
_target = _this select 1;

// remove scroll wheel action
/*
_this removeAction (_this getVariable ["AGM_Drag_ReleaseActionID", -1]);
*/

// play release animation
_unit playAction "released";

// release object
detach _target;

_unit setVariable [QGVAR(isDragging), false, true];

// make object accesable for other units
[objNull, _target, true] call EFUNC(common,claim);

["fixPosition", _target, _target] call EFUNC(common,targetEvent);
