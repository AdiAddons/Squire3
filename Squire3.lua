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
-- Create the secure button
--------------------------------------------------------------------------------

local BUTTON_NAME = "Squire3Button"
local theButton = CreateFrame("Button", BUTTON_NAME, nil, "SecureActionButtonTemplate")

theButton:RegisterForClicks("AnyUp")
theButton:SetScript("PreClick", function(_, button)
	if theButton:CanChangeAttribute() then
		addon:UpdateAction(theButton, button == "dismount" and "dismount" or "mount")
	end
end)

theButton:RegisterEvent('PLAYER_REGEN_DISABLED')
theButton:SetScript('OnEvent', function() addon:UpdateAction(theButton, "combat") end)

theButton:SetAttribute('type', 'macro')

theButton:SetAttribute('type-dismount', 'macro')
theButton:SetAttribute('macrotext-dismount', "/dismount\n/cancelform\n/leavevehicle")

addon.button = theButton

--------------------------------------------------------------------------------
-- Create the macro
--------------------------------------------------------------------------------
--[=[
do
	local MACRO_NAME = addonName
	local MACRO_ICON = [[Ability_Mount_RidingHorse]]
	local MACRO_BODY = format("/click [button:2] %s RightButton; %s", BUTTON_NAME, BUTTON_NAME)

	local index = GetMacroIndexByName(MACRO_NAME)
	if index == 0 then
		CreateMacro(MACRO_NAME, MACRO_ICON, MACRO_BODY, 0)
	else
		EditMacro(index, MACRO_NAME, MACRO_ICON, MACRO_BODY)
	end
end
--]=]

--------------------------------------------------------------------------------
-- Binding localization
--------------------------------------------------------------------------------

_G["BINDING_HEADER_SQUIRE3"] = addonName
_G["BINDING_NAME_CLICK Squire3Button:LeftButton"] = addon.L["Use Squire3"]
_G["BINDING_NAME_CLICK Squire3Button:dismount"] = addon.L["Dismount"]

--------------------------------------------------------------------------------
-- Updating
--------------------------------------------------------------------------------

local env = {}
local settings = {}
function addon:UpdateAction(widget, button)
	env.moving = GetUnitSpeed("player") > 0 or IsFalling()
	env.combat = button == "combat" or InCombatLockdown()
	env.indoors = IsIndoors()
	env.canMount = not (env.moving or env.combat or env.indoors)
	widget:SetAttribute("macrotext", addon:BuildMacro(button, env, settings))
end
