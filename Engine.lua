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

local cancelSpells = {}
function addon:RegisterCancelSpells(id, type, purpose, more, ...)
	cancelSpells[id] = { type = type, purpose = purpose }
	if more then
		return self:RegisterCancelSpells(more, ...)
	end
end

local specialSpells = {}
function addon:RegisterSpecialSpells(id, handler, more, ...)
	tinsert(specialSpells, { id = id, handler = handler })
	if more then
		return self:RegisterSpecialSpells(more, ...)
	end
end

do
	local parts, numParts = {}
	
	local function append(head, more, ...)
		numParts = numParts + 1
		parts[numParts] = head
		if more then
			return append(more, ...)
		end
	end

	function addon:BuildMacro(env, settings)
		numParts = 0

		self:AddSafetyStop(append, env, settings)
		self:AddCancels(append, env, settings)

		append("\n/leavevehicle [canexitvehicle]")
		append("\n/dismount [mounted]")
		
		self:AddStopMacro(append, env, settings)
		self:AddCasts(append, env, settings)
		
		local macro = tconcat(parts, "", 1, numParts)
		print(macro)
		return macro
	end
end

function addon:GetFormBySpellId(id)
	for i = 1, GetNumShapeshiftForms() do
		if id == select(5, GetShapeshiftFormInfo(i)) then
			return i
		end
	end
end

function addon:AddSafetyStop(append)
	append("\n/stopmacro [flying,nomod:shift]")
	for id, spell in pairs(cancelSpells) do
		if IsPlayerSpell(id) and spell.type == "form" and spell.purpose == "tank" then
			local i = self:GetFormBySpellId(id)
			if i then
				append(";[nomod:shift,form:", i, "]")
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

local spells, numSpells = {}

local function appendSpell(txt)
	numSpells = numSpells + 1
	spells[numSpells] = txt
end

function addon:AddCasts(append, env, settings)
	numSpells = 0
	
	for i, spell in ipairs(specialSpells) do
		if IsPlayerSpell(spell.id) then
			local isUsable, condition = spell.handler(env, settings)
			if isUsable then
				appendSpell((condition or "")..GetSpellInfo(spell.id))
			end
		end
	end
	
	if not env.moving and not env.combat then
		self:AddMounts(appendSpell, env, settings)
	end

	if numSpells > 0 then
		append("\n/cast ", tconcat(spells, ";", 1, numSpells))
	end
end

local C_MountJournal = C_MountJournal
local lastSeen = {}

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
	local now = GetTime()

	for index = 1, C_MountJournal.GetNumMounts() do
		local name, spellId, _, active, isUsable, _, isFavorite, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfo(index)
		if isUsable and isCollected and isFavorite and not hideOnChar then
			local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtra(index)
			local age = 25
			if active then
				lastSeen[spellId] = now
				age = 0
			elseif lastSeen[spellId] then
				age = (0.0 + lastSeen[spellId] - now) / 1000.0
			end
			if mountType == 230 or mountType == 241 then
				-- Ground and Ahn'Qiraj mounts
				groundScore, groundSpell = selectBest(groundScore, groundSpell, 100+age, spellId)
			end
			if mountType == 231 then
				-- Riding Turtle and Sea Turtle
				swimmingScore, swimmingSpell = selectBest(swimmingScore, swimmingSpell, 300+age, spellId)
			end
			if mountType == 232 or mountType == 254 then
				-- Seahorses
				swimmingScore, swimmingSpell = selectBest(swimmingScore, swimmingSpell, 450+age, spellId)
			end
			if mountType == 248 then
				-- Flying mounts
				groundScore, groundSpell = selectBest(groundScore, groundSpell, 100+age, spellId)
				flyableScore, flyableSpell = selectBest(flyableScore, flyableSpell, 310+age, spellId)
			end
		end
	end
	
	if swimmingScore > 0 and swimmingSpell ~= groundSpell then
		append("[swimming]"..GetSpellInfo(swimmingSpell))
	end
	if flyableScore > 0 and flyableSpell ~= groundSpell then
		append("[flyable]"..GetSpellInfo(flyableSpell))
	end
	if groundScore > 0 then
		append((GetSpellInfo(flyableSpell)))
	end
end