local framework = Config.framework or 'standalone'

local function DebugPrint(message)
    if Config.debug then
        print("[DEBUG - SERVER]: " .. message)
    end
end

local function GetResourceVersion()
    local file = LoadResourceFile(GetCurrentResourceName(), "fxmanifest.lua")
    local version = "Please Check Your fxmanifest For Version Of This Script"

    if file then
        local versionPattern = "version%s*'%d+%.%d+%.%d+'"
        local versionMatch = file:match(versionPattern)
        if versionMatch then
            version = versionMatch:match("'%d+%.%d+%.%d+'"):gsub("'", "")
        end
    end

    return version
end

local version = GetResourceVersion()
print("[INFO - SERVER]: Script created by [MrJujuri] | GitHub: https://github.com/MrJujuri | Version: " .. version)

if framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
    DebugPrint("Using QBCore framework.")
elseif framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
    DebugPrint("Using ESX framework.")
else
    DebugPrint("Framework not recognized. Defaulting to standalone.")
end

if framework == 'qb-core' then
    QBCore.Functions.CreateUseableItem("megaphone", function(source)
        DebugPrint("Player " .. source .. " used the megaphone item.")
        TriggerClientEvent("megaphone:use", source)
    end)
elseif framework == 'esx' then
    ESX.RegisterUsableItem('megaphone', function(source)
        DebugPrint("Player " .. source .. " used the megaphone item.")
        TriggerClientEvent("megaphone:use", source)
    end)
else
    DebugPrint("Standalone framework detected.")
    RegisterCommand("megaphone", function(source)
        TriggerClientEvent("megaphone:use", source)
    end)
end

RegisterNetEvent('megaphone:applySubmix', function(bool)
    DebugPrint("Submix state change: " .. (bool and "enabled" or "disabled"))
    TriggerClientEvent('megaphone:updateSubmixStatus', -1, bool, source)
end)