-- Multi-framework bridge (ESX / QB / Standalone)
--
-- This resource was originally written for ESX; this wrapper keeps the logic intact
-- while swapping player/inventory calls depending on the selected framework.

local Framework = {
    name = 'standalone',
    core = nil,
    inventory = 'none', -- 'framework' | 'ox' | 'none'
    ox = nil,
    ready = false,
}

local function isStarted(resName)
    local state = GetResourceState(resName)
    return state == 'started' or state == 'starting'
end

local function detectFramework()
    local fw = (Config and Config.Framework) or 'auto'
    fw = string.lower(fw)
    if fw == 'auto' then
        if isStarted('es_extended') then
            fw = 'esx'
        elseif isStarted('qb-core') then
            fw = 'qb'
        else
            fw = 'standalone'
        end
    end
    return fw
end

local function initFramework()
    Framework.name = detectFramework()

    if Framework.name == 'esx' then
        local tries = 200
        while not isStarted('es_extended') and tries > 0 do
            Citizen.Wait(250)
            tries = tries - 1
        end
        if not isStarted('es_extended') then
            log('ERROR: Config.Framework is ESX, but es_extended is not started!')
        else
            Framework.core = exports['es_extended']:getSharedObject()
        end
    elseif Framework.name == 'qb' then
        local tries = 200
        while not isStarted('qb-core') and tries > 0 do
            Citizen.Wait(250)
            tries = tries - 1
        end
        if not isStarted('qb-core') then
            log('ERROR: Config.Framework is QB, but qb-core is not started!')
        else
            local ok, obj = pcall(function()
                return exports['qb-core']:GetCoreObject({'Functions', 'Shared'})
            end)
            if ok and obj then
                Framework.core = obj
            else
                Framework.core = exports['qb-core']:GetCoreObject()
            end
        end
    end

    local inv = (Config and Config.Inventory) or 'auto'
    inv = string.lower(inv)

    -- Default inventory selection
    if inv == 'auto' then
        if Framework.name == 'standalone' then
            inv = isStarted('ox_inventory') and 'ox' or 'none'
        else
            inv = 'framework'
        end
    end

    if inv == 'ox' and isStarted('ox_inventory') then
        Framework.inventory = 'ox'
        Framework.ox = exports.ox_inventory
    elseif inv == 'framework' then
        Framework.inventory = 'framework'
    else
        Framework.inventory = 'none'
    end

    Framework.ready = true
    log('Framework:', Framework.name, '| Inventory:', Framework.inventory)
end

-- GetConvar returns strings; normalise to a boolean.
-- FXServer has used both `onesync_enabled` and `onesync` across versions/config styles.
local oneSyncEnabled = (
    GetConvar('onesync_enabled', 'false') == 'true'
    or GetConvar('onesync', 'off') ~= 'off'
)
local VERBOSE = false
local lastPlant = {}
local tickTimes = {}
local tickPlantCount = 0
local VERSION = '1.2.0-mosh'

AddEventHandler('playerDropped',function(why)
    lastPlant[source] = nil
end)

function log (...)
    local numElements = select('#',...)
    local elements = {...}
    local line = ''
    local prefix = '['..os.date("%H:%M:%S")..'] '
    suffix = '\n'
    local resourceName = '<'..GetCurrentResourceName()..'>'

    for i=1,numElements do
        local entry = elements[i]
        line = line..' '..tostring(entry)
    end
    Citizen.Trace(prefix..resourceName..line..suffix)
end

function verbose(...)
    if VERBOSE then
        log(...)
    end
end

if not oneSyncEnabled then
    log('OneSync not available: Will have to trust client for locations!')
end

function HasItem(who, what, count)
    count = count or 1
    if not what then return true end
    if Framework.inventory == 'ox' and Framework.ox then
        return (Framework.ox:Search(who, 'count', what) or 0) >= count
    end
    if Framework.inventory ~= 'framework' then
        return true
    end
    if Framework.name == 'esx' and Framework.core then
        local xPlayer = Framework.core.GetPlayerFromId(who)
        if not xPlayer then return false end
        local itemspec = xPlayer.getInventoryItem(what)
        return (itemspec and itemspec.count or 0) >= count
    end
    if Framework.name == 'qb' and Framework.core then
        local Player = Framework.core.Functions.GetPlayer(who)
        if not Player then return false end
        local item = Player.Functions.GetItemByName(what)
        local amount = item and (item.amount or item.count or 0) or 0
        return amount >= count
    end
    return false
end

function TakeItem(who, what, count)
    count = count or 1
    if not what then return true end
    if Framework.inventory == 'ox' and Framework.ox then
        local success = Framework.ox:RemoveItem(who, what, count)
        return success == true
    end
    if Framework.inventory ~= 'framework' then
        return true
    end
    if Framework.name == 'esx' and Framework.core then
        local xPlayer = Framework.core.GetPlayerFromId(who)
        if not xPlayer then return false end
        local itemspec = xPlayer.getInventoryItem(what)
        if itemspec and itemspec.count >= count then
            xPlayer.removeInventoryItem(what, count)
            return true
        end
        return false
    end
    if Framework.name == 'qb' and Framework.core then
        local Player = Framework.core.Functions.GetPlayer(who)
        if not Player then return false end
        local item = Player.Functions.GetItemByName(what)
        local amount = item and (item.amount or item.count or 0) or 0
        if amount >= count then
            return Player.Functions.RemoveItem(what, count) == true
        end
        return false
    end
    return false
end

function GiveItem(who, what, count)
    count = count or 1
    if not what then return true end
    if Framework.inventory == 'ox' and Framework.ox then
        if Framework.ox:CanCarryItem(who, what, count) then
            local success = Framework.ox:AddItem(who, what, count)
            return success == true
        end
        return false
    end
    if Framework.inventory ~= 'framework' then
        return true
    end
    if Framework.name == 'esx' and Framework.core then
        local xPlayer = Framework.core.GetPlayerFromId(who)
        if not xPlayer then return false end
        if xPlayer.canCarryItem and not xPlayer.canCarryItem(what, count) then
            return false
        end
        local itemspec = xPlayer.getInventoryItem(what)
        if not itemspec then return false end
        if (not xPlayer.canCarryItem) then
            if itemspec.limit and itemspec.limit ~= -1 and (itemspec.count + count) > itemspec.limit then
                return false
            end
        end
        xPlayer.addInventoryItem(what, count)
        return true
    end
    if Framework.name == 'qb' and Framework.core then
        local Player = Framework.core.Functions.GetPlayer(who)
        if not Player then return false end
        return Player.Functions.AddItem(what, count) == true
    end
    return false
end

-- Framework init (must run after log() exists)
Citizen.CreateThread(function()
    -- Wait for config + shared libs to load
    Citizen.Wait(0)
    initFramework()
end)

function makeToast(target, subject, message)
    TriggerClientEvent('mosh_uteknark:make_toast', target, subject, message)
end
function inChat(target, message)
    if target == 0 then
        log(message)
    else
        TriggerClientEvent('chat:addMessage',target,{args={'UteKnark', message}})
    end
end

function plantSeed(location, soil)
    
    local hits = cropstate.octree:searchSphere(location, Config.Distance.Space)
    if #hits > 0 then
        return false
    end

    verbose('Planting at',location,'in soil', soil)
    cropstate:plant(location, soil)
    return true
end

function doScenario(who, what, where)
    verbose('Telling', who,'to',what,'at',where)
    TriggerClientEvent('mosh_uteknark:do', who, what, where)
end

RegisterNetEvent('mosh_uteknark:success_plant')
AddEventHandler ('mosh_uteknark:success_plant', function(location, soil)
    local src = source
    if oneSyncEnabled and false then -- "and false" because something is weird in my OneSync stuff
        local ped = GetPlayerPed(src)
        --log('ped:',ped)
        local pedLocation = GetEntityCoords(ped)
        --log('pedLocation:',pedLocation)
        --log('location:', location)
        local distance = #(pedLocation - location)
        if distance > Config.Distance.Interact then
            if distance > 10 then
                log(GetPlayerName(src),'attempted planting at',distance..'m - Cheating?')
            end
            makeToast(src, _U('planting_text'), _U('planting_too_far'))
            return
        end
    end
    if soil and Config.Soil[soil] then
        local hits = cropstate.octree:searchSphere(location, Config.Distance.Space)
        if #hits == 0 then
            if TakeItem(src, Config.Items.Seed) then
                if plantSeed(location, soil) then
                    makeToast(src, _U('planting_text'), _U('planting_ok'))
                    doScenario(src, 'Plant', location)
                else
                    GiveItem(src, Config.Items.Seed)
                    makeToast(src, _U('planting_text'), _U('planting_failed'))
                end
            else
                makeToast(src, _U('planting_text'), _U('planting_no_seed'))
            end
        else
            makeToast(src, _U('planting_text'), _U('planting_too_close'))
        end
    else
        makeToast(src, _U('planting_text'), _U('planting_not_suitable_soil'))
    end
end)

RegisterNetEvent('mosh_uteknark:log')
AddEventHandler ('mosh_uteknark:log',function(...)
    local src = source
    log(src,GetPlayerName(src),...)
end)

RegisterNetEvent('mosh_uteknark:test_forest')
AddEventHandler ('mosh_uteknark:test_forest',function(forest)
    local src = source


    if IsPlayerAceAllowed(src, 'command.mosh_uteknark') or IsPlayerAceAllowed(src, 'command.uteknark') then

        local soil
        for candidate, quality in pairs(Config.Soil) do
            soil = candidate
            if quality >= 1.0 then
                break
            end
        end

        log(GetPlayerName(src),'('..src..') is magically planting a forest of',#forest,'plants')
        for i, tree in ipairs(forest) do
            cropstate:plant(tree.location, soil, tree.stage)
            if i % 25 == 0 then
                Citizen.Wait(0)
            end
        end
    else
        log('OY!', GetPlayerName(src),'with ID',src,'tried to spawn a test forest, BUT IS NOT ALLOWED!')
    end
end)

local function useSeed(source)
    local now = os.time()
    local last = lastPlant[source] or 0
    if now <= last + (Config.ActionTime / 1000) then
        makeToast(source, _U('planting_text'), _U('planting_too_fast'))
        return
    end

    if Config.Items.Seed and HasItem(source, Config.Items.Seed) then
        TriggerClientEvent('mosh_uteknark:attempt_plant', source)
        lastPlant[source] = now
    else
        makeToast(source, _U('planting_text'), _U('planting_no_seed'))
    end
end

Citizen.CreateThread(function()
    -- Wait until framework detection ran
    while not Framework.ready do
        Citizen.Wait(0)
    end

    -- Optional validation of configured items
    local itemList
    if Framework.name == 'esx' and Framework.core and Framework.core.Items then
        itemList = Framework.core.Items
    elseif Framework.name == 'qb' and Framework.core and Framework.core.Shared and Framework.core.Shared.Items then
        itemList = Framework.core.Shared.Items
    end
    if type(itemList) == 'table' then
        for forWhat, itemName in pairs(Config.Items) do
            if itemName and itemList[itemName] then
                log(forWhat, 'item in configuration ('..itemName..') found: Good!')
            elseif itemName then
                log('WARNING:', forWhat, 'item in configuration ('..itemName..') does not exist!')
            end
        end
    end

    -- Register seed usage depending on framework
    if not Config.Items.Seed then
        log('WARNING: Config.Items.Seed is nil; players will not be able to plant.')
        return
    end

    if Framework.name == 'esx' and Framework.core then
        Framework.core.RegisterUsableItem(Config.Items.Seed, function(source)
            useSeed(source)
        end)
    elseif Framework.name == 'qb' and Framework.core then
        -- QBCore: CreateUseableItem(item, cb)
        Framework.core.Functions.CreateUseableItem(Config.Items.Seed, function(source, item)
            useSeed(source)
        end)
    else
        -- Standalone: command-based fallback
        local cmd = (Config.Standalone and Config.Standalone.PlantCommand) or 'utekseed'
        RegisterCommand(cmd, function(source)
            useSeed(source)
        end, false)
        log('Standalone mode: use /'..cmd..' to plant a seed.')
    end
end)

Citizen.CreateThread(function()
    local databaseReady = false

    -- oxmysql: wait until the DB connection is ready.
    MySQL.ready(function()
        cropstate:load(function(plantCount)
            if plantCount == 1 then
                log('mosh_uteknark loaded a single plant!')
            else
                log('mosh_uteknark loaded',plantCount,'plants')
            end
        end)
        databaseReady = true
    end)

    while not databaseReady do
        Citizen.Wait(100)
    end

    while true do
        Citizen.Wait(0)
        local now = os.time()
        local begin = GetGameTimer()
        local plantsHandled = 0
        for id, plant in pairs(cropstate.index) do
            if type(id) == 'number' then -- Because of the whole "hashtable = true" thing
                local stageData = Growth[plant.data.stage]
                local growthTime = (stageData.time * 60 * Config.TimeMultiplier)
                local soilQuality = Config.Soil[plant.data.soil] or 1.0

                if stageData.interact then
                    local relevantTime = plant.data.time + ((growthTime / soilQuality) * Config.TimeMultiplier)
                    if now >= relevantTime then
                        verbose('Plant',id,'has died: No interaction in time')
                        cropstate:remove(id)
                    end
                else
                    local relevantTime = plant.data.time + ((growthTime * soilQuality) * Config.TimeMultiplier)
                    if now >= relevantTime then
                        if plant.data.stage < #Growth then
                            verbose('Plant',id,'has grown to stage',plant.data.stage + 1)
                            cropstate:update(id, plant.data.stage + 1)
                        else
                            verbose('Plant',id,'has died: Ran out of stages')
                            cropstate:remove(id)
                        end
                    end
                end

                plantsHandled = plantsHandled + 1
                if plantsHandled % 10 == 0 then
                    Citizen.Wait(0)
                end
            end
        end

        tickPlantCount = plantsHandled
        local tickTime = GetGameTimer() - begin
        table.insert(tickTimes, tickTime)
        while #tickTimes > 20 do
            table.remove(tickTimes, 1)
        end
    end
end)

local commands = {
    debug = function(source, args)
        if source == 0 then
            log('Client debugging on the console? Nope.')
        else
            TriggerClientEvent('mosh_uteknark:toggle_debug', source)
        end
    end,
    stage = function(source, args)
        if args[1] and string.match(args[1], "^%d+$") then
            local plant = tonumber(args[1])
            if cropstate.index[plant] then
                if args[2] and string.match(args[2], "^%d+$") then
                    local stage = tonumber(args[2])
                    if stage > 0 and stage <= #Growth then
                        log(source,GetPlayerName(source),'set plant',plant,'to stage',stage)
                        cropstate:update(plant, stage)
                    else
                        inChat(source, string.format("%i is an invalid stage", stage))
                    end
                else
                    inChat(source, "What stage?")
                end
            else
                inChat(source,string.format("Plant %i does not exist!", plant))
            end
        else
            inChat(source, "What plant, you say?")
        end
    end,
    forest = function(source, args)
        if source == 0 then
            log('Forests can\'t grow in a console, buddy!')
        else

            local count = #Growth * #Growth
            if args[1] and string.match(args[1], "%d+$") then
                count = tonumber(args[1])
            end

            local randomStage = false
            if args[2] then randomStage = true end

            TriggerClientEvent('mosh_uteknark:test_forest', source, count, randomStage)

        end
    end,
    stats = function(source, args)
        if cropstate.loaded then
            local totalTime = 0
            for i,time in ipairs(tickTimes) do
                totalTime = totalTime + time
            end
            local tickTimeAverage = totalTime / #tickTimes
            inChat(source, string.format("Tick time average: %.1fms", tickTimeAverage))
            inChat(source, string.format("Plant count: %i", tickPlantCount))
        else
            inChat(source,'Not loaded yet')
        end
    end,
    groundmat = function(source, args)
        if source == 0 then
            log('Console. The ground material is CONSOLE.')
        else
            TriggerClientEvent('mosh_uteknark:groundmat', source)
        end
    end,
    pyro = function(source, args)
        if source == 0 then
            log('You can\'t really test particle effects on the console.')
        else
            TriggerClientEvent('mosh_uteknark:pyromaniac', source)
        end
    end,
}

local function adminCommandHandler(source, args, raw)
    if #args > 0 then
        local directive = string.lower(args[1])
        if commands[directive] then
            if #args > 1 then
                local newArgs = {}
                for i,entry in ipairs(args) do
                    if i > 1 then
                        table.insert(newArgs, entry)
                    end
                end
                args = newArgs
            else
                args = {}
            end
            commands[directive](source,args)
        elseif source == 0 then
            log('Invalid directive: ' .. directive)
        else
            inChat(source,_U('command_invalid', directive))
        end
    else
        inChat(source, _U('command_empty', VERSION))
    end
end

-- Admin command (new name)
RegisterCommand('mosh_uteknark', adminCommandHandler, true)
-- Legacy alias (old name)
RegisterCommand('uteknark', adminCommandHandler, true)
