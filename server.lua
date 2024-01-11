QBCore = exports['qb-core']:GetCoreObject()
local props = {}
local spawned = false

RegisterNetEvent('qb-propplacing:server:savePersistentProp', function(coords, heading, model, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Wait(100)
    if Config.Inventory == 'qb-inventory' then

        local propId = GeneratePropId()
        exports.oxmysql:execute('INSERT INTO qb_propplacing (id, model, item, x, y, z, heading, citizen, metadata) VALUES (@id, @model, @item, @x, @y, @z, @heading, @citizen, @metadata)', {['@id'] = propId, ['@model'] = model, ['@item'] = item.name, ['@x'] = coords.x, ['@y'] = coords.y, ['@z'] = coords.z, ['@heading'] = heading, ["@citizen"] = Player.PlayerData.citizenid, ["@metadata"] = json.encode(item.info)}, function(result)
            local prop = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, true, false, false)
            SetEntityHeading(prop, heading)
            FreezeEntityPosition(prop, true)
            Entity(prop).state.useditem = item.name
            Entity(prop).state.propid = propId
            Entity(prop).state.metadata = item.info
            props[#props+1] = prop
            TriggerClientEvent('qb-propplacing:client:playAnimation', src)
            TriggerClientEvent('qb-propplacing:client:addTarget', -1, NetworkGetNetworkIdFromEntity(prop))

            exports['qb-inventory']:RemoveItem(src, item.name, 1, item.slot)
        end)
    elseif Config.Inventory == 'core_inventory' then
        local itemexact = Player.Functions.GetItemByName(item)

        local propId = GeneratePropId()
        exports.oxmysql:execute('INSERT INTO qb_propplacing (id, model, item, x, y, z, heading, citizen, metadata) VALUES (@id, @model, @item, @x, @y, @z, @heading, @citizen, @metadata)', {['@id'] = propId, ['@model'] = model, ['@item'] = item, ['@x'] = coords.x, ['@y'] = coords.y, ['@z'] = coords.z, ['@heading'] = heading, ["@citizen"] = Player.PlayerData.citizenid, ["@metadata"] = json.encode(itemexact.info)}, function(result)
            local prop = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, true, false, false)
            SetEntityHeading(prop, heading)
            FreezeEntityPosition(prop, true)
            Entity(prop).state.useditem = item
            Entity(prop).state.propid = propId
            Entity(prop).state.metadata = itemexact.info
            props[#props+1] = prop
            TriggerClientEvent('qb-propplacing:client:playAnimation', src)
            TriggerClientEvent('qb-propplacing:client:addTarget', -1, NetworkGetNetworkIdFromEntity(prop))

            Player.Functions.RemoveItem(item, 1)
        end)
    end
end)

RegisterNetEvent('qb-propplacing:server:deletePersistentProp', function(playerCoords)
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

    exports.oxmysql:execute('DELETE FROM qb_propplacing WHERE id = ?', {id}, function()
        TriggerClientEvent('qb-propplacing:client:playAnimation', src)
        Wait(1000)
        if Config.Inventory == 'qb-inventory' then
            exports['qb-inventory']:AddItem(src, item, 1, metadata)
        elseif Config.Inventory == 'core_inventory' then
            Player.Functions.AddItem(item, 1, false, metadata)
        end
        DeleteEntity(closestProp)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("message.itempickup"), "success")
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

    exports.oxmysql:execute('DELETE FROM qb_propplacing WHERE id = ?', {id}, function()
        TriggerClientEvent('qb-propplacing:client:playAnimation', src)
        Wait(1000)
        if Config.Inventory == 'qb-inventory' then
            exports['qb-inventory']:AddItem(src, item, 1, metadata)
        elseif Config.Inventory == 'core_inventory' then
            Player.Functions.AddItem(item, 1, false, metadata)
        end
        DeleteEntity(prop)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("message.itempickup"), "success")
    end)
end)


RegisterNetEvent('qb-propplacing:server:initProps')
AddEventHandler('qb-propplacing:server:initProps', function()
    if not spawned then
        exports.oxmysql:execute('SELECT * FROM qb_propplacing', function(result)
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
                    TriggerClientEvent('qb-propplacing:client:addTarget', -1, NetworkGetNetworkIdFromEntity(prop))
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
    local result = exports.oxmysql:executeSync('SELECT * FROM qb_propplacing WHERE id = ?', {TID})
    Wait(10)
    if result[1] then
        return GenerateTempId()
    else
        return TID:upper()
    end
end
