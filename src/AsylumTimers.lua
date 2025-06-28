AT = { name = "AsylumTimers" }

local function updateFont(font)
	AsylumTimers_LlothisTitle:SetFont(font)
	AsylumTimers_LlothisTimer:SetFont(font)
	AsylumTimers_FelmsTitle:SetFont(font)
	AsylumTimers_FelmsTimer:SetFont(font)
end

local function formatSeconds(seconds)
	return string.format("%d:%02d", math.floor(seconds/60), seconds%60)
end

function AT.updateText()
	AsylumTimers_LlothisTimer:SetText(formatSeconds(AT.time_Llothis))
	AsylumTimers_FelmsTimer:SetText(formatSeconds(AT.time_Felms))
	
	if AT.time_Llothis > 0 then 
		AT.time_Llothis = AT.time_Llothis - 1 
	elseif AT.isLlothisEnraged == false and AT.hasLlothisSpawned then
		AT.isLlothisEnraged = true
		AsylumTimers_LlothisTimer:SetColor(1.0, 0.0, 0.0, 1.0)
	end
	if AT.time_Felms > 0 then 
		AT.time_Felms = AT.time_Felms - 1 
	elseif AT.isFelmsEnraged == false and AT.hasFelmsSpawned then
		AT.isFelmsEnraged = true
		AsylumTimers_FelmsTimer:SetColor(1.0, 0.0, 0.0, 1.0)
	end
end

function AT.onEffect(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID, sourceType)
	if abilityID == 99990 then --Dormant
		if changeType == EFFECT_RESULT_GAINED  then
			
			if unitName == "Saint Llothis the Pious^M" then
				if AT.savedVariables.debugMessages then AT.chat:Print("Llothis Died!") end
				
				AT.time_Llothis = 45
				AsylumTimers_LlothisTimer:SetColor(0.0, 1.0, 0.0, 1.0)
				AT.isLlothisEnraged = false
			elseif unitName == "Saint Felms the Bold^M" then
				if AT.savedVariables.debugMessages then AT.chat:Print("Felms Died!") end
				
				AT.time_Felms = 45
				AsylumTimers_FelmsTimer:SetColor(0.0, 1.0, 0.0, 1.0)
				AT.isFelmsEnraged = false
			end
		
		elseif changeType == EFFECT_RESULT_FADED then
			
			if unitName == "Saint Llothis the Pious^M" then
				if AT.savedVariables.debugMessages then AT.chat:Print("Llothis Respawned!") end
				
				AT.time_Llothis = 180
				AsylumTimers_FelmsTimer:SetColor(1.0, 1.0, 1.0, 1.0)
			elseif unitName == "Saint Felms the Bold^M" then
				if AT.savedVariables.debugMessages then AT.chat:Print("Felms Respawned!") end
				
				AT.time_Felms = 180
				AsylumTimers_FelmsTimer:SetColor(1.0, 1.0, 1.0, 1.0)
			end
			
		end
	end
end

function AT.onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _log, sourceUnitID, targetUnitID, abilityID, overflow)
	if AT.hasLlothisSpawned == false and sourceName == "Saint Llothis the Pious^M" then
		if AT.savedVariables.debugMessages then AT.chat:Print("Llothis Spawned! (Initial)") end
		
		AT.hasLlothisSpawned = true
		AT.time_Llothis = 180
	elseif AT.hasFelmsSpawned == false and sourceName == "Saint Felms the Bold^M" then
		if AT.savedVariables.debugMessages then AT.chat:Print("Felms Spawned! (Initial) (CombatEvent)") end
		
		AT.hasFelmsSpawned = true
		AT.time_Felms = 180
	end
end

function AT.onWipe(eventCode)
	zo_callLater(function ()
		if IsUnitInCombat("player") == false and IsUnitDead("player") == false then
			AsylumTimers_FelmsTimer:SetColor(1.0, 1.0, 1.0, 1.0)
			AT.time_Felms = 0
			AT.time_Llothis = 0
			AT.hasLlothisSpawned = false
			AT.hasFelmsSpawned = false
			AT.isLlothisEnraged = false
			AT.isFelmsEnraged = false
		end
	end, 2000)
end

function AT.onNewZone(eventCode, initial)
	local zoneID, _, _, _ = GetUnitRawWorldPosition("player")
	
	if zoneID == 1000 then
		AsylumTimers:SetHidden(false)
		if AT.isRegistered == false then
			AT.isRegistered = true
			
			EVENT_MANAGER:RegisterForUpdate(AT.name, 1000, AT.updateText)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_EFFECT_CHANGED, AT.onEffect)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_ALIVE, AT.onWipe)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_COMBAT_EVENT, AT.onCombatEvent)
		end
	else
		AsylumTimers:SetHidden(true)
		if AT.isRegistered then 
			AT.isRegistered = false
			
			EVENT_MANAGER:UnregisterForUpdate(AT.name, AT.updateText)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_EFFECT_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_PLAYER_ALIVE)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_COMBAT_EVENT)
		end
	end
end

function AT.Initialize()

	AT.defaults = {
		debugMessages = false,
		
		selectedFontNumber_Timers = "22",
		selectedFontName_Timers = "ZoFontGamepad22",
		
		checked = false,
		offset_x = 0,
		offset_y = 0,
	}
	

	AT.isRegistered = false
	AT.time_Llothis = 0
	AT.time_Felms = 0
	AT.hasLlothisSpawned = false
	AT.hasFelmsSpawned = false
	AT.isLlothisEnraged = false
	AT.isFelmsEnraged = false

	AT.chat = LibChatMessage("AsylumTimers", "AT") 
	LibChatMessage:SetTagPrefixMode(1)
	
	AT.savedVariables = ZO_SavedVars:NewAccountWide("ATSavedVariables", 1, nil, AT.defaults, GetWorldName())
	updateFont(AT.savedVariables.selectedFontName_Timers)	
	AsylumTimers:ClearAnchors()
	AsylumTimers:SetAnchor(3, GuiRoot, 3, AT.savedVariables.offset_x, AT.savedVariables.offset_y)

	AT.onNewZone(_, _)
	
	--settings
	local settings = LibHarvensAddonSettings:AddAddon("Asylum Timers")
	local areSettingsDisabled = false
	
	local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
	local timerSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Timers",}
	
	local toggle = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Disable", 
        tooltip = "Disables the addon's displays.",
        default = AT.defaults.checked,
        setFunction = function(state) 
            AT.savedVariables.checked = state
			AsylumTimers:SetHidden(state)
        end,
        getFunction = function() 
            return AT.savedVariables.checked
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local toggleDebug = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Debug Messages", 
        tooltip = "Enables Debug messages.\n\nThis will only be useful to me as I test it on console. The final version of this addon won't have debug messages",
        default = AT.defaults.debugMessages,
        setFunction = function(state) 
            AT.savedVariables.debugMessages = state
        end,
        getFunction = function() 
            return AT.savedVariables.debugMessages
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local resetDefaults = {
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			AT.savedVariables.debugMessages = AT.defaults.debugMessages
			
			AT.savedVariables.selectedFontNumber_Timers = AT.defaults.selectedFontNumber_Timers
			AT.savedVariables.selectedFontName_Timers = AT.defaults.selectedFontName_Timers
			AT.savedVariables.selectedPos_Timers = AT.defaults.selectedPos_Timers
			AT.savedVariables.selectedPosName_Timers = AT.defaults.selectedPosName_Timers
			
			AT.savedVariables.checked = AT.defaults.checked
			AT.savedVariables.offset_x = AT.defaults.offset_x
			AT.savedVariables.offset_y = AT.defaults.offset_y
			
			updateFont(selectedFontName_Timers)
			
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(3, GuiRoot, 3, AT.savedVariables.offset_x, AT.savedVariables.offset_y)			
		end,
        disable = function() return areSettingsDisabled end,
    }
	
	local timer_font = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Timer Font Size",
        tooltip = "Change the size of the Timers.",
        setFunction = function(combobox, name, item)
			updateFont(item.data)
			AT.savedVariables.selectedFontNumber_Timers = name
			AT.savedVariables.selectedFontName_Timers = item.data
        end,
        getFunction = function()
            return AT.savedVariables.selectedFontNumber_Timers
        end,
        default = AT.defaults.selectedFontNumber_Timers,
        items = {
            {
                name = "18",
                data = "ZoFontGamepad18"
            },
            {
                name = "20",
                data = "ZoFontGamepad20"
            },
            {
                name = "22",
                data = "ZoFontGamepad22"
            },
            {
                name = "25",
                data = "ZoFontGamepad25"
            },
            {
                name = "34",
                data = "ZoFontGamepad34"
            },
			{
                name = "36",
                data = "ZoFontGamepad36"
            },
            {
                name = "42",
                data = "ZoFontGamepad42"
            },
            {
                name = "54",
                data = "ZoFontGamepad54"
            },
            {
                name = "61",
                data = "ZoFontGamepad61"
            },
        },
        disable = function() return areSettingsDisabled end,
    }
	
	local offset_x = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "X Offset",
        tooltip = "",
        setFunction = function(value)
			AT.savedVariables.offset_x = value
			
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(3, GuiRoot, 3, AT.savedVariables.offset_x, AT.savedVariables.offset_y)
		  end,
        getFunction = function()
            return AT.savedVariables.offset_x
        end,
        default = 0,
        min = 0,
        max = 1800,
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	local offset_y = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Y Offset",
        tooltip = "",
        setFunction = function(value)
			AT.savedVariables.offset_y = value
		
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(3, GuiRoot, 3, AT.savedVariables.offset_x, AT.savedVariables.offset_y)
		 end,
        getFunction = function()
            return AT.savedVariables.offset_y
        end,
        default = 0,
        min = 0,
        max = 1000,
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return areSettingsDisabled end,
    }
	
	settings:AddSettings({generalSection, toggle, toggleDebug, resetDefaults})
	settings:AddSettings({timerSection, timer_font, offset_x, offset_y})
	
	EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_ACTIVATED, AT.onNewZone)
end
	
function AT.OnAddOnLoaded(event, addonName)
	if addonName == AT.name then
		AT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_ADD_ON_LOADED, AT.OnAddOnLoaded)