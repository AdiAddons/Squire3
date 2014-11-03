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

local L = addon.L

--------------------------------------------------------------------------------
-- States
--------------------------------------------------------------------------------

local function AlwaysTrue()
	return true
end

local function NoCondition(self, modifier)
	return
end

local function GetCondition(self, modifier)
	return format('[%s%s]', self.condition, modifier or "")
end

local function GetCancelArgs(self, modifier)
	return self.cancelWith, self:GetCondition(modifier)
end

local function GetCancelAuraArgs(self, modifier)
	return "cancelaura", (self:GetCondition(modifier) or "")..GetSpellInfo(self.spellId)
end

local states = {
	mount = {
		name          = L['Mounts'],
		condition     = "mounted",
		cancelWith    = "dismount",
		IsAvailable   = AlwaysTrue,
		IsUsable      = AlwaysTrue,
		GetCondition  = GetCondition,
		GetCancelArgs = GetCancelArgs,
	},
	flying = {
		name          = L['Flying'],
		condition     = "flying",
		IsAvailable   = AlwaysTrue,
		IsUsable      = function(self, env) return not env.instance end,
		GetCondition  = GetCondition,
		GetCancelArgs = GetCancelArgs,
	},
	vehicle = {
		name          = L['Vehicles'],
		condition     = "vehicleui,canexitvehicle",
		cancelWith    = "leavevehicle",
		IsAvailable   = AlwaysTrue,
		IsUsable      = AlwaysTrue,
		GetCondition  = GetCondition,
		GetCancelArgs = GetCancelArgs,
	}
}
local orderedCancels = {}
local orderedConditions = {}
addon.states = states

function addon:RegisterCancelSpells(id, type, ...)
	states[tostring(id)] = {
		spellId       = id,
		isForm        = type:match("form"),
		cancelWith    = type:match("aura") and "cancelaura" or "cancelform",
		IsAvailable   = function() return IsPlayerSpell(id) end,
		IsUsable      = AlwaysTrue,
		GetCondition  = NoCondition,
		GetCancelArgs = type:match("aura") and GetCancelAuraArgs or GetCancelArgs
	}
	if ... then
		return self:RegisterCancelSpells(...)
	end
end

local function compareConditions(a, b)
	return (states[a].condition or "") < (states[b].condition or "")
end

local function compareCancelWith(a, b)
	if states[a].cancelWith == states[b].cancelWith then
		return compareConditions(a, b)
	end
	return states[a].cancelWith < states[b].cancelWith
end

local formMap = {}
function addon:RefreshStates()
	wipe(formMap, orderedCancels, orderedConditions)
	for index = 1, GetNumShapeshiftForms() do
		formMap[select(5, GetShapeshiftFormInfo(index))] = index
	end
	for key, state in pairs(states) do
		if state.spellId then
			state.name = GetSpellInfo(state.spellId) or format('#%d', state.spellId)
		end
		if state.isForm then
			state.condition = formMap[state.spellId] and format("form:%d", formMap[state.spellId]) or nil
		end
		if state.condition then
			tinsert(orderedConditions, key)
		end
		if state.cancelWith then
			tinsert(orderedCancels, key)
		end
	end
	sort(orderedConditions, compareConditions)
	sort(orderedCancels, compareCancelWith)
end

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
-- Special mounts
--------------------------------------------------------------------------------
-- Listed in mounts but cannot be set as favorite

local specialMounts = {}
function addon:RegisterSpecialMounts(id, ...)
	if id then
		specialMounts[id] = true
		return self:RegisterSpecialMounts(...)
	end
end
addon.specialMounts = specialMounts

--------------------------------------------------------------------------------
-- Main building method
--------------------------------------------------------------------------------

do
	local parts, numParts, currentCmd, done = {}

	local function doAppend(cmd, arg)
		if cmd == currentCmd then
			local lastArg = parts[numParts]
			if arg == lastArg then
				return
			end
			local suffixPos, _, suffix = strfind(lastArg, '%]([^%[%]]*)$')
			if suffixPos and suffix == strmatch(arg, '%]([^%[%]]*)$') then
				local _, pos, forms = strfind(lastArg, '%[form:([%d/]+)')
				if forms then
					local newForms = strmatch(arg, '%[form:([%d/]+)')
					if newForms then
						parts[numParts] = strsub(lastArg, 1, pos) .. '/' .. newForms .. strsub(lastArg, pos+1)
						return
					end
				end
				parts[numParts] = strsub(lastArg, 1, suffixPos)
			else
				numParts = numParts + 1
				parts[numParts] = ";"
			end
		else
			numParts = numParts + 1
			parts[numParts] = "\n/"..cmd.." "
			currentCmd = cmd
		end
		numParts = numParts + 1
		parts[numParts] = arg
	end

	local function append(cmd, arg, ...)
		if arg then
			return doAppend(cmd, arg), append(cmd, ...)
		end
	end

	local handlers = {
		mount = { 'AddSafetyStop', 'AddCancels', 'AddToggle', 'AddMounts', 'AddSpells', 'AddDismount' },
		dismount = { 'AddSafetyStop', 'AddCancels', 'AddDismount' },
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
	for i, key in ipairs(orderedConditions) do
		local state = states[key]
		if settings.safety[key] and state:IsAvailable() and state:IsUsable(env) then
			append("stopmacro", state:GetCondition(modifier))
		end
	end
end

function addon:AddCancels(append, env, settings)
	for i, key in ipairs(orderedCancels) do
		local state = states[key]
		if settings.cancel[key] and state:IsAvailable() and state:IsUsable(env) then
			append(state:GetCancelArgs())
		end
	end
end

function addon:AddToggle(append, env, settings)
	if not settings.toggleMode then return end
	for i, key in ipairs(orderedConditions) do
		local state = states[key]
		if settings.dismount[key] and state:IsAvailable() and state:IsUsable(env) then
			append("cast", state:GetCondition())
		end
	end
end

function addon:AddDismount(append, env, settings)
	for i, key in ipairs(orderedCancels) do
		local state = states[key]
		if settings.dismount[key] and not settings.cancel[key] and state:IsAvailable() and state:IsUsable(env) then
			append(state:GetCancelArgs())
		end
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
	local toggle, dismount = settings.toggleMode, settings.dismount
	for index, spell in ipairs(specialSpells) do
		if IsPlayerSpell(spell.id) and settings.spells[spell.id] then
			local condition = spell.condition
			local _, pos = strfind(condition, "%Aflyable")
			if pos then
				condition = strsub(condition, 1, pos)..GetModifierCondition(settings.groundModifier, ",no")..strsub(condition, pos+1)
			end
			if env.instance then
				local a, b = strfind(condition, ",?noflyable,?")
				if a and b then
					condition = strsub(condition, 1, a-1) .. strsub(condition, b+1)
				end
			end
			if not pos or not env.instance then
				append("cast", format("%s%s%s",
					condition,
					toggle and dismount[spell.id] and "" or "!",
					(GetSpellInfo(spell.id))
				))
			end
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
			if isUsable and isCollected and (isFavorite or specialMounts[spellId] and settings.spells[spellId]) and not hideOnChar then
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

	local flyingSpell = not env.instance and contexts.flying:GetRandom()
	local groundSpell = contexts.ground:GetRandom()
	local swimmingSpell = contexts.swimming:GetRandom()

	local toggle, dismount = settings.toggleMode, settings.dismount
	if swimmingSpell then
		append("cast", format(
			"[swimming]%s%s",
			toggle and dismount[swimmingSpell] and "" or "!",
			(GetSpellInfo(swimmingSpell))
		))
	end
	if flyingSpell then
		append("cast", format(
			"[flyable%s]%s%s",
			GetModifierCondition(settings.groundModifier, ",no"),
			toggle and dismount[flyingSpell] and "" or "!",
			(GetSpellInfo(flyingSpell))
		))
	end
	if groundSpell then
		append("cast", format(
			"%s%s",
			toggle and dismount[groundSpell] and "" or "!",
			(GetSpellInfo(groundSpell))
		))
	end
end
