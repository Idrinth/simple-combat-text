SimpleCombatText = {Settings = {}}

local data = {
    Incoming = {
        Heal=0,
        Damage=0,
    },
    Outgoing = {
        Heal=0,
        Damage=0,
    }
}
local previous = {{
    Incoming = {
        Heal=0,
        Damage=0,
    },
    Outgoing = {
        Heal=0,
        Damage=0,
    }
},{
    Incoming = {
        Heal=0,
        Damage=0,
    },
    Outgoing = {
        Heal=0,
        Damage=0,
    }
},{
    Incoming = {
        Heal=0,
        Damage=0,
    },
    Outgoing = {
        Heal=0,
        Damage=0,
    }
}}
local time=0;

local function log(message)
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, towstring(message))
end
local function slash(input)
    local command = input:match("^([a-z.:]+)")
    if command == "frequency" or command == "f" then
        local updateInterval = input:match("([0-9.]+)$")
        if updateInterval then
            updateInterval = tonumber(updateInterval)
            if updateInterval < 0.1 or updateInterval > 3 then
                log("Update Interval needs to be between 0.1 and 3 seconds.")
            else
                SimpleCombatText.Settings.updateInterval = updateInterval
                log("Update Interval set to "..tostring(updateInterval))
            end
        end
    elseif command == "moving" or command == "m" then
        SimpleCombatText.Settings.moving = not SimpleCombatText.Settings.moving
        log("Moving set to "..tostring(SimpleCombatText.Settings.moving))
    elseif command == "color" or command == "c" then
        local direction,r,g,b = input:match("([a-z:]+) ([0-9]+) ([0-9]+) ([0-9]+)$")
        if direction then
            r = tonumber(r)
            g = tonumber(g)
            b = tonumber(b)
            if r > 255 or g > 255 or b > 255 then
                log("RGB can have each color at 255 maximum")
                return
            end
            if direction == "outgoing:heal" or direction == "o:h" then
                SimpleCombatText.Settings.outgoingHealColor = {r=r,g=g,b=b}
                log("Outgoing Heal set to ("..tostring(r)..","..tostring(g)..","..tostring(b)..")")
                LabelSetTextColor("SimpleCombatTextOutgoingHeal", SimpleCombatText.Settings.outgoingHealColor.r, SimpleCombatText.Settings.outgoingHealColor.g, SimpleCombatText.Settings.outgoingHealColor.b)
            elseif direction == "outgoing:damage" or direction == "o:d" then
                SimpleCombatText.Settings.outgoingDamageColor = {r=r,g=g,b=b}
                log("Outgoing Damage set to ("..tostring(r)..","..tostring(g)..","..tostring(b)..")")
                LabelSetTextColor("SimpleCombatTextOutgoingDamage", SimpleCombatText.Settings.outgoingDamageColor.r, SimpleCombatText.Settings.outgoingDamageColor.g, SimpleCombatText.Settings.outgoingDamageColor.b)
            elseif direction == "incoming:damage" or direction == "i:d" then
                SimpleCombatText.Settings.incomingDamageColor = {r=r,g=g,b=b}
                log("Incoming Damage set to ("..tostring(r)..","..tostring(g)..","..tostring(b)..")")
                LabelSetTextColor("SimpleCombatTextIncomingDamage", SimpleCombatText.Settings.incomingDamageColor.r, SimpleCombatText.Settings.incomingDamageColor.g, SimpleCombatText.Settings.incomingDamageColor.b)
            elseif direction == "incoming:heal" or direction == "i:h" then
                SimpleCombatText.Settings.incomingHealColor = {r=r,g=g,b=b}
                log("Incoming Heal set to ("..tostring(r)..","..tostring(g)..","..tostring(b)..")")
                LabelSetTextColor("SimpleCombatTextIncomingHeal", SimpleCombatText.Settings.incomingHealColor.r, SimpleCombatText.Settings.incomingHealColor.g, SimpleCombatText.Settings.incomingHealColor.b)
            else
                log("Target not recognised, please use outgoing:heal or incoming:damage")
            end
        else
            log("Please provide target and rgb values: /sct color outgoing:heal 0 255 0")
        end
    elseif command == "toggle" or command == "t" then
        local direction = input:match("([a-z:]+)$")
        if direction then
            if direction == "outgoing:heal" or direction == "o:h" then
                SimpleCombatText.Settings.outgoingHealEnabled = not SimpleCombatText.Settings.outgoingHealEnabled
                log("Outgoing Heal enabled? "..tostring(SimpleCombatText.Settings.outgoingHealEnabled))
            elseif direction == "outgoing:damage" or direction == "o:d" then
                SimpleCombatText.Settings.outgoingDamageEnabled = not SimpleCombatText.Settings.outgoingDamageEnabled
                log("Outgoing Damage enabled? "..tostring(SimpleCombatText.Settings.outgoingDamageEnabled))
            elseif direction == "incoming:damage" or direction == "i:d" then
                SimpleCombatText.Settings.incomingDamageEnabled = not SimpleCombatText.Settings.incomingDamageEnabled
                log("Incoming Damage enabled? "..tostring(SimpleCombatText.Settings.incomingDamageEnabled))
            elseif direction == "incoming:heal" or direction == "i:h" then
                SimpleCombatText.Settings.incomingHealEnabled = not SimpleCombatText.Settings.incomingHealEnabled
                log("Incoming Heal enabled? "..tostring(SimpleCombatText.Settings.incomingHealEnabled))
            else
                log("Target not recognised, please use outgoing:heal or incoming:damage")
            end
        else
            log("Please provide target: /sct toggle outgoing:heal")
        end
    elseif command == "lowerlimit:hit" or command == "lh" then
        local amount = input:match("([1-9][0-9]*)$")
        if amount then
            SimpleCombatText.Settings.lowerLimitHit = tonumber(amount)
            log("Minimum Amount per Hit "..amount)
        else
            log("Please provide an amount: /sct lowerlimit:hit 1")
        end
    elseif command == "lowerlimit:aggregated" or command == "la" then
        local amount = input:match("([1-9][0-9]*)$")
        if amount then
            SimpleCombatText.Settings.lowerLimitAggregated = tonumber(amount)
            log("Minimum Amount per Aggregate "..amount)
        else
            log("Please provide an amount: /sct lowerlimit:hit 1")
        end
    end
end
function SimpleCombatText.OnInitialize()
    local colors = {
        green={r=0,g=255,b=0},
        red={r=255,g=0,b=0},
    }
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "SimpleCombatText.AddCombatEventText")
    if LibSlash ~= nil and LibSlash.RegisterSlashCmd ~= nil then --optional dependency
        LibSlash.RegisterSlashCmd("sct", slash)
        LibSlash.RegisterSlashCmd("simplecombattext", slash)
    end
    if SimpleCombatText.Settings == nil then
        SimpleCombatText.Settings = {}
    end
    if SimpleCombatText.Settings.updateInterval == nil then
        SimpleCombatText.Settings.updateInterval = 0.5
    end
    if SimpleCombatText.Settings.outgoingDamageColor == nil then
        SimpleCombatText.Settings.outgoingDamageColor = colors.red
    end
    if SimpleCombatText.Settings.incomingDamageColor == nil then
        SimpleCombatText.Settings.incomingDamageColor = colors.red
    end
    if SimpleCombatText.Settings.outgoingHealColor == nil then
        SimpleCombatText.Settings.outgoingHealColor = colors.green
    end
    if SimpleCombatText.Settings.incomingHealColor == nil then
        SimpleCombatText.Settings.incomingHealColor = colors.green
    end
    if SimpleCombatText.Settings.incomingHealEnabled == nil then
        SimpleCombatText.Settings.incomingHealEnabled = true
    end
    if SimpleCombatText.Settings.incomingDamageEnabled == nil then
        SimpleCombatText.Settings.incomingDamageEnabled = true
    end
    if SimpleCombatText.Settings.outgoingHealEnabled == nil then
        SimpleCombatText.Settings.outgoingHealEnabled = true
    end
    if SimpleCombatText.Settings.outgoingDamageEnabled == nil then
        SimpleCombatText.Settings.outgoingDamageEnabled = true
    end
    if SimpleCombatText.Settings.lowerLimitHit == nil then
        SimpleCombatText.Settings.lowerLimitHit = 1
    end
    if SimpleCombatText.Settings.lowerLimitAggregated == nil then
        SimpleCombatText.Settings.lowerLimitAggregated = 1
    end
    if SimpleCombatText.Settings.moving == nil then
        SimpleCombatText.Settings.moving = false
    end
    for label,value in pairs(data) do
        CreateWindow("SimpleCombatText"..label, true)
        WindowSetScale("SimpleCombatText"..label, 2)
        for i=1,3 do
            LabelSetFont("SimpleCombatText"..label.."Heal"..i, ChatSettings.Fonts[4].fontName, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING) -- Age of Reckoning Large
            LabelSetFont("SimpleCombatText"..label.."Damage"..i, ChatSettings.Fonts[4].fontName, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING) -- Age of Reckoning Large
            LabelSetTextColor("SimpleCombatText"..label.."Heal"..i, SimpleCombatText.Settings.outgoingHealColor.r, SimpleCombatText.Settings.outgoingHealColor.g, SimpleCombatText.Settings.outgoingHealColor.b)
            LabelSetTextColor("SimpleCombatText"..label.."Damage"..i, SimpleCombatText.Settings.outgoingDamageColor.r, SimpleCombatText.Settings.outgoingDamageColor.g, SimpleCombatText.Settings.outgoingDamageColor.b)
        end
        LayoutEditor.RegisterWindow("SimpleCombatText"..label, towstring("SimpleCombatText"..label),L"", true, true, true, nil, nil, false, 1, nil, nil )
    end
end
function SimpleCombatText.AddCombatEventText( hitTargetObjectNumber, hitAmount, textType )
    if GameData.Player.worldObjNum == hitTargetObjectNumber then
        if textType == GameData.CombatEvent.HIT or textType == GameData.CombatEvent.ABILITY_HIT or textType == GameData.CombatEvent.CRITICAL or textType == GameData.CombatEvent.ABILITY_CRITICAL then
            if hitAmount < 0 then
                if SimpleCombatText.Settings.incomingDamageEnabled and hitAmount <= -1 * SimpleCombatText.Settings.lowerLimitHit then
                    data.Incoming.Damage = data.Incoming.Damage - hitAmount
                end
            elseif SimpleCombatText.Settings.incomingHealEnabled and hitAmount >= SimpleCombatText.Settings.lowerLimitHit then
                data.Incoming.Heal = data.Incoming.Heal + hitAmount
            end
        end
    elseif textType == GameData.CombatEvent.HIT or textType == GameData.CombatEvent.ABILITY_HIT or textType == GameData.CombatEvent.CRITICAL or textType == GameData.CombatEvent.ABILITY_CRITICAL then
        if hitAmount < 0 then
            if SimpleCombatText.Settings.outgoingDamageEnabled and hitAmount <= -1 * SimpleCombatText.Settings.lowerLimitHit then
                data.Outgoing.Damage = data.Outgoing.Damage - hitAmount
            end
        elseif SimpleCombatText.Settings.outgoingHealEnabled and hitAmount >= SimpleCombatText.Settings.lowerLimitHit then
            data.Outgoing.Heal = data.Outgoing.Heal + hitAmount
        end
    end
end
function SimpleCombatText.OnUpdate(elapsed)
    time = time + elapsed
    if time >= SimpleCombatText.Settings.updateInterval then
        time = time - SimpleCombatText.Settings.updateInterval
        for label,value in pairs(data) do
            for modifier,amount in pairs(value) do
                previous[3][label][modifier] = previous[2][label][modifier]
                previous[2][label][modifier] = previous[1][label][modifier]
                previous[1][label][modifier] = data[label][modifier]
                data[label][modifier] = 0
            end
        end
        for pos,set in pairs(previous) do
            for label,value in pairs(set) do
                for modifier,amount in pairs(value) do
                    if amount >= SimpleCombatText.Settings.lowerLimitAggregated then
                        WindowSetShowing("SimpleCombatText"..label..modifier..pos, true);
                        LabelSetText("SimpleCombatText"..label..modifier..pos, towstring(amount))
                        WindowStartAlphaAnimation("SimpleCombatText"..label..modifier..pos, Window.AnimationType.EASE_OUT, math.max(1.33-pos*0.33, 0.33), math.max(1-pos*0.33, 0), SimpleCombatText.Settings.updateInterval, true, 0, 0)
                    else
                        WindowSetShowing("SimpleCombatText"..label..modifier..pos, false);
                    end
                end
            end
        end
    end
    if SimpleCombatText.Settings.moving then
        WindowClearAnchors("SimpleCombatTextIncomingHeal")
        WindowAddAnchor("SimpleCombatTextIncomingHeal", "topleft", "SimpleCombatTextIncoming", "topleft", 0, 20 - 20/SimpleCombatText.Settings.updateInterval*time)
        WindowClearAnchors("SimpleCombatTextOutgoingHeal")
        WindowAddAnchor("SimpleCombatTextOutgoingHeal", "topleft", "SimpleCombatTextOutgoing", "topleft", 0, 20 - 20/SimpleCombatText.Settings.updateInterval*time)
        WindowClearAnchors("SimpleCombatTextIncomingDamage")
        WindowAddAnchor("SimpleCombatTextIncomingDamage", "bottomleft", "SimpleCombatTextIncoming", "bottomleft", 0, 20/SimpleCombatText.Settings.updateInterval*time)
        WindowClearAnchors("SimpleCombatTextOutgoingDamage")
        WindowAddAnchor("SimpleCombatTextOutgoingDamage", "bottomleft", "SimpleCombatTextOutgoing", "bottomleft", 0, 20/SimpleCombatText.Settings.updateInterval*time)
    else
        WindowSetShowing("SimpleCombatTextOutgoingDamage2", false)
        WindowSetShowing("SimpleCombatTextOutgoingDamage3", false)
        WindowSetShowing("SimpleCombatTextIncomingDamage2", false)
        WindowSetShowing("SimpleCombatTextIncomingDamage3", false)
        WindowSetShowing("SimpleCombatTextOutgoingHeal2", false)
        WindowSetShowing("SimpleCombatTextOutgoingHeal3", false)
        WindowSetShowing("SimpleCombatTextIncomingHeal2", false)
        WindowSetShowing("SimpleCombatTextIncomingHeal3", false)
        WindowClearAnchors("SimpleCombatTextIncomingHeal")
        WindowAddAnchor("SimpleCombatTextIncomingHeal", "topleft", "SimpleCombatTextIncoming", "topleft", 0, 0)
        WindowClearAnchors("SimpleCombatTextOutgoingHeal")
        WindowAddAnchor("SimpleCombatTextOutgoingHeal", "topleft", "SimpleCombatTextOutgoing", "topleft", 0, 0)
        WindowClearAnchors("SimpleCombatTextIncomingDamage")
        WindowAddAnchor("SimpleCombatTextIncomingDamage", "bottomleft", "SimpleCombatTextIncoming", "bottomleft", 0, 0)
        WindowClearAnchors("SimpleCombatTextOutgoingDamage")
        WindowAddAnchor("SimpleCombatTextOutgoingDamage", "bottomleft", "SimpleCombatTextOutgoing", "bottomleft", 0, 0)
    end
end