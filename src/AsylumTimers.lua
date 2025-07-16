AT = { name = "AsylumTimers" }

local function updateFont(font)
	AsylumTimers_LlothisTitle:SetFont(font)
	AsylumTimers_LlothisTimer:SetFont(font)
	AsylumTimers_FelmsTitle:SetFont(font)
	AsylumTimers_FelmsTimer:SetFont(font)
	AsylumTimers_BashTimer:SetFont(font)
	AsylumTimers_KiteTitle:SetFont(font)
	AsylumTimers_KiteTimer:SetFont(font)
	AsylumTimers_JumpTimer:SetFont(font)
	
	AsylumTimers_LlothisTitle:SetHeight(AsylumTimers_LlothisTitle:GetFontHeight())
	AsylumTimers_LlothisTimer:SetHeight(AsylumTimers_LlothisTimer:GetFontHeight())
	AsylumTimers_FelmsTitle:SetHeight(AsylumTimers_FelmsTitle:GetFontHeight())
	AsylumTimers_FelmsTimer:SetHeight(AsylumTimers_FelmsTimer:GetFontHeight())
	AsylumTimers_BashTimer:SetHeight(AsylumTimers_BashTimer:GetFontHeight())
	AsylumTimers_KiteTitle:SetHeight(AsylumTimers_KiteTitle:GetFontHeight())
	AsylumTimers_KiteTimer:SetHeight(AsylumTimers_KiteTimer:GetFontHeight())
	AsylumTimers_JumpTimer:SetHeight(AsylumTimers_JumpTimer:GetFontHeight())
end

local function formatSeconds(seconds)
	return string.format("%d:%02d", math.floor(seconds/60), seconds%60)
end

function AT.updateText()
	--Llothis
	if (AT.time_Llothis <= 0 and AT.isLlothisEnraged == false and AT.hasLlothisSpawned) or AT.isLlothisEnraged then
		AT.isLlothisEnraged = true
		AsylumTimers_LlothisTimer:SetText("ENRAGED")
		AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha)
	elseif AT.time_Llothis > 0 then 
		AsylumTimers_LlothisTimer:SetText(formatSeconds(AT.time_Llothis))
		AT.time_Llothis = AT.time_Llothis - 1 
	end
	
	--Felms
	if (AT.time_Felms <= 0 and AT.isFelmsEnraged == false and AT.hasFelmsSpawned) or AT.isFelmsEnraged then
		AT.isFelmsEnraged = true
		AsylumTimers_FelmsTimer:SetText("ENRAGED")
		AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha)
	elseif AT.time_Felms > 0 then 
		AsylumTimers_FelmsTimer:SetText(formatSeconds(AT.time_Felms))
		AT.time_Felms = AT.time_Felms - 1 
	end
	
	--Kite
	if AT.displayKite == true then
		AsylumTimers_KiteTimer:SetText("KITE")
		AsylumTimers_KiteTimer:SetColor(AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha)
	elseif AT.time_Kite > 0 then
		AT.time_Kite = AT.time_Kite - 1
		AsylumTimers_KiteTimer:SetText(formatSeconds(AT.time_Kite))
		AsylumTimers_KiteTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif DoesUnitExist("boss1") then
		local health, maxHealth, _ = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
		if health/maxHealth <= 0.9 then
			AsylumTimers_KiteTimer:SetText("SOON")
			AsylumTimers_KiteTimer:SetColor(AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha)
		end
	end
	
	--Bash
	if AT.activeBash then
		AsylumTimers_BashTimer:SetText("(BASH)")
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha)
	elseif AT.time_Bash > 0 then 
		AsylumTimers_BashTimer:SetText("("..formatSeconds(AT.time_Bash)..")")
		AT.time_Bash = AT.time_Bash - 1
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasLlothisSpawned then
		AsylumTimers_BashTimer:SetText("(SOON)")
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha)
	end
	
	--Jump (Felms)
	if AT.felmsJumps ~= 0 then
		AsylumTimers_JumpTimer:SetText("(JUMPING)")
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha)
	elseif AT.time_Jump > 0 then
		AsylumTimers_JumpTimer:SetText("("..formatSeconds(AT.time_Jump)..")")
		AT.time_Jump = AT.time_Jump - 1
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasFelmsSpawned then
		AsylumTimers_JumpTimer:SetText("(SOON)")
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha)
	end
end

function AT.onEffect(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID, sourceType)
	if abilityID == 99990 then --Dormant
		if changeType == EFFECT_RESULT_GAINED  then
			
			if string.find(unitName, "Llothis") ~= nil then
				
				AT.time_Llothis = 45
				AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha)
				AT.isLlothisEnraged = false
			elseif string.find(unitName, "Felms") ~= nil then
				
				AT.time_Felms = 45
				AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha)
				AT.isFelmsEnraged = false
			end
		
		elseif changeType == EFFECT_RESULT_FADED then
			
			if string.find(unitName, "Llothis") ~= nil then
				
				AT.time_Llothis = 180
				AsylumTimers_LlothisTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
			elseif string.find(unitName, "Felms") ~= nil then
				
				AT.time_Felms = 180
				AsylumTimers_FelmsTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
			end
			
		end
	elseif abilityID == 101354 and changeType == EFFECT_RESULT_GAINED then --Enrage	
		if string.find(unitName, "Llothis") ~= nil then
			
			AT.isLlothisEnraged = true
		elseif string.find(unitName, "Felms") ~= nil then
			
			AT.isFelmsEnraged = true
		end
	end
end

function AT.onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _log, sourceUnitID, targetUnitID, abilityID, overflow)
	--Player hits miniboss for the first time.
	if AT.hasLlothisSpawned == false and string.find(targetName, "Llothis") ~= nil then
		AT.hasLlothisSpawned = true
		
		if AT.spawnTimes[tostring(targetID)] == nil then
			AT.time_Llothis = 180
		else
			AT.time_Llothis = 180 - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		end
		
		AT.time_Bash = AT.cooldowns.bash - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	elseif AT.hasFelmsSpawned == false and string.find(targetName, "Felms") ~= nil then	
		AT.hasFelmsSpawned = true
		
		if AT.spawnTimes[tostring(targetID)] == nil then
			AT.time_Felms = 180
		else
			AT.time_Felms = 180 - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		end
		AT.time_Jump = AT.cooldowns.jump - (GetGameTimeSeconds() - AT.spawnTimes[tostring(targetID)])
		AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
	end
	
	if abilityID == 10298 then --ad spawns, only lets us use targetID
		if AT.hasFelmsSpawned == false or AT.hasLlothisSpawned == false then
			AT.spawnTimes[tostring(targetID)] = GetGameTimeSeconds()
		end
	elseif abilityID == 95687 or abilityID == 9566 then --Oppressive Bolt Sound
		if AT.savedVariables.bashSound and AT.hasLlothisBashSoundPlayedRecently == false then
			PlaySound(SOUNDS.RAID_TRIAL_FAILED)
			AT.hasLlothisBashSoundPlayedRecently = true
			zo_callLater(function() AT.hasLlothisBashSoundPlayedRecently = false end, 250)
		end
		AT.activeBash = true
	elseif abilityID == 98535 then --Storm the heavens
		if AT.activeKite == false then
			AT.displayKite = true
			AT.activeKite = true
			zo_callLater(function ()
				AT.time_Kite = AT.cooldowns.kite
				AT.displayKite = false
				end, 5000)
			zo_callLater(function ()
				AT.activeKite = false
			end, 10000)
		end
	elseif abilityID == 99138 then --teleport strike
		AT.felmsJumps = AT.felmsJumps + 1
		AT.hasFelmsJumpedRecently = true
		zo_callLater(function() AT.hasFelmsJumpedRecently = false end, 250)
		
		if AT.felmsJumps == 3 then
			AT.felmsJumps = 0
			AT.time_Jump = AT.cooldowns.jump
			AsylumTimers_JumpTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		end
	end
	
	--Llothis Bash
	if result == ACTION_RESULT_INTERRUPT then
		AT.time_Bash = AT.cooldowns.bash
		AsylumTimers_BashTimer:SetColor(AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha)
		
		AT.activeBash = false
		zo_callLater(function()
			AT.activeBash = false 
		end, 2500)
	end
end

function AT.onWipeOrKill(eventCode, inCombat)
	zo_callLater(function ()
		if IsUnitInCombat("player") == false and IsUnitDead("player") == false then
			AsylumTimers_BashTimer:SetText("")
			AsylumTimers_FelmsTimer:SetText("")
			AsylumTimers_JumpTimer:SetText("")
			AsylumTimers_KiteTimer:SetText("")
			AsylumTimers_LlothisTimer:SetText("")
			
			AT.time_Felms = 0
			AT.time_Llothis = 0
			AT.time_Bash = 0
			AT.time_Jump = 0
			AT.time_Kite = 0
			AT.felmsJumps = 0
			AT.activeBash = false
			AT.activeKite = false
			AT.hasLlothisSpawned = false
			AT.hasFelmsSpawned = false
			AT.isLlothisEnraged = false
			AT.isFelmsEnraged = false
			AT.spawnTimes = { }
		end
	end, 2000)
end

function AT.onNewZone(eventCode, initial)
	local zoneID, _, _, _ = GetUnitRawWorldPosition("player")
	
	if zoneID == 1000 then
		AsylumTimers:SetHidden(AT.savedVariables.checked)
		if AT.isRegistered == false then
			AT.isRegistered = true
			
			EVENT_MANAGER:RegisterForUpdate(AT.name, 1000, AT.updateText)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_EFFECT_CHANGED, AT.onEffect)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_ALIVE, AT.onWipeOrKill)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_COMBAT_STATE, AT.onWipeOrKill)
			EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_COMBAT_EVENT, AT.onCombatEvent)
		end
	else
		AsylumTimers:SetHidden(true)
		if AT.isRegistered then 
			AT.isRegistered = false
			
			EVENT_MANAGER:UnregisterForUpdate(AT.name, AT.updateText)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_EFFECT_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_PLAYER_ALIVE)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_PLAYER_COMBAT_STATE)
			EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_COMBAT_EVENT)
		end
	end
end

local function fragmentChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		local zoneID, _, _, _ = GetUnitRawWorldPosition("player")
	
		if zoneID == 1000 then
			AsylumTimers:SetHidden(AT.savedVariables.checked)
		end
	elseif newState == SCENE_FRAGMENT_HIDDEN then
		AsylumTimers:SetHidden(true)
	end
end

function AT.Initialize()
	
	AT.defaults = {
		selectedFontNumber_Timers = "22",
		selectedFontName_Timers = "ZoFontGamepad22",
		
		
		normalColor = {
			red = 1.0,
			green = 1.0,
			blue = 1.0,
			alpha = 1.0,
		},
		mechColor = {
			red = 0.0,
			green = 1.0,
			blue = 1.0,
			alpha = 1.00,
		},
		enragedColor = {
			red = 1.0,
			green = 0.0,
			blue = 0.0,
			alpha = 1.0,
		},
		soonColor = {
			red = 1.0,
			green = 0.0,
			blue = 0.0,
			alpha = 1.0,
		},
		downedColor = {
			red = 0,
			green = 1,
			blue = 0,
			alpha = 1,
		},
		
		checked = false,
		offset_x = 0,
		offset_y = 0,
		
		bashSound = true,
	}
	
	AT.cooldowns = {
		bash = 12,
		kite = 35,
		jump = 20,
	}
	
	AT.isRegistered = false
	AT.time_Llothis = 0
	AT.time_Felms = 0
	AT.time_Bash = 0
	AT.time_Kite = 0
	AT.time_Jump = 0
	AT.felmsJumps = 0
	AT.activeKite = false
	AT.displayKite = false
	AT.activeBash = false
	AT.hasLlothisSpawned = false
	AT.hasFelmsSpawned = false
	AT.isLlothisEnraged = false
	AT.isFelmsEnraged = false
	AT.hasFelmsJumpedRecently = false
	AT.hasLlothisBashSoundPlayedRecently = false
	AT.spawnTimes = { }
	
	
	AT.savedVariables = ZO_SavedVars:NewAccountWide("ATSavedVariables", 1, nil, AT.defaults, GetWorldName())
	updateFont(AT.savedVariables.selectedFontName_Timers)	
	AsylumTimers:ClearAnchors()
	AsylumTimers:SetAnchor(3, GuiRoot, 3, AT.savedVariables.offset_x, AT.savedVariables.offset_y)

	AT.onNewZone(_, _)
	
	HUD_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	
	--settings
	local settings = LibHarvensAddonSettings:AddAddon("Asylum Timers")
	local areSettingsDisabled = false
	
	local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
	local timerSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Timers",}
	local otherSection = {type = LibHarvensAddonSettings.ST_SECTION, label = "OTHER",}
	
	local changeCounter = 0
	
	local toggle = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Disable", 
        tooltip = "Disables the addon's displays.",
        default = AT.defaults.checked,
        setFunction = function(state) 
            AT.savedVariables.checked = state
			AsylumTimers:SetHidden(state)
			
			if state ==  false then
				--Hide UI 5 seconds after most recent change. multiple changes can be queued.
				AsylumTimers:SetHidden(false)
				changeCounter = changeCounter + 1
				local changeNum = changeCounter
				zo_callLater(function()
					if changeNum == changeCounter then
						changeCounter = 0
						if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
							AsylumTimers:SetHidden(true)
						end
					end
				end, 5000)
			end
        end,
        getFunction = function() 
            return AT.savedVariables.checked
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local resetDefaults = {
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			--save
			AT.savedVariables.checked = AT.defaults.checked
		
			AT.savedVariables.selectedFontNumber_Timers = AT.defaults.selectedFontNumber_Timers
			AT.savedVariables.selectedFontName_Timers = AT.defaults.selectedFontName_Timers
			
			AT.savedVariables.normalColor = AT.defaults.normalColor
			AT.savedVariables.mechColor = AT.defaults.mechColor
			AT.savedVariables.enragedColor = AT.defaults.enragedColor
			AT.savedVariables.soonColor = AT.defaults.soonColor
			AT.savedVariables.downedColor = AT.defaults.downedColor
			
			AT.savedVariables.bashSound = AT.defaults.bashSound
			
			AT.savedVariables.selectedPos_Timers = AT.defaults.selectedPos_Timers
			AT.savedVariables.selectedPosName_Timers = AT.defaults.selectedPosName_Timers
			AT.savedVariables.offset_x = AT.defaults.offset_x
			AT.savedVariables.offset_y = AT.defaults.offset_y
			
			--apply
			updateFont(AT.savedVariables.selectedFontName_Timers)
			
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(3, GuiRoot, 3, AT.savedVariables.offset_x, AT.savedVariables.offset_y)			
			
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
			
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
			
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
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
	
	local normalColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Normal Color",
        tooltip = "Change the color of the timer when there are no other mechanics active.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha = ...
        
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
		end,
        default = {AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha},
        getFunction = function()
            return AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local mechColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Mechanic Color",
        tooltip = "Change the color of the timer when there is an active mechanic (e.g. kite, interrupt, jump).",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha = ...
       
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
	    end,
        default = {AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha},
        getFunction = function()
            return AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local enragedColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Enraged Color",
        tooltip = "Change the color of the timer when a miniboss is enraged.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha = ...
			
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
		end,
        default = {AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha},
        getFunction = function()
            return AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local soonColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Soon Color",
        tooltip = "Change the color of the mechanic timer when it is expected at any moment.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha = ...
        
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
		end,
        default = {AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha},
        getFunction = function()
            return AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	local downedColor = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Downed Color",
        tooltip = "Change the color of the timer when a miniboss is respawning.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha = ...
        
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
		end,
        default = {AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha},
        getFunction = function()
            return AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha
        end,
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
		  
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
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
		 
			--Hide UI 5 seconds after most recent change. multiple changes can be queued.
			AsylumTimers:SetHidden(false)
			changeCounter = changeCounter + 1
			local changeNum = changeCounter
			zo_callLater(function()
				if changeNum == changeCounter then
					changeCounter = 0
					if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.checked then
						AsylumTimers:SetHidden(true)
					end
				end
			end, 5000)
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
	
	local toggleBashSound = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Bash Sound", 
        tooltip = "Plays a sound during Llothis' interrupt mechanic",
        default = AT.defaults.bashSound,
        setFunction = function(state) 
            AT.savedVariables.bashSound = state
        end,
        getFunction = function() 
            return AT.savedVariables.bashSound
        end,
        disable = function() return areSettingsDisabled end,
    }
	
	settings:AddSettings({generalSection, toggle, resetDefaults})
	settings:AddSettings({timerSection, timer_font, normalColor, mechColor, enragedColor, soonColor, downedColor, offset_x, offset_y})
	settings:AddSettings({otherSection, toggleBashSound})
	
	EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_PLAYER_ACTIVATED, AT.onNewZone)
end
	
function AT.OnAddOnLoaded(event, addonName)
	if addonName == AT.name then
		AT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_ADD_ON_LOADED, AT.OnAddOnLoaded)