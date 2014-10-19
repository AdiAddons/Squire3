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

local L = setmetatable({}, {
	__index = function(self, key)
		if key ~= nil then
			--@debug@
			addon.Debug('Missing locale', tostring(key))
			--@end-debug@
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

--------------------------------------------------------------------------------
-- Locales from localization system
--------------------------------------------------------------------------------

-- %Localization: squire3
-- THE END OF THE FILE IS UPDATED BY https://github.com/Adirelle/wowaceTools/#updatelocalizationphp.
-- ANY CHANGE BELOW THESES LINES WILL BE LOST.
-- UPDATE THE TRANSLATIONS AT http://www.wowace.com/addons/squire3/localization/
-- AND ASK THE AUTHOR TO UPDATE THIS FILE.

-- @noloc[[

------------------------ enUS ------------------------


-- Config.lua
L["Alt"] = true
L["Any"] = true
L["Automatically ..."] = true
L["Blizzard settings"] = true
L["Built-in settings that interacts with shapeshift forms and mounts."] = true
L["Cancel %s"] = true
L["Control"] = true
L["Create and pickup a macro to put in an action slot."] = true
L["Dismount while flying"] = true
L["Dismount"] = true
L["Enforce ground mount modifier"] = true
L["Leave vehicle"] = true
L["Macro"] = true
L["None"] = true
L["Note: these are console variables. They are not affected by profile changes."] = true
L["Options"] = true
L["Select a modifier to enforce a unsafe behavior (like dismount mid-air)."] = true
L["Select a modifier to select a ground mount even in flyable area."] = true
L["Select which action Squire3 should automatically take."] = true
L["Select which spells Squire3 should use."] = true
L["Shift"] = true
L["Unsafe modifier"] = true
L["Use spells"] = true
L["When enabled, automatically dismount when you cast a spell mid-air. When disabled, you have to dismount first."] = true
L["When enabled, automatically dismount when you cast a spell. When disabled, you have to dismount first."] = true
L["When enabled, trying to cast a spell normally unavailable to your current shapeshift form automatically cancels it beforehands. When disabled, you have to unshift first."] = true

-- Squire3.lua
L["Use Squire3"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["Alt"] = "Alt" -- Needs review
L["Any"] = "N'importe lequel" -- Needs review
L["Automatically ..."] = "Automatiquement ..." -- Needs review
L["Blizzard settings"] = "Réglages Blizzard" -- Needs review
L["Built-in settings that interacts with shapeshift forms and mounts."] = "Réglages intégrés qui interagissent avec les transformations et les montures." -- Needs review
L["Cancel %s"] = "Annuler %s" -- Needs review
L["Control"] = "Ctrl" -- Needs review
L["Create and pickup a macro to put in an action slot."] = "Créer et prend une macro à mettre dans une barre d'action." -- Needs review
L["Dismount"] = "Démonter" -- Needs review
L["Dismount while flying"] = "Démonter en vol" -- Needs review
L["Enforce ground mount modifier"] = "Modificateur pour forcer une monture terrestre" -- Needs review
L["Leave vehicle"] = "Quitter le véhicule" -- Needs review
L["Macro"] = "Macro" -- Needs review
L["None"] = "Aucun" -- Needs review
L["Note: these are console variables. They are not affected by profile changes."] = "Note : ce sont des variables de consoles. Elles ne sont pas affectées par les changements de profil." -- Needs review
L["Options"] = "Options" -- Needs review
L["Select a modifier to enforce a unsafe behavior (like dismount mid-air)."] = "Sélectionner un modificateur pour outrepasser les sécurites (pour démonter en vol par exemple)." -- Needs review
L["Select a modifier to select a ground mount even in flyable area."] = "Sélectionner une modificateur pour sélectionner une monture terrestre dans les zones où le vol est possible." -- Needs review
L["Select which action Squire3 should automatically take."] = "Sélectionner quelles actions Squire3 doit automatiquement entreprendre." -- Needs review
L["Select which spells Squire3 should use."] = "Sélectionenr quels sorts Squire3 peut utiliser." -- Needs review
L["Shift"] = "Maj" -- Needs review
L["Unsafe modifier"] = "Modificateur \"forcer\"" -- Needs review
L["Use spells"] = "Utiliser les sorts" -- Needs review
L["Use Squire3"] = "Utiliser Squire3" -- Needs review
L["When enabled, automatically dismount when you cast a spell mid-air. When disabled, you have to dismount first."] = "Quand actif, démonte automatiquement en vol pour lancer un sort. Quand inactif, il faut démonter d'abord." -- Needs review
L["When enabled, automatically dismount when you cast a spell. When disabled, you have to dismount first."] = "Quand actif, démonte automatiquement pour lancer un sort. Quand inactif, il faut démonter d'abord." -- Needs review
L["When enabled, trying to cast a spell normally unavailable to your current shapeshift form automatically cancels it beforehands. When disabled, you have to unshift first."] = "Quand actif, lancer un sort normalement interdit pour la transformation courante l'annule. Quand inactif, il faut d'abord annuler la transformation." -- Needs review

------------------------ deDE ------------------------
-- no translation

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
-- no translation

------------------------ zhTW ------------------------
-- no translation

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
-- no translation

------------------------ ptBR ------------------------
-- no translation
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
