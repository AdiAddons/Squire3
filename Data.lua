--[[
Squire3 - One-click smart mounting.
(c) 2014 Adirelle (adirelle@gmail.com)

This file is part of Squire3.

Squire3 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Squire3 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Squire3.  If not, see <http://www.gnu.org/licenses/>.
--]]

local addonName, addon = ...

local function isA(class) return select(2, UnitClass("player")) == class end
---@debug@
isA = function() return true end
---@end-debug@

if isA("DRUID") then
	addon:RegisterCancelSpells(
		   768, "form", "damage",  -- Cat form
		   783, "form", "travel",  -- Travel form
		  5487, "form", "tank",    -- Bear form
		 24858, "form", "damage",  -- Moonkin form
		114282, "aura", "cosmetic" -- Treant form
	)
	addon:RegisterSpecialSpells(
		-- Travel form
		783,
		function(env, settings)
			return env.moving or env.combat, "[outdoors]"
		end,
		-- Cat form
		768,  
		function(env, settings) 
			return env.moving or env.combat, "[indoors]"
		end
	)
end

if isA("HUNTER") then
end
