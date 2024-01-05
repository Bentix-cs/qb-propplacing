QBCore = exports['qb-core']:GetCoreObject()
local props = {}
local spawned = false

RegisterNetEvent('ev-propplacing:server:savePersistentProp', function(coords, heading, model, item, itemid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local itemexact = Player.Functions.GetItemByName(item)
    Wait(100)
    Player.Functions.RemoveItem(item, 1)
    local propId = GeneratePropId()
    exports.oxmysql:execute('INSERT INTO props (id, model, item, x, y, z, heading, citizen, metadata) VALUES (@id, @model, @item, @x, @y, @z, @heading, @citizen, @metadata)', {['@id'] = propId, ['@model'] = model, ['@item'] = item, ['@x'] = coords.x, ['@y'] = coords.y, ['@z'] = coords.z, ['@heading'] = heading, ["@citizen"] = Player.PlayerData.citizenid, ["@metadata"] = json.encode(itemexact.info)}, function(result) 
        local prop = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, true, false, false)
        SetEntityHeading(prop, heading)
        FreezeEntityPosition(prop, true)
        Entity(prop).state.useditem = item
        Entity(prop).state.propid = propId
        Entity(prop).state.metadata = itemexact.info
        props[#props+1] = prop
        TriggerClientEvent('ev-propplacing:client:playAnimation', src)
        TriggerClientEvent('ev-propplacing:client:addTarget', -1, NetworkGetNetworkIdFromEntity(prop))
    end)
end)

RegisterNetEvent('ev-propplacing:server:deletePersistentProp', function(playerCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local closestDist = -1
    local closestProp = -1
    for k, v in pairs(props) do
        local dist = #(playerCoords - GetEntityCoords(v))
        if closestDist == -1 or dist < closestDist then
            if dist <= 2.0 then
                closestProp = v
            end
        end
    end

    if closestProp == -1 then
        return
    end

    local item = Entity(closestProp).state.useditem
    local id = Entity(closestProp).state.propid
    local metadata = Entity(closestProp).state.metadata

    exports.oxmysql:execute('DELETE FROM props WHERE id = ?', {id}, function()
        TriggerClientEvent('ev-propplacing:client:playAnimation', src)
        Wait(1000)
        Player.Functions.AddItem(item, 1, false, metadata)
        DeleteEntity(closestProp)
        TriggerClientEvent('QBCore:Notify', src, "Objekt erfolgreich aufgehoben!", "success")
    end)
end)

RegisterNetEvent('ev-propplacing:server:deletePersistentPropByNetID', function(entity)
    while not DoesEntityExist(NetworkGetEntityFromNetworkId(entity)) do 
        Wait(10)
    end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local prop = NetworkGetEntityFromNetworkId(entity)

    local item = Entity(prop).state.useditem
    local id = Entity(prop).state.propid
    local metadata = Entity(prop).state.metadata

    exports.oxmysql:execute('DELETE FROM props WHERE id = ?', {id}, function()
        TriggerClientEvent('ev-propplacing:client:playAnimation', src)
        Wait(1000)
        Player.Functions.AddItem(item, 1, false, metadata)
        DeleteEntity(prop)
        TriggerClientEvent('QBCore:Notify', src, "Objekt erfolgreich aufgehoben!", "success")
    end)
end)


RegisterNetEvent('ev-propplacing:server:initProps')
AddEventHandler('ev-propplacing:server:initProps', function()
    if not spawned then
        exports.oxmysql:execute('SELECT * FROM props', function(result)
            if result[1] then
                for i = 1, (#result), 1 do
                    local coords = vector3(result[i].x, result[i].y, result[i].z)
                    local prop = CreateObjectNoOffset(result[i].model, coords, true, true, false)
                    FreezeEntityPosition(prop, true)
                    SetEntityHeading(prop, result[i].heading)
                    Entity(prop).state.useditem = result[i].item
                    Entity(prop).state.propid = result[i].id
                    Entity(prop).state.metadata = json.decode(result[i].metadata)
                    props[#props+1] = prop
                    TriggerClientEvent('ev-propplacing:client:addTarget', -1, NetworkGetNetworkIdFromEntity(prop))
                end
            end
        end)
        spawned = true
    end
end)



RegisterNetEvent('onResourceStop')
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(props) do
            DeleteEntity(v)
        end
    end
end)


function GeneratePropId()
    local TID = QBCore.Shared.RandomStr(3) .. "-" ..  QBCore.Shared.RandomStr(3) .. "-" .. QBCore.Shared.RandomStr(3)
    local result = exports.oxmysql:executeSync('SELECT * FROM props WHERE id = ?', {TID})
    Wait(10)
    if result[1] then
        return GenerateTempId()
    else
        return TID:upper()
    end
end
