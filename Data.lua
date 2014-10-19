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
		-- Running Wild
		87840,
		function(env)
			return env.canMount, 100, nil, nil, "[outdoors,nocombat]"
		end
	)
end

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
		783, function(env) return "[nocombat,outdoors]", 100, 310, 100 end,
		-- Cat form
		768,  function(env) return "", 30, nil, nil end
	)
end

if isA("HUNTER") then
	addon:RegisterCancelSpells(
		 5118, "aura", "travel", -- Aspect of the Cheetah
		13159, "aura", "travel"  -- Aspect of the Pack
	)
	addon:RegisterSpecialSpells(
		-- Aspect of the Cheetah
		5118, function(env) return "", 30 end
	)
end

if isA("MONK") then
	addon:RegisterCancelSpells(
		125883, "aura", "travel" -- Zen Flight
	)
	addon:RegisterSpecialSpells(
		-- Zen Flight
		125883, function(env) return "[nocombat,outdoors]", nil, 54, nil end
	)
end

if isA("SHAMAN") then
	addon:RegisterCancelSpells(
		2645, "aura", "travel" -- Ghost Wolf
	)
	addon:RegisterSpecialSpells(
		-- Ghost Wolf
		2645, function(env) return "", 30 end
	)
end
