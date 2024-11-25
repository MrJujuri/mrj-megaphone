local QBCore, ESX
local usingMegaphone = false
local filter

local function DebugPrint(message)
    if Config.debug then
        print("[DEBUG]: " .. message)
    end
end

if Config.framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
    DebugPrint("Using QBCore framework.")
elseif Config.framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
    DebugPrint("Using ESX framework.")
else
    DebugPrint("Framework not recognized. Defaulting to standalone.")
end

local function DisableSubmix()
    if IsEntityPlayingAnim(PlayerPedId(), "molly@megaphone", "megaphone_clip", 3) then
        ExecuteCommand('e c')
    end
    TriggerServerEvent('megaphone:applySubmix', false)
end

local function HasMegaphoneItem()
    local hasItem = false
    if Config.framework == 'qb-core' then
        hasItem = QBCore.Functions.HasItem(Config.megaphoneItem)
    elseif Config.framework == 'esx' then
        ESX.TriggerServerCallback('esx:getPlayerData', function(playerData)
            hasItem = playerData.items and playerData.items[Config.megaphoneItem]
        end)
    else
        DebugPrint("Using megaphone in standalone mode.")
        hasItem = true
    end
    return hasItem
end

local function UseMegaphone()
    local playerPed = PlayerPedId()
    DebugPrint("UseMegaphone function triggered.")

    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        DebugPrint("Player is in a vehicle.")
        
        local vehicleClass = GetVehicleClass(vehicle)
        DebugPrint("Vehicle Class: " .. vehicleClass)

        local isClassAllowed = false
        for _, class in ipairs(Config.vehicleClasses) do
            if class == vehicleClass then
                isClassAllowed = true
                break
            end
        end

        if not isClassAllowed then
            lib.notify({
                title = "Megaphone",
                description = "This vehicle class cannot use the megaphone.",
                type = "error"
            })
            return
        end

        if not HasMegaphoneItem() then
            lib.notify({
                title = "Megaphone",
                description = "You need to have a megaphone to use this feature.",
                type = "error"
            })
            return
        end

        if usingMegaphone then
            DisableSubmix()
        else
            TriggerServerEvent('megaphone:applySubmix', true)
        end
        usingMegaphone = not usingMegaphone

        CreateThread(function()
            while usingMegaphone do
                if not IsEntityPlayingAnim(playerPed, "molly@megaphone", "megaphone_clip", 3) then
                    ExecuteCommand('e megaphone')
                end
                Wait(100)
            end
        end)

    else
        if not HasMegaphoneItem() then
            lib.notify({
                title = "Megaphone",
                description = "You need to have a megaphone to use this feature.",
                type = "error"
            })
            return
        end

        if usingMegaphone then 
            DisableSubmix()
        end
        usingMegaphone = not usingMegaphone

        CreateThread(function()
            while usingMegaphone do
                if not IsEntityPlayingAnim(playerPed, "molly@megaphone", "megaphone_clip", 3) then
                    ExecuteCommand('e megaphone')
                end
                Wait(100)
            end
        end)
    end
end

exports('UseMegaphone', UseMegaphone)

RegisterNetEvent('megaphone:use', function()
    DebugPrint("Megaphone event triggered.")
    UseMegaphone()
end)

RegisterKeyMapping('useMegaphone', 'Use Megaphone', 'keyboard', 'E')

if Config.debug then
    RegisterCommand('useMegaphone', function()
        DebugPrint("Keybind triggered.")
        UseMegaphone()
    end, false)
end


local data = {
    [`default`] = 1,
    [`freq_low`] = 300.0,
    [`freq_hi`] = 5000.0,
    [`rm_mod_freq`] = 0.0,
    [`rm_mix`] = 0.2,
    [`fudge`] = 0.0,
    [`o_freq_lo`] = 550.0,
    [`o_freq_hi`] = 0.0,
}

CreateThread(function()
    filter = CreateAudioSubmix("Megaphone")
    SetAudioSubmixEffectRadioFx(filter, 0)
    for hash, value in pairs(data) do
        SetAudioSubmixEffectParamInt(filter, 0, hash, 1)
    end
    AddAudioSubmixOutput(filter, 0)
end)

RegisterNetEvent('megaphone:updateSubmixStatus', function(state, source)
    DebugPrint("Submix update: " .. (state and "enabled" or "disabled"))
    if state then
        if Config.ForceVolume then
            MumbleSetVolumeOverrideByServerId(source, 0.90)
        end
        MumbleSetSubmixForServerId(source, filter)
        exports['pma-voice']:overrideProximityRange(Config.ForcedProximity, false)
    else
        MumbleSetSubmixForServerId(source, -1)
        if Config.ForceVolume then
            MumbleSetVolumeOverrideByServerId(source, -1.0)
        end
        exports['pma-voice']:clearProximityOverride()
        MumbleClearVoiceTargetPlayers(1.0)
    end
end)
