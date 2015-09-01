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
--@debug@
_G[addonName] = addon
--@end-debug@

--------------------------------------------------------------------------------
-- Debug stuff
--------------------------------------------------------------------------------

local Debug
if AdiDebug then
	Debug = AdiDebug:GetSink(addonName)
else
	function Debug() end
end
addon.Debug = Debug

--------------------------------------------------------------------------------
-- Default settings
--------------------------------------------------------------------------------

local DEFAULT_SETTINGS = {
	profile = {
		spells = { ['*'] = true },
		dismount = { ['*'] = true },
		cancel = {
			['*'] = false,
		},
		safety = {
			['*'] = false,
			flying = true,
		},
		unsafeModifier = "shift",
		groundModifier = "ctrl",
		toggleMode = false,
		favoriteSection = "global",
	},
	char = {
		favorites = {
			['*'] = false
		}
	},
	global = {
		favorites = {
			['*'] = false
		}
	}
}

--------------------------------------------------------------------------------
-- The secure button
--------------------------------------------------------------------------------

local BUTTON_NAME = "Squire3Button"
local theButton = CreateFrame("Button", BUTTON_NAME, nil, "SecureActionButtonTemplate")

theButton:RegisterForClicks("AnyUp")
theButton:SetScript("PreClick", function(_, button)
	if theButton:CanChangeAttribute() then
		addon:UpdateAction(theButton, button == "dismount" and "dismount" or "mount")
	end
end)

theButton:SetAttribute('type', 'macro')
theButton:SetAttribute('type-dismount', 'macro')

local function IsReallyFlyable(continent)
	if continent == 1 or continent == 2 or continent == 5 then
		-- Kalimdor, Eastern Kingdoms & the Maelstrom require Flight Master's License
		return IsPlayerSpell(90267)
	elseif continent == 4 then
		-- Northrend requires Cold Weather Flying
		return IsPlayerSpell(54197)
	elseif continent == 6 then
		-- Pandaria requires Wisdom of the Four Winds
		return IsPlayerSpell(115913)
	elseif continent == 7 then
		-- Draenor requires Draenor Pathfinder
		return IsPlayerSpell(191645)
	elseif continent == 3 then
		-- Outland requires Expert Riding or above
		return IsPlayerSpell(90265)	-- Master
			or IsPlayerSpell(34091)	-- Artisan
			or IsPlayerSpell(34090)	-- Expert
	end
	return false
end

local env = { continent = 0 }
function addon:UpdateAction(widget, button)
	env.moving = GetUnitSpeed("player") > 0 or IsFalling()
	env.combat = button == "combat" or InCombatLockdown()
	env.indoors = IsIndoors()
	env.reallyFlyable = not IsInInstance() and IsReallyFlyable(env.continent)
	addon:Debug('continent=', env.continent, 'in instance=',  IsInInstance(), 'really flyable=', env.reallyFlyable)
	env.canMount = not (env.moving or env.combat or env.indoors)
	local suffix = (button == "dismount") and "-dismount" or ""
	widget:SetAttribute("macrotext"..suffix, addon:BuildMacro(button, env, self.db.profile))
end

addon.button = theButton

--------------------------------------------------------------------------------
-- Event handling
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript('OnEvent', function(_, event, ...) return addon[event](addon, event, ...) end)

function addon:PLAYER_REGEN_DISABLED()
	self:UpdateAction(theButton, "combat")
end

function addon:ADDON_LOADED(event, name)
	if name ~= addonName then return end

	self.db = LibStub('AceDB-3.0'):New(addonName.."DB", DEFAULT_SETTINGS, true)

	if self.db.profile.perCharFavorites then
		self.db.profile.favoriteSection = "char"
		self.db.profile.perCharFavorites = nil
	end

	self.db.RegisterCallback(self, 'OnDatabaseShutdown', function() return self:SaveFavorites() end)

	eventFrame:RegisterEvent('COMPANION_UPDATE')
	eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
	eventFrame:RegisterEvent('UPDATE_SHAPESHIFT_FORMS')
	eventFrame:RegisterEvent('SPELLS_CHANGED')
	eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')

	hooksecurefunc('SetMapToCurrentZone', function()
		env.continent = GetCurrentMapContinent()
	end)

	if IsAddOnLoaded("Blizzard_PetJournal") then
		self:Blizzard_PetJournal_Loaded(event, "Blizzard_PetJournal")
	else
		self.ADDON_LOADED = self.Blizzard_PetJournal_Loaded
	end
end
eventFrame:RegisterEvent('ADDON_LOADED')

function addon:PLAYER_ENTERING_WORLD(event)
	self:MountsLoaded(event)
end

function addon:COMPANION_UPDATE(event, type)
	if type then return end
	self:MountsLoaded(event)
end

function addon:MountsLoaded(event)
	addon:Debug('Mounts loaded on', event)
	eventFrame:UnregisterEvent('COMPANION_UPDATE')
	eventFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	self:ScanSpecialMounts()
	self:RestoreFavorites()
	SetMapToCurrentZone()
end

function addon:UPDATE_SHAPESHIFT_FORMS()
	self:RefreshStates()
end

function addon:SPELLS_CHANGED()
	eventFrame:UnregisterEvent('SPELLS_CHANGED')
	self:RefreshStates()
end

-- Configuration loading helper
function _G.Squire3_Load(callback)
	return callback(addonName, addon)
end

function addon:Blizzard_PetJournal_Loaded(event, name)
	if name ~= "Blizzard_PetJournal" then return end
	eventFrame:UnregisterEvent('ADDON_LOADED')
	addon:Debug("Blizzard_PetJournal_Loaded", event, name)

	hooksecurefunc(MountJournal.mountOptionsMenu, 'initialize', function(_, level)
		return self:MountOptionsMenu_Init(level)
	end)
end

function addon:ScanSpecialMounts()
	for index = 1, C_MountJournal.GetNumMounts() do
		local name, spellId, _, _, _, _, _, _, _, hideOnChar = C_MountJournal.GetMountInfo(index)
		local _, canFavorite = C_MountJournal.GetIsFavorite(index)
		if not canFavorite and not hideOnChar and not addon.specialMounts[spellId] then
			addon:Debug('Cannot set as favorite:', name)
			addon:RegisterSpecialMounts(spellId)
		end
	end
end

--------------------------------------------------------------------------------
-- Hook Blizzard_PetJournal mount dropdown
--------------------------------------------------------------------------------

local L = addon.L

function addon:MountOptionsMenu_Init(level)
	if level ~= 1 then return end

	local index = MountJournal.menuMountID
	if not index then return end

	local _, spellId = C_MountJournal.GetMountInfo(index)
	if not self.specialMounts[spellId] then return end

	-- Erase then cancel button
	local dropDownFrame = _G["DropDownList"..level]
	self:Debug('MountOptionsMenu_Init', level, dropDownFrame, dropDownFrame.numButtons)
	dropDownFrame.numButtons = dropDownFrame.numButtons - 1

	local favorites = self:GetFavoriteDB()
	local info = UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	local isFavorite = favorites[spellId]
	info.text = isFavorite and L["Remove from Squire3 favorites"] or L["Add to Squire3 favorites"]
	info.func = function() favorites[spellId] = not isFavorite end

	UIDropDownMenu_AddButton(info, level)

	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

--------------------------------------------------------------------------------
-- Favorites
--------------------------------------------------------------------------------

function addon:GetFavoriteDB()
	return self.db[self.db.profile.favoriteSection].favorites
end

local function favoriteIterator(num, index)
	while index < num do
		index = index + 1
		local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(index)
		if canFavorite then
			local _, spellId, _, _, _, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfo(index) C_MountJournal.GetMountInfo(index)
			if isCollected and not hideOnChar then
				return index, spellId, isFavorite
			end
		end
	end
end

local function iterateFavorites()
	return favoriteIterator, C_MountJournal.GetNumMounts(), 0
end

function addon:SaveFavorites()
	local favorites = self:GetFavoriteDB()
	for index, spellId, isFavorite in iterateFavorites() do
		favorites[spellId] = isFavorite
	end
end

function addon:RestoreFavorites()
	local favorites = self:GetFavoriteDB()
	for index, spellId, isFavorite in iterateFavorites() do
		local saved = favorites[spellId] or false
		if saved ~= isFavorite then
			self:Debug("Restoring favorite status of", index, spellId, GetSpellInfo(spellId), ":", saved, "actual:", isFavorite)
			C_MountJournal.SetIsFavorite(index, saved)
		end
	end
end

--------------------------------------------------------------------------------
-- Binding localization
--------------------------------------------------------------------------------

_G["BINDING_HEADER_SQUIRE3"] = addonName
_G["BINDING_NAME_CLICK Squire3Button:LeftButton"] = addon.L["Use Squire3"]
_G["BINDING_NAME_CLICK Squire3Button:dismount"] = addon.L["Dismount"]
