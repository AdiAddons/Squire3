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
function addon:RegisterCancelSpells(id, type, ...)
	cancelSpells[id] = type
	if ... then
		return self:RegisterCancelSpells(...)
	end
end
addon.cancelSpells = cancelSpells

--------------------------------------------------------------------------------
-- Alternative spells
--------------------------------------------------------------------------------

local specialSpells = {}
function addon:RegisterSpecialSpells(id, condition, ground, flying, swimming, ...)
	tinsert(specialSpells, { id = id, condition = condition, ground = ground, flying = flying, swimming = swimming })
	if ... then
		return self:RegisterSpecialSpells(...)
	end
end
addon.specialSpells = specialSpells

--------------------------------------------------------------------------------
-- Main building method
--------------------------------------------------------------------------------

do
	local parts, numParts, currentCmd, done = {}

	-- Record all commands
	local function append(cmd, head, ...)
		if cmd ~= currentCmd then
			numParts = numParts + 1
			parts[numParts] = "\n/"..cmd
		end
		if head then
			parts[numParts+1] = currentCmd == cmd and ";" or " "
			parts[numParts+2] = head
			numParts = numParts + 2
		end
		currentCmd = cmd
		if ... then
			return append(cmd, ...)
		end
	end

	-- Stop as soon as we have a working command
	local function liveAppend(cmd, head, ...)
		if done then return end
		if cmd ~= "cancelaura" and head then
			head = SecureCmdOptionParse(head)
		end
		if head then
			if cmd ~= "stopmacro" then
				append(cmd, head)
			end
			if cmd ~= "cancelaura" then
				done = true
			end
		end
		if ... then
			return liveAppend(cmd, ...)
		end
	end

	local handlers = {
		mount = { 'AddSafetyStop', 'AddCancels', 'AddToggleStop', 'AddMounts', 'AddSpells' },
		dismount = { 'AddSafetyStop', 'AddCancels' },
	}

	function addon:BuildMacro(button, env, settings)
		numParts, done, currentCmd = 0, false

		local append = env.combat and append or liveAppend
		local handlers = handlers[button] or handlers.mount
		for i, handler in ipairs(handlers) do
			self[handler](self, append, env, settings)
			if done then
				break
			end
		end

		local macro = tconcat(parts, "", 1, numParts)
		addon.Debug(macro)
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
	if not cancel.flying then
		append("stopmacro", format('[flying%s]', modifier))
	end
	if not cancel.vehicle then
		append("stopmacro", format('[vehicleui,canexitvehicle%s]', modifier))
	end
	if not cancel.dismount then
		append("stopmacro", format('[mounted%s]', modifier))
	end
	for id, type in pairs(cancelSpells) do
		if IsPlayerSpell(id) and type == "form" and not settings.cancel[tostring(id)] then
			local i = self:GetFormBySpellId(id)
			if i then
				append("stopmacro", format('[form:%d%s]', i, modifier))
			end
		end
	end
end

function addon:AddCancels(append, env, settings)
	local cancelForm = false
	for id, type in pairs(cancelSpells) do
		if IsPlayerSpell(id) and settings.cancel[tostring(id)] then
			if type == "form" then
				cancelForm = true
			elseif type == "aura" then
				append("cancelaura", (GetSpellInfo(id)))
			end
		end
	end
	if cancelForm then
		append("cancelform", "[form]")
	end
	if settings.cancel.vehicle then
		append("leavevehicle", "[vehicleui,canexitvehicule]")
	end
	if settings.cancel.mount then
		append("dismount", "[mounted]")
	end
end

function addon:AddToggleStop(append, env, settings)
	if not settings.toggleMode then return end
	if settings.cancel.vehicle then
		append("stopmacro", "[vehicleui,canexitvehicule]")
	end
	if settings.cancel.mount then
		append("stopmacro", "[mounted]")
	end
	for id, type in pairs(cancelSpells) do
		if IsPlayerSpell(id) and type == "form" and not settings.cancel[tostring(id)] then
			local i = self:GetFormBySpellId(id)
			if i then
				append("stopmacro", format('[form:%d]', i))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Combat spell part
--------------------------------------------------------------------------------

function addon:AddSpells(append, env, settings)
	if env.canMount then return end
	for index, spell in ipairs(specialSpells) do
		if IsPlayerSpell(spell.id) and settings.spells[spell.id] then
			local condition = spell.condition
			local _, pos = strfind(condition, "flyable")
			if pos then
				condition = strsub(condition, 1, pos)..GetModifierCondition(settings.groundModifier, ",no")..strsub(condition, pos)
			end
			append("cast", format("%s!%s", condition, GetSpellInfo(spell.id)))
		end
	end
end

--------------------------------------------------------------------------------
-- Mount part
--------------------------------------------------------------------------------

local mountTypeSpeeds = {
	[230] = {100, nil, nil}, -- Ground mounts
	[231] = {nil, nil,  50}, -- Riding Turtle and Sea Turtle
	[232] = {nil, nil, 450}, -- Vashj'ir Seahorse
	[241] = {100, nil, nil}, -- Ahn'Qiraj mounts
	[247] = { 98, 310, nil}, -- Red Flying Cloud
	[248] = { 98, 310, nil}, -- Flying mounts
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
				if SecureCmdOptionParse(spell.condition) then
					return spell.id, spell.ground, spell.flying, spell.swimming
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
	if not env.canMount then return end
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

	if swimmingScore > 0 and swimmingSpell ~= groundSpell then
		append("cast", format("[swimming]!%s", GetSpellInfo(swimmingSpell)))
	end
	if flyableScore > 0 and flyableSpell ~= groundSpell then
		append("cast", format("[flyable%s]!%s", GetModifierCondition(settings.groundModifier, ",no"), GetSpellInfo(flyableSpell)))
	end
	if groundScore > 0 then
		append("cast", "!"..GetSpellInfo(groundSpell))
	end
end
