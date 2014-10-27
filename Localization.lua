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
L["Two-step mode"] = true
L["Unsafe modifier"] = true
L["Use spells"] = true
L["When enabled, Squire3 will either dismount or mount each click, not both at the same time."] = true
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
elseif locale == 'deDE' then
L["Alt"] = "ALT"
L["Any"] = "Jeder"
L["Automatically ..."] = "Automatisch..."
L["Blizzard settings"] = "Blizzard-Einstellungen"
L["Cancel %s"] = "%s abbrechen"
L["Control"] = "STRG"
L["Dismount"] = "Absitzen"
L["Dismount while flying"] = "Abzitzen im Flug"
L["Leave vehicle"] = "Fahrzeug verlassen"
L["Macro"] = "Makro"
L["None"] = "Keiner"
L["Options"] = "Einstellungen"
L["Shift"] = "SHIFT"

------------------------ esMX ------------------------
elseif locale == 'esMX' then
L["Alt"] = "Alt"
L["Any"] = "Cualquier"
L["Automatically ..."] = "Automáticamente..."
L["Blizzard settings"] = "Opciones de Blizzard"
L["Built-in settings that interacts with shapeshift forms and mounts."] = "Opciones que se incluyen en el juego y se afectan el comportamiento de formas y monturas."
L["Cancel %s"] = "Cancelar %s"
L["Control"] = "Ctrl"
L["Create and pickup a macro to put in an action slot."] = "Crea y recoge un macro para poner en un botón de acción."
L["Dismount"] = "Desmontar"
L["Dismount while flying"] = "Desmontar en vuelo"
L["Enforce ground mount modifier"] = "Modificador para usar montura de tierra"
L["Leave vehicle"] = "Salir del vehículo"
L["Macro"] = "Macro"
L["None"] = "Ningún"
L["Note: these are console variables. They are not affected by profile changes."] = "Notas: Estos son variables de la consola. Ellas no se ven afectadas por los cambios del perfíl."
L["Options"] = "Opciones"
L["Select a modifier to enforce a unsafe behavior (like dismount mid-air)."] = "Seleccione un modificador para ejecutar un acción inseguro, como desmontar en vuelo."
L["Select a modifier to select a ground mount even in flyable area."] = "Seleccione un modificador para usar una montura de tierra en una zona donde puedes volar."
L["Select which action Squire3 should automatically take."] = "Seleccione el acción que Squire3 debe hacer automáticamente."
L["Select which spells Squire3 should use."] = "Seleccione los hechizos que Squire3 debe usar."
L["Shift"] = "Mayús"
L["Unsafe modifier"] = "Modificador inseguro"
L["Use spells"] = "Usar hechizos"
L["Use Squire3"] = "Usar Squire3"
L["When enabled, automatically dismount when you cast a spell mid-air. When disabled, you have to dismount first."] = "Cuando se activa, desmontas automáticamente al lanzar un hechizo en vuelo. Cuando no se activa, primero debes desmontar."
L["When enabled, automatically dismount when you cast a spell. When disabled, you have to dismount first."] = "Cuando se activa, desmontas automáticamente al lanzar un hechizo. Cuando no se activa, primero debes desmontar."
L["When enabled, trying to cast a spell normally unavailable to your current shapeshift form automatically cancels it beforehands. When disabled, you have to unshift first."] = "Cuando se activa, cancelas automáticamente el cambio de forma al lanzar un hechizo que no puede ser lanzado en tu forma actuál. Cuando no se activa, primero debes cancelar la forma."

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
elseif locale == 'esES' then
L["Alt"] = "Alt"
L["Any"] = "Cualquier"
L["Automatically ..."] = "Automáticamente..."
L["Blizzard settings"] = "Opciones de Blizzard"
L["Built-in settings that interacts with shapeshift forms and mounts."] = "Opciones que se incluyen en el juego y se afectan el comportamiento de formas y monturas."
L["Cancel %s"] = "Cancelar %s"
L["Control"] = "Ctrl"
L["Create and pickup a macro to put in an action slot."] = "Crea y recoge un macro para poner en un botón de acción."
L["Dismount"] = "Desmontar"
L["Dismount while flying"] = "Desmontar en vuelo"
L["Enforce ground mount modifier"] = "Modificador para usar montura de tierra"
L["Leave vehicle"] = "Salir del vehículo"
L["Macro"] = "Macro"
L["None"] = "Ningún"
L["Note: these are console variables. They are not affected by profile changes."] = "Notas: Estos son variables de la consola. Ellas no se ven afectadas por los cambios del perfíl."
L["Options"] = "Opciones"
L["Select a modifier to enforce a unsafe behavior (like dismount mid-air)."] = "Seleccione un modificador para ejecutar un acción inseguro, como desmontar en vuelo."
L["Select a modifier to select a ground mount even in flyable area."] = "Seleccione un modificador para usar una montura de tierra en una zona donde puedes volar."
L["Select which action Squire3 should automatically take."] = "Seleccione el acción que Squire3 debe hacer automáticamente."
L["Select which spells Squire3 should use."] = "Seleccione los hechizos que Squire3 debe usar."
L["Shift"] = "Mayús"
L["Unsafe modifier"] = "Modificador inseguro"
L["Use spells"] = "Usar hechizos"
L["Use Squire3"] = "Usar Squire3"
L["When enabled, automatically dismount when you cast a spell mid-air. When disabled, you have to dismount first."] = "Cuando se activa, desmontas automáticamente al lanzar un hechizo en vuelo. Cuando no se activa, primero debes desmontar."
L["When enabled, automatically dismount when you cast a spell. When disabled, you have to dismount first."] = "Cuando se activa, desmontas automáticamente al lanzar un hechizo. Cuando no se activa, primero debes desmontar."
L["When enabled, trying to cast a spell normally unavailable to your current shapeshift form automatically cancels it beforehands. When disabled, you have to unshift first."] = "Cuando se activa, cancelas automáticamente el cambio de forma al lanzar un hechizo que no puede ser lanzado en tu forma actuál. Cuando no se activa, primero debes cancelar la forma."

------------------------ zhTW ------------------------
-- no translation

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
elseif locale == 'koKR' then
L["Alt"] = "Alt"
L["Any"] = "Any"
L["Automatically ..."] = "자동화"
L["Blizzard settings"] = "블리자드 설정"
L["Built-in settings that interacts with shapeshift forms and mounts."] = "태세 변환과 탈것에 대한 행동을 변경하는 설정입니다."
L["Cancel %s"] = "취소 %s"
L["Control"] = "Ctrl"
L["Create and pickup a macro to put in an action slot."] = "매크로를 생성하여 행동 바에 넣습니다."
L["Dismount"] = "해제"
L["Dismount while flying"] = "비행시 해제"
L["Enforce ground mount modifier"] = "지상 탈것 강제 기능키"
L["Leave vehicle"] = "탈것 내리기"
L["Macro"] = "매크로"
L["None"] = "None"
L["Note: these are console variables. They are not affected by profile changes."] = "중요: 이것은 콘솔의 변수입니다. 프로필 변경이 적용되지 않습니다."
L["Options"] = "설정"
L["Select a modifier to enforce a unsafe behavior (like dismount mid-air)."] = "불완전한 행동을 할 수 있는 기능키를 선택합니다. (이를테면 하늘에서 내리기)"
L["Select a modifier to select a ground mount even in flyable area."] = "비행가능 지역에서 지상 탈것으로 선택할 때 기능키를 선택합니다."
L["Select which action Squire3 should automatically take."] = "비행하는 동안 Squire3가 자동으로 진행해야 하는 것을 선택합니다."
L["Select which spells Squire3 should use."] = "Squire3가 사용하는 주문을 선택합니다."
L["Shift"] = "Shift"
L["Unsafe modifier"] = "불완전한 행동 기능키"
L["Use spells"] = "주문 사용"
L["Use Squire3"] = "Squire3 사용"
L["When enabled, automatically dismount when you cast a spell mid-air. When disabled, you have to dismount first."] = "선택하면 하늘에서 주문을 시전하면 자동으로 탈것에서 내립니다. 탈것에서 먼저 내리면 불가능합니다."
L["When enabled, automatically dismount when you cast a spell. When disabled, you have to dismount first."] = "선택하면 주문을 시전할 때 탈것에서 내립니다. 탈것에서 먼저 내리면 불가능합니다."
L["When enabled, trying to cast a spell normally unavailable to your current shapeshift form automatically cancels it beforehands. When disabled, you have to unshift first."] = "선택하면 태세 또는 변신시 사용할 수 없는 주문을 시전할 때 자동으로 먼저 취소합니다. 반드시 변신전에 시전해야 합니다."

------------------------ ptBR ------------------------
-- no translation
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
