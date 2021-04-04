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
local time=0;

local function log(message)
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, towstring(message))
end
local function slash(input)
    local command = input:match("^([a-z.]+)")
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
    end
end
function SimpleCombatText.OnInitialize()
    local colors = {
        green={r=0,g=255,b=0},
        red={r=255,g=0,b=0},
    }
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "SimpleCombatText.AddCombatEventText")
    for label,value in pairs(data) do
        CreateWindow("SimpleCombatText"..label, true)
        WindowSetScale("SimpleCombatText"..label, 2)
        LabelSetTextColor("SimpleCombatText"..label.."Heal", colors.green.r, colors.green.g, colors.green.b)
        LabelSetTextColor("SimpleCombatText"..label.."Damage", colors.red.r, colors.red.g, colors.red.b)
        LabelSetFont("SimpleCombatText"..label.."Heal", ChatSettings.Fonts[4].fontName, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING) -- Age of Reckoning Large
        LabelSetFont("SimpleCombatText"..label.."Damage", ChatSettings.Fonts[4].fontName, WindowUtils.FONT_DEFAULT_TEXT_LINESPACING) -- Age of Reckoning Large
        LayoutEditor.RegisterWindow("SimpleCombatText"..label, towstring("SimpleCombatText"..label),L"", true, true, true, nil, nil, false, 1, nil, nil )
    end
    if LibSlash ~= nil and LibSlash.RegisterSlashCmd ~= nil then --optional dependency
        LibSlash.RegisterSlashCmd("sct", slash)
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
    LabelSetTextColor("SimpleCombatTextOutgoingHeal", SimpleCombatText.Settings.outgoingHealColor.r, SimpleCombatText.Settings.outgoingHealColor.g, SimpleCombatText.Settings.outgoingHealColor.b)
    LabelSetTextColor("SimpleCombatTextOutgoingDamage", SimpleCombatText.Settings.outgoingDamageColor.r, SimpleCombatText.Settings.outgoingDamageColor.g, SimpleCombatText.Settings.outgoingDamageColor.b)
    LabelSetTextColor("SimpleCombatTextIncomingHeal", SimpleCombatText.Settings.incomingHealColor.r, SimpleCombatText.Settings.incomingHealColor.g, SimpleCombatText.Settings.incomingHealColor.b)
    LabelSetTextColor("SimpleCombatTextIncomingDamage", SimpleCombatText.Settings.incomingDamageColor.r, SimpleCombatText.Settings.incomingDamageColor.g, SimpleCombatText.Settings.incomingDamageColor.b)
end
function SimpleCombatText.AddCombatEventText( hitTargetObjectNumber, hitAmount, textType )
    if GameData.Player.worldObjNum == hitTargetObjectNumber then
        if textType == GameData.CombatEvent.HIT or textType == GameData.CombatEvent.ABILITY_HIT or textType == GameData.CombatEvent.CRITICAL or textType == GameData.CombatEvent.ABILITY_CRITICAL then
            if hitAmount < 0 then
                data.Incoming.Damage = data.Incoming.Damage - hitAmount
            else
                data.Incoming.Heal = data.Incoming.Heal + hitAmount
            end
        end
    elseif textType == GameData.CombatEvent.HIT or textType == GameData.CombatEvent.ABILITY_HIT or textType == GameData.CombatEvent.CRITICAL or textType == GameData.CombatEvent.ABILITY_CRITICAL then
        if hitAmount < 0 then
            data.Outgoing.Damage = data.Outgoing.Damage - hitAmount
        else
            data.Outgoing.Heal = data.Outgoing.Heal + hitAmount
        end
    end
end
function SimpleCombatText.OnUpdate(elapsed)
    time = time + elapsed
    if time < SimpleCombatText.Settings.updateInterval then
        return
    end
    time = time - SimpleCombatText.Settings.updateInterval;
    for label,value in pairs(data) do
        for modifier,amount in pairs(value) do
            if amount > 0 then
                WindowSetShowing("SimpleCombatText"..label..modifier, true);
                data[label][modifier] = 0
                LabelSetText("SimpleCombatText"..label..modifier, towstring(amount))
                WindowStartAlphaAnimation("SimpleCombatText"..label..modifier, Window.AnimationType.EASE_OUT, 1, 0, SimpleCombatText.Settings.updateInterval, true, 0, 0)
            else
                WindowSetShowing("SimpleCombatText"..label..modifier, false);
            end
        end
    end
end