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

local tconcat = table.concat

--------------------------------------------------------------------------------
-- Spells to cancel
--------------------------------------------------------------------------------

local cancelSpells = {}
function addon:RegisterCancelSpells(id, type, purpose, more, ...)
	cancelSpells[id] = { type = type, purpose = purpose }
	if more then
		return self:RegisterCancelSpells(more, ...)
	end
end
addon.cancelSpells = cancelSpells

--------------------------------------------------------------------------------
-- Alternative spells
--------------------------------------------------------------------------------

local specialSpells = {}
function addon:RegisterSpecialSpells(id, handler, more, ...)
	tinsert(specialSpells, { id = id, handler = handler })
	if more then
		return self:RegisterSpecialSpells(more, ...)
	end
end
addon.specialSpells = specialSpells

--------------------------------------------------------------------------------
-- Main building method
--------------------------------------------------------------------------------

do
	local parts, numParts = {}

	local function append(head, more, ...)
		numParts = numParts + 1
		parts[numParts] = head
		if more then
			return append(more, ...)
		end
	end

	function addon:BuildMacro(button, env, settings)
		numParts = 0

		self:AddSafetyStop(append, env, settings)
		self:AddCancels(append, env, settings)

		append("\n/leavevehicle [canexitvehicle]")
		append("\n/dismount [mounted]")

		if button ~= "dismount" then
			self:AddStopMacro(append, env, settings)

			if env.canMount then
				self:AddMounts(append, env, settings)
			else
				self:AddSpells(append, env, settings)
			end
		end

		local macro = tconcat(parts, "", 1, numParts)
		--@debug@
		print(macro)
		--@end-debug@
		return macro
	end
end

--------------------------------------------------------------------------------
-- Macro part building
--------------------------------------------------------------------------------

local function GetModifierCondition(modifier, prefix)
	if modifier == "any" then
		return prefix..'mod'
	elseif modifier == "none" then
		return ""
	else
		return prefix..'mod:'..modifier
	end
end

function addon:GetFormBySpellId(id)
	for i = 1, GetNumShapeshiftForms() do
		if id == select(5, GetShapeshiftFormInfo(i)) then
			return i
		end
	end
end

function addon:AddSafetyStop(append, env, settings)
	local modifier = GetModifierCondition(settings.unsafeModifier, ",no")
	local cancel = settings.cancel
	append("\n/stopmacro ")
	if not cancel.flying then
		append("[flying", modifier, "]")
	end
	if not cancel.vehicle then
		append("[canexitvehicle", modifier, "]")
	end
	for id, spell in pairs(cancelSpells) do
		if IsPlayerSpell(id) and spell.type == "form" and settings.cancel[id] then
			local i = self:GetFormBySpellId(id)
			if i then
				append("[form:", i, modifier, "]")
			end
		end
	end
end

function addon:AddCancels(append)
	local cancelForm = false
	for id, spell in pairs(cancelSpells) do
		if IsPlayerSpell(id) then
			if spell.type == "form" and spell.purpose ~= "tank" then
				cancelForm = true
			elseif spell.type == "aura" then
				append("\n/cancelaura ", (GetSpellInfo(id)))
			end
		end
	end
	if cancelForm then
		append("\n/cancelform")
	end
end

function addon:AddStopMacro(append)
end

--------------------------------------------------------------------------------
-- Combat spell part
--------------------------------------------------------------------------------

function addon:AddSpells(append, env, settings)
	local first = true
	for index, spell in ipairs(specialSpells) do
		if IsPlayerSpell(spell.id) and settings.spells[spell.id] then
			if first then
				append("\n/cast ")
				first = false
			else
				append(";")
			end
			append((spell.handler(env, settings) or ""), (GetSpellInfo(spell.id)))
		end
	end
end

--------------------------------------------------------------------------------
-- Mount part
--------------------------------------------------------------------------------

local mountTypeSpeeds = {
	[230] = {100, nil, nil}, -- Ground mounts
	[231] = {nil, nil, 100}, -- Riding Turtle and Sea Turtle
	[232] = {nil, nil, 450}, -- Vashj'ir Seahorse
	[241] = {100, nil, nil}, -- Ahn'Qiraj mounts
	[247] = {100, 310, nil}, -- Red Flying Cloud
	[248] = {100, 310, nil}, -- Flying mounts
	[254] = {nil, nil, 450}, -- Subdued Seahorse
	[269] = {100, nil, nil}, -- Water striders
}
local unknownMountType = {}

-- Spell + mount iterator
local C_MountJournal = C_MountJournal
function addon:IterateMounts(env, settings)
	local numMounts = C_MountJournal.GetNumMounts()
	local index = -#specialSpells

	return function()
		while index < 0 do
			index = index + 1
			local spell = specialSpells[1-index]
			if IsPlayerSpell(spell.id) and settings.spells[spell.id] then
				local condition, groundSpeed, flyingSpeed, swimmingSpeed = spell.handler(env, settings)
				if SecureCmdOptionParse(condition) then
					return spell.id, groundSpeed, flyingSpeed, swimmingSpeed
				end
			end
		end
		while index < numMounts do
			index = index + 1
			local _, spellId, _, _, isUsable, _, isFavorite, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfo(index)
			if isUsable and isCollected and isFavorite and not hideOnChar then
				local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtra(index)
				if mountTypeSpeeds[mountType] then
					return spellId, unpack(mountTypeSpeeds[mountType], 1, 3)
				elseif not unknownMountType[mountType] then
					geterrorhandler()(format("Unknown mount type %d for mount #%d", mountType, spellId))
					unknownMountType[mountType] = true
				end
			end
		end
	end
end

local function selectBest(currentScore, currentSpell, newScore, newSpell)
	if newScore > currentScore or (newScore == currentScore and math.random() < 0.5) then
		return newScore, newSpell
	else
		return currentScore, currentSpell
	end
end

function addon:AddMounts(append, env, settings)
	local flyableScore, flyableSpell = 0
	local groundScore, groundSpell = 0
	local swimmingScore, swimmingSpell = 0

	for spellId, groundSpeed, flyingSpeed, swimmingSpeed in self:IterateMounts(env, settings) do
		if groundSpeed then
			groundScore, groundSpell = selectBest(groundScore, groundSpell, groundSpeed, spellId)
		end
		if flyingSpeed then
			flyableScore, flyableSpell = selectBest(flyableScore, flyableSpell, flyingSpeed, spellId)
		end
		if swimmingSpeed then
			swimmingScore, swimmingSpell = selectBest(swimmingScore, swimmingSpell, swimmingSpeed, spellId)
		end
	end

	if groundScore > 0 or swimmingScore > 0 or flyableScore > 0 then
		append("\n/cast ")
	end

	if swimmingScore > 0 and swimmingSpell ~= groundSpell then
		append("[swimming]!", (GetSpellInfo(swimmingSpell)), ";")
	end
	if flyableScore > 0 and flyableSpell ~= groundSpell then
		append("[flyable,nomod:shift]!", (GetSpellInfo(flyableSpell)), ";")
	end
	if groundScore > 0 then
		append("!", (GetSpellInfo(groundSpell)))
	end
end
