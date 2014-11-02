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
-- Handle forms
--------------------------------------------------------------------------------

local forms = {}
function addon:GetCancelFormCondition(cancel, reverse)
	reverse = reverse or false
	local count, numForms = 0, GetNumShapeshiftForms()
	for index = 1, numForms do
		local spellId = select(5, GetShapeshiftFormInfo(index))
		if cancel[tostring(spellId)] ~= reverse then
			count = count + 1
			forms[count] = index
		end
	end
	if count == 0 then
		return false
	end
	if count == numForms then
		return "form"
	end
	return "form:"..table.concat(forms, "/", 1, count)
end

--------------------------------------------------------------------------------
-- Main building method
--------------------------------------------------------------------------------

do
	local parts, numParts, currentCmd, done = {}

	local function doAppend(cmd, arg)
		if cmd == currentCmd then
			parts[numParts+1] = ";"
		else
			parts[numParts+1] = "\n/"..cmd.." "
			currentCmd = cmd
		end
		parts[numParts+2] = arg
		numParts = numParts + 2
	end

	local function append(cmd, arg, ...)
		if arg then
			return doAppend(cmd, arg), append(cmd, ...)
		end
	end

	local handlers = {
		mount = { 'AddSafetyStop', 'AddToggleStop', 'AddMounts', 'AddSpells', 'AddCancels' },
		dismount = { 'AddSafetyStop', 'AddCancels' },
	}

	function addon:BuildMacro(button, env, settings)
		numParts, done, currentCmd = 0, false

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
	local cancelForms = self:GetCancelFormCondition(settings.cancel, true)
	if cancelForms then
		append("stopmacro", format('[%s%s]', cancelForms, modifier))
	end
end

function addon:AddCancels(append, env, settings)
	for id, type in pairs(cancelSpells) do
		if IsPlayerSpell(id) and type:match("aura") and settings.cancel[tostring(id)] then
			append("cancelaura", (GetSpellInfo(id)))
		end
	end
	local cancelForms = self:GetCancelFormCondition(settings.cancel)
	if cancelForms then
		append("cancelform", '['..cancelForms..']')
	end
	if settings.cancel.vehicle then
		append("leavevehicle", "[vehicleui,canexitvehicle]")
	end
	if settings.cancel.mount then
		append("dismount", "[mounted]")
	end
end

function addon:AddToggleStop(append, env, settings)
	if not settings.toggleMode then return end
	if settings.cancel.vehicle then
		append("cast", "[vehicleui,canexitvehicle]")
	end
	if settings.cancel.mount then
		append("cast", "[mounted]")
	end
	local cancelForms = self:GetCancelFormCondition(settings.cancel)
	if cancelForms then
		append("cast", '['..cancelForms..']')
	end
end

--------------------------------------------------------------------------------
-- Selection contexts
--------------------------------------------------------------------------------

local context_mt = { __index = {
	Reset = function(self)
		self.speed, self.count = 0, 0
	end,
	Update = function(self, id, speed)
		if not speed or speed < self.speed then
			return
		end
		if speed > self.speed then
			self.speed, self.count = speed, 0
		end
		self.count = self.count + 1
		self.ids[self.count] = id
	end,
	GetRandom = function(self)
		if self.count > 0 then
			return self.ids[math.random(1, self.count)]
		end
	end
}}

local contexts = {
	ground   = setmetatable({ ids = {} }, context_mt),
	flying   = setmetatable({ ids = {} }, context_mt),
	swimming = setmetatable({ ids = {} }, context_mt),

	Reset = function(self)
		self.ground:Reset()
		self.flying:Reset()
		self.swimming:Reset()
	end,

	Update = function(self, id, groundSpeed, flyingSpeed, swimmingSpeed)
		self.ground:Update(id, groundSpeed)
		self.flying:Update(id, flyingSpeed)
		self.swimming:Update(id, swimmingSpeed)
	end
}

--------------------------------------------------------------------------------
-- Combat spell part
--------------------------------------------------------------------------------

function addon:AddSpells(append, env, settings)
	if env.canMount then return end
	for index, spell in ipairs(specialSpells) do
		if IsPlayerSpell(spell.id) and settings.spells[spell.id] then
			local condition = spell.condition
			local _, pos = strfind(condition, "%Aflyable")
			if pos then
				condition = strsub(condition, 1, pos)..GetModifierCondition(settings.groundModifier, ",no")..strsub(condition, pos+1)
			end
			local ensure = settings.toggleMode and "" or "!"
			append("cast", format("%s%s%s", condition, ensure, GetSpellInfo(spell.id)))
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

function addon:AddMounts(append, env, settings)
	if not env.canMount then return end
	contexts:Reset()

	for spellId, groundSpeed, flyingSpeed, swimmingSpeed in self:IterateMounts(env, settings) do
		contexts:Update(spellId, groundSpeed, flyingSpeed, swimmingSpeed)
	end

	local flyingSpell = contexts.flying:GetRandom()
	local groundSpell = contexts.ground:GetRandom()
	local swimmingSpell = contexts.swimming:GetRandom()

	local ensure = settings.toggleMode and "" or "!"
	if swimmingSpell then
		append("cast", format("[swimming]%s%s", ensure, GetSpellInfo(swimmingSpell)))
	end
	if flyingSpell then
		append("cast", format("[flyable%s]%s%s", GetModifierCondition(settings.groundModifier, ",no"), ensure, GetSpellInfo(flyingSpell)))
	end
	if groundSpell then
		append("cast", ensure..GetSpellInfo(groundSpell))
	end
end
