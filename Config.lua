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
				CreateMacro(MACRO_NAME, MACRO_ICON, MACRO_BODY)
			else
				EditMacro(index, MACRO_NAME, MACRO_ICON, MACRO_BODY)
			end
			
			PickupMacro(MACRO_NAME)
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
				spells = {
					name = L['Spells and conditions'],
					type = 'group',
					order = 20,
					get = function(info)
						local n = #info
						return addon.db.profile[info[n-1]][info[n]]
					end,
					set = function(info, value)
						local n = #info
						addon.db.profile[info[n-1]][info[n]] = value
					end,
					args = {
						safety = {
							name = L['Safety conditions'],
							order = 10,
							type = 'group',
							inline = true,
							args = {
								_desc = {
									name = L['Squire3 will not do anything if any of the selected condition(s) is met, unless the unsafe modifier is used.'],
									type = 'description',
									order = 0,
								},
							}
						},
						spells = {
							name = L['Use spells'],
							order = 20,
							type = 'group',
							inline = true,
							get = function(info)
								return addon.db.profile.spells[tonumber(info[#info])]
							end,
							set = function(info, value)
								addon.db.profile.spells[tonumber(info[#info])] = value
							end,
							args = {
								_desc = {
									name = L['Squire3 will use the selected spell(s).'],
									type = 'description',
									order = 0,
								},
							}
						},
						cancel = {
							name = L['Automatically cancel/leave'],
							order = 30,
							type = 'group',
							inline = true,
							args = {
								_desc = {
									name = L['Squire3 will automatically cancel the selected state(s) as a part of its operation. Unselected can still be cancelled because of the autoUnshift and autoDismount settings.'],
									type = 'description',
									order = 0,
								},
							}
						},
						dismount = {
							name = L['Dismount'],
							order = 40,
							type = 'group',
							inline = true,
							args = {
								_desc = {
									name = L['Squire3 will include the selected state(s) in its dismount action.'],
									type = 'description',
									order = 0,
								},
							}
						}
					}
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
		
		local toggleGroups = options.args.spells.args

		for i, spell in ipairs(addon.specialSpells) do
			local id = spell.id
			toggleGroups.spells.args[tostring(spell.id)] = {
				name = GetSpellInfo(spell.id),
				type = 'toggle',
				hidden = function() return not IsPlayerSpell(id) end,
				order = id,
			}
		end
		
		for key, state in pairs(addon.states) do
			local key, state = key, state
			local option = { 
				name = function() return state.name end,
				type = 'toggle',
				hidden = function() return not state:IsAvailable() end,
				order = tonumber(key) or 1,
			}
			if state.cancelWith then
				toggleGroups.cancel.args[key] = option
				toggleGroups.dismount.args[key] = option
			end
			if state.condition then
				toggleGroups.safety.args[key] = option
			end
		end
		
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
