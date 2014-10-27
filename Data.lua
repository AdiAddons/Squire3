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

if "Worgen" == select(2, UnitRace("player")) then
	addon:RegisterSpecialSpells(
		87840, "[outdoors,nocombat]", 100, nil, nil -- Running Wild
	)
end

if isA("DRUID") then
	addon:RegisterCancelSpells(
		   768, "form", -- Cat form
		   783, "form", -- Travel form
		  5487, "form", -- Bear form
		 24858, "form", -- Moonkin form
		114282, "aura", -- Treant form
		165962, "form"  -- Flying form
	)
	addon:RegisterSpecialSpells(
		165962, "[flyable,nocombat,outdoors]",  98, 310, nil, -- Flying form
		   783, "[nocombat,outdoors]",         100, 308,  85, -- Travel form
		   768, "",                             30, nil, nil  -- Cat form
	)
end

if isA("HUNTER") then
	addon:RegisterSpecialSpells(
		5118, "", 30, nil, nil -- Aspect of the Cheetah
	)
end

if isA("MONK") then
	addon:RegisterCancelSpells(
		125883, "aura" -- Zen Flight
	)
	addon:RegisterSpecialSpells(
		125883, "[nocombat,outdoors,flyable]", nil, 54, nil, -- Zen Flight
		109132, "", 10, nil, nil, -- Roll
		121827, "", 10, nil, nil  -- Celerity Roll
	)
end

if isA("SHAMAN") then
	addon:RegisterCancelSpells(
		2645, "aura" -- Ghost Wolf
	)
	addon:RegisterSpecialSpells(
		2645, "", 30, nil, nil -- Ghost Wolf
	)
end
