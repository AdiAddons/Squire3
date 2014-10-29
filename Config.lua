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

Squire3_Load(function(addonName, addon)

	local L = addon.L
	
	local options
	
	local function GetOptions()
		if options then return options end

		local function GetTheMacro()
			local MACRO_NAME = addonName
			local MACRO_ICON = "ACHIEVEMENT_GUILDPERK_MOUNTUP"
			local MACRO_BODY = "/click [button:2] Squire3Button RightButton; Squire3Button"

			local index = GetMacroIndexByName(MACRO_NAME)
			if index == 0 then
				CreateMacro(MACRO_NAME, MACRO_ICON, MACRO_BODY, 0)
			else
				EditMacro(index, MACRO_NAME, MACRO_ICON, MACRO_BODY)
			end
			
			PickupMacro(MACRO_NAME)
		end
		
		local specialSpells = {}
		local function GetSpecialSpells()
			wipe(specialSpells)
			for i, spell in ipairs(addon.specialSpells) do
				if IsPlayerSpell(spell.id) then
					specialSpells[spell.id] = GetSpellInfo(spell.id)
				end
			end
			return specialSpells
		end
		
		local cancel = {}
		local function GetCancelList()
			wipe(cancel)
			cancel.mount = L["Dismount"]
			cancel.flying = L["Dismount while flying"]
			cancel.vehicle = L["Leave vehicle"]
			for id, spell in pairs(addon.cancelSpells) do
				if IsPlayerSpell(id) then
					cancel[tostring(id)] = L["Cancel %s"]:format((GetSpellInfo(id)))
				end
			end
			return cancel
		end
		
		local modifiers = {
			none    = L["None"],
			shift   = L["Shift"],
			ctrl    = L["Control"],
			alt     = L["Alt"],
			any     = L["Any"],
		}
	
		local handler = {}
		local L = addon.L
		
		function handler:get(info)
			local key = info[#info]
			return addon.db.profile[key]
		end
		
		function handler:set(info, value)
			local key = info[#info]
			addon.db.profile[key] = value
		end
		
		local profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db)
		profiles.order = -10
		profiles.disabled = false
	
		options = {
			name = addonName,
			handler = handler,
			get = 'get',
			set = 'set',
			type = 'group',
			childGroups = 'tab',
			args = {
				global = {
					name = L['Options'],
					type = 'group',
					order = 10,
					args = {
						macro = {
							name = L['Macro'],
							desc = L["Create and pickup a macro to put in an action slot."],
							type = 'execute',
							func = GetTheMacro,
							disabled = InCombatLockdown,
							order = 0,
						},
						toggleMode = {
							name = L['Two-step mode'],
							desc = L["When enabled, Squire3 will either dismount or mount each click, not both at the same time."],
							type = 'toggle',
							order = 5,
						},
						perCharFavorites = {
							name = L['Per character favorites'],
							desc = L["When enabled, Squire3 will save and restore favorite mounts per character."],
							type = 'toggle',
							order = 8,
						},
						spells = {
							name = L['Use spells'],
							desc = L['Select which spells Squire3 should use.'],
							type = 'multiselect',
							get = function(_, id) return addon.db.profile.spells[id] end,
							set = function(_, id, enabled) addon.db.profile.spells[id] = enabled end,
							values = GetSpecialSpells,
							hidden = function() return not next(GetSpecialSpells()) end,
							order = 10,
						},
						cancel = {
							name = L['Automatically ...'],
							desc = L['Select which action Squire3 should automatically take.'],
							type = 'multiselect',
							get = function(_, key) return addon.db.profile.cancel[key] end,
							set = function(_, key, enabled) addon.db.profile.cancel[key] = enabled end,
							values = GetCancelList,
							order = 20,
						},
						unsafeModifier = {
							name = L['Unsafe modifier'],
							desc = L['Select a modifier to enforce a unsafe behavior (like dismount mid-air).'],
							type = 'select',
							values = modifiers,
							order = 30,
						},
						groundModifier = {
							name = L['Enforce ground mount modifier'],
							desc = L['Select a modifier to select a ground mount even in flyable area.'],
							type = 'select',
							values = modifiers,
							order = 40,
						},
					},
				},
				cvars = {
					name = L['Blizzard settings'],
					desc = L['Built-in settings that interacts with shapeshift forms and mounts.'],
					type = 'group',
					order = -20,
					get = function(info) return GetCVarBool(info[#info]) end,
					set = function(info, value) SetCVar(info[#info], value and 1 or 0) end,
					args = {
						_desc = {
							name = L['Note: these are console variables. They are not affected by profile changes.'],
							type = 'description',
							order = 0,
						},
						autoUnshift = {
							name = "autoUnshift",
							desc = L["When enabled, trying to cast a spell normally unavailable to your current shapeshift form automatically cancels it beforehands. When disabled, you have to unshift first."],
							type = 'toggle',
							order = 10,
						},
						autoDismount = {
							name = "autoDismount",
							desc = L["When enabled, automatically dismount when you cast a spell. When disabled, you have to dismount first."],
							type = 'toggle',
							order = 20,
						},
						autoDismountFlying = {
							name = "autoDismountFlying",
							desc = L["When enabled, automatically dismount when you cast a spell mid-air. When disabled, you have to dismount first."],
							type = 'toggle',
							order = 30,
						}
					},
				},
				profiles = profiles
			}
		}

		return options
	end

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, GetOptions)
	local panel = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName, addonName)
	
	_G.SLASH_SQUIRETHREE1 = "/squire3"
	_G.SLASH_SQUIRETHREE2 = "/sq3"
	_G.SlashCmdList["SQUIRETHREE"] = function()
		InterfaceOptionsFrame_OpenToCategory(panel)
	end

end)
