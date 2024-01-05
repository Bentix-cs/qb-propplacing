QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('ev-propplacing:client:placeProp', function(item, prop, itemid)
    if not IsPedInAnyVehicle(PlayerPedId(), true) and not IsEntityDead(PlayerPedId()) then
        StartPropPlacing(item, prop, itemid)
    end
end)

function StartPropPlacing(item, prop, itemid)
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped, true)
    local playerHeading = GetEntityHeading(ped)
    local propCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.9, 0)

    local placedProp = CreateObjectNoOffset(GetHashKey(prop), propCoords, false, false, false)
    PlaceObjectOnGroundProperly(placedProp)
    SetEntityAlpha(placedProp, 150, true)
    SetEntityCollision(placedProp, false, false)
    SetEntityHeading(placedProp, playerHeading)
    
    if IsPedInAnyVehicle(ped) or IsEntityDead(ped) then
        return
    end

    local form = setupScaleform("instructional_buttons")

    Citizen.CreateThread(function()
        while true do

            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)

            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            SetPauseMenuActive(false)

            local pos = GetEntityCoords(placedProp, false)

            local yaw = GetEntityHeading(ped) * math.pi / 180.0
            local right = norm(vector3(math.cos(yaw) * 2, math.sin(yaw) * 2, 0)) * 0.005
            yaw = yaw - math.pi / 2.0
            local forward = norm(vector3(math.cos(yaw) * 2, math.sin(yaw) * 2, 0)) * 0.005

            if IsDisabledControlPressed(0, 21) then
                right = right * 3.0
                forward = forward * 3.0
            end

            -- Forward
            if IsDisabledControlPressed(0, 32) then
                if (#(playerCoords - (pos - forward))) < 4 then
                    pos = pos - forward
                end
                SetEntityCoords(placedProp, pos, false, false, false, false)
            end

            -- Backwards
            if IsDisabledControlPressed(0, 31) then
                if (#(playerCoords - (pos + forward))) < 4 then
                    pos = pos + forward
                end
                SetEntityCoords(placedProp, pos, false, false, false, false)
            end

            -- Right
            if IsDisabledControlPressed(0, 35) then
                if (#(playerCoords - (pos + right))) < 4 then
                    pos = pos + right
                end
                SetEntityCoords(placedProp, pos, false, false, false, false)
            end

            -- Left
            if IsDisabledControlPressed(0, 34) then
                if (#(playerCoords - (pos - right))) < 4 then
                    pos = pos - right
                end
                SetEntityCoords(placedProp, pos, false, false, false, false)
            end

            -- Up
            if IsDisabledControlPressed(0, 44) then
                local tempCoords = GetOffsetFromEntityInWorldCoords(placedProp, 0, 0, 0.005)
                SetEntityCoords(placedProp, tempCoords, false, false, false, false)
            end

            -- Down
            if IsDisabledControlPressed(0, 38) then
                local tempCoords = GetOffsetFromEntityInWorldCoords(placedProp, 0, 0, -0.005)
                SetEntityCoords(placedProp, tempCoords, false, false, false, false)
            end

            -- Rotate left
            if IsDisabledControlPressed(0, 48) then
                local tempHeading = GetEntityHeading(placedProp) + 1
                SetEntityHeading(placedProp, tempHeading)
            end

            -- Rotate right
            if IsDisabledControlPressed(0, 73) then
                local tempHeading = GetEntityHeading(placedProp) - 1
                SetEntityHeading(placedProp, tempHeading)
            end

            -- Reset to ground
            if IsDisabledControlPressed(0, 140) then
                PlaceObjectOnGroundProperly(placedProp)
            end

            -- Break
            if IsDisabledControlPressed(0, 202) then
                DeleteEntity(placedProp)
                break
            end

            -- Place
            if IsDisabledControlPressed(0, 176) then
                PlacePropFinal(placedProp, item, itemid)
                break
            end

            Wait(1)
        end
    end)
end

function PlacePropFinal(prop, item, itemid)
    TriggerServerEvent('ev-propplacing:server:savePersistentProp', GetEntityCoords(prop, false), GetEntityHeading(prop), GetEntityModel(prop), item, itemid)
    DeleteEntity(prop)
end



--[[Citizen.CreateThread(function()
    TriggerServerEvent('ev-propplacing:server:initProps')
    while true do
        Wait(1)
        local ped = PlayerPedId()
        if IsControlJustPressed(0, 52) and not IsPedInAnyVehicle(ped) and not IsEntityDead(ped) then
            TriggerServerEvent('ev-propplacing:server:deletePersistentProp', GetEntityCoords(ped))
        end
    end
end)]]


RegisterNetEvent('ev-propplacing:client:playAnimation', function()
    while (not HasAnimDictLoaded("random@mugging1")) do
        RequestAnimDict("random@mugging1")
        Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), "random@mugging1", "pickup_low", 1.0, 1.0, -1, 0, 0, 0, 0, 0)
end)

RegisterNetEvent('ev-propplacing:client:addTarget', function(entity)
    while not DoesEntityExist(NetToObj(entity)) do 
        Wait(10)
    end
    local prop = NetToObj(entity)
    exports["qb-target"]:AddTargetEntity(prop, {
        options = {
            {
                num = 1,
                targeticon = 'fas fa-hand',
                label = 'Aufheben',
                action = function(entity)
                    local ped = PlayerPedId()
                    if IsPedInAnyVehicle(ped) or IsEntityDead(ped) then
                        return
                    end
                    TriggerServerEvent('ev-propplacing:server:deletePersistentPropByNetID', ObjToNet(entity))
                end
            }
        },
        distance = 2
    })
end)




function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    ScaleformMovieMethodAddParamPlayerNameString(ControlButton)
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    -- draw it once to set up layout
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 35, true))
    Button(GetControlInstructionalButton(2, 33, true))
    Button(GetControlInstructionalButton(2, 34, true))
    Button(GetControlInstructionalButton(2, 32, true))
    ButtonMessage("Bewegen")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 46, true))
    Button(GetControlInstructionalButton(2, 44, true))
    ButtonMessage("Hoch/Runter")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 73, true))
    Button(GetControlInstructionalButton(2, 48, true))
    ButtonMessage("Drehen")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 250, true))
    ButtonMessage("Auf Boden zurücksetzten")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, 21, true))
    ButtonMessage("Beschleunigen")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    Button(GetControlInstructionalButton(2, 194, true))
    ButtonMessage("Abbrechen")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    Button(GetControlInstructionalButton(2, 191, true))
    ButtonMessage("Bestätigen")
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    EndScaleformMovieMethod()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND")
    EndScaleformMovieMethod()
    
    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    return scaleform
end

