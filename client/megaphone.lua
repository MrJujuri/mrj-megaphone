local function DebugPrint(message)
    if Config.debug then
        print("[DEBUG]: " .. message)
    end
end

local function IsVehicleAllowed()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleClass = GetVehicleClass(vehicle)
        DebugPrint("Player vehicle class: " .. tostring(vehicleClass))
        for _, class in ipairs(Config.vehicleClasses) do
            if vehicleClass == class then
                DebugPrint("Vehicle class allowed for megaphone.")
                return true
            end
        end
        DebugPrint("Vehicle class not allowed for megaphone.")
        return false
    end
    DebugPrint("Player not in a vehicle.")
    return true
end

local function DisableSubmix()
    DebugPrint("Disabling submix...")
    if IsEntityPlayingAnim(PlayerPedId(), "molly@megaphone", "megaphone_clip", 3) then
        ExecuteCommand('e c')
        DebugPrint("Stopped animation: megaphone_clip.")
    end
    TriggerServerEvent('megaphone:applySubmix', false)
    DebugPrint("Server event 'megaphone:applySubmix' triggered with state: false.")
end 

local usingMegaphone = false

function UseMegaphone()
    DebugPrint("UseMegaphone function called.")

    if IsPedInAnyVehicle(PlayerPedId(), false) and not IsVehicleAllowed() then
        lib.notify({
            title = "Megaphone",
            description = "You cannot use the megaphone in this type of vehicle.",
            type = "error"
        })
        return
    end

    if usingMegaphone then 
        DebugPrint("Megaphone is currently active. Disabling...")
        DisableSubmix()
    end

    usingMegaphone = not usingMegaphone
    DebugPrint("Megaphone state toggled. New state: " .. tostring(usingMegaphone))

    CreateThread(function()
        if usingMegaphone then
            DebugPrint("Enabling megaphone effect.")
            TriggerServerEvent('megaphone:applySubmix', true)
            DebugPrint("Server event 'megaphone:applySubmix' triggered with state: true.")
        end

        while usingMegaphone do
            if not IsEntityPlayingAnim(PlayerPedId(), "molly@megaphone", "megaphone_clip", 3) then
                ExecuteCommand('e megaphone')
                DebugPrint("Animation 'megaphone_clip' started.")
            end
            Wait(100)
        end
    end)
end

exports('UseMegaphone', UseMegaphone)

RegisterNetEvent('megaphone:use')
AddEventHandler('megaphone:use', function()
    DebugPrint("Event 'megaphone:use' triggered.")
    UseMegaphone()
end)

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

local filter

CreateThread(function()
    DebugPrint("Initializing audio submix...")
    filter = CreateAudioSubmix("Megaphone")
    SetAudioSubmixEffectRadioFx(filter, 0)
    DebugPrint("Audio submix 'Megaphone' created.")

    for hash, value in pairs(data) do
        SetAudioSubmixEffectParamInt(filter, 0, hash, 1)
        DebugPrint("Audio submix parameter set: " .. tostring(hash) .. " = " .. tostring(value))
    end

    AddAudioSubmixOutput(filter, 0)
    DebugPrint("Audio submix output added.")
end)

RegisterNetEvent('megaphone:updateSubmixStatus', function(state, source)
    DebugPrint("Event 'megaphone:updateSubmixStatus' triggered with state: " .. tostring(state) .. ", source: " .. tostring(source))

    if state then
        if Config.ForceVolume then
            MumbleSetVolumeOverrideByServerId(source, 0.90)
            DebugPrint("Volume override set for source " .. tostring(source) .. " to 0.90.")
        end
        MumbleSetSubmixForServerId(source, filter)
        DebugPrint("Submix set for source " .. tostring(source) .. ".")
        exports['pma-voice']:overrideProximityRange(Config.ForcedProximity, false)
        DebugPrint("Proximity range overridden.")
    else
        MumbleSetSubmixForServerId(source, -1)
        if Config.ForceVolume then
            MumbleSetVolumeOverrideByServerId(source, -1.0)
            DebugPrint("Volume override reset for source " .. tostring(source) .. ".")
        end
        exports['pma-voice']:clearProximityOverride()
        DebugPrint("Proximity override cleared.")
        MumbleClearVoiceTargetPlayers(1.0)
        DebugPrint("Voice target players cleared.")
    end
end)
