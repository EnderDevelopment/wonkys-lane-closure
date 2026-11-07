local cones = {}
local coneObjects = {}
local editing = false
local canManage = false
local routedVehicles = {}

local function notify(description, notificationType)
    lib.notify({ title = 'Lane Closure', description = description, type = notificationType or 'inform' })
end

local function deleteConeObjects()
    for _, object in ipairs(coneObjects) do
        if DoesEntityExist(object) then
            SetEntityAsMissionEntity(object, true, true)
            DeleteObject(object)
        end
    end
    coneObjects = {}
end

local function spawnCones()
    deleteConeObjects()
    if #cones == 0 then return end

    lib.requestModel(Config.Editor.coneModel)
    for _, cone in ipairs(cones) do
        local object = CreateObject(Config.Editor.coneModel, cone.x, cone.y, cone.z + Config.Editor.groundOffset, false, false, false)
        SetEntityHeading(object, cone.heading)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        coneObjects[#coneObjects + 1] = object
    end
    SetModelAsNoLongerNeeded(Config.Editor.coneModel)
end

local function drawPlacementMarker()
    local player = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(player, 0.0, Config.Editor.placementDistance, 0.0)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, false)
    if found then coords = vector3(coords.x, coords.y, groundZ) end
    DrawMarker(2, coords.x, coords.y, coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityHeading(player), 0.25, 0.25, 0.25, 255, 150, 0, 180, false, true, 2, false, nil, nil, false)
    return coords
end

local function saveLayout()
    TriggerServerEvent('wonkys_laneclosure:server:saveLayout', cones)
    notify(('Saved %d cones.'):format(#cones), 'success')
end

local function stopEditing()
    editing = false
    lib.hideTextUI()
    notify(('Layout closed with %d cones.'):format(#cones), 'inform')
end

local function startEditing(clearFirst)
    if clearFirst then
        cones = {}
        spawnCones()
    end
    editing = true
    notify('Place cones with E. Delete the last cone with Backspace. Save with G. Close with X.', 'inform')
end

local function openMenu()
    lib.registerContext({
        id = 'wonkys_laneclosure_menu',
        title = 'Manual Lane Closure',
        options = {
            {
                title = 'Edit current layout',
                description = ('%d cones currently deployed'):format(#cones),
                icon = 'pen-to-square',
                onSelect = function() startEditing(false) end
            },
            {
                title = 'Create new layout',
                description = 'Delete the current cones and start placing again',
                icon = 'plus',
                onSelect = function() startEditing(true) end
            },
            {
                title = 'Save layout',
                description = 'Persist the cones for every player',
                icon = 'floppy-disk',
                disabled = #cones == 0,
                onSelect = saveLayout
            },
            {
                title = 'Clear layout',
                description = 'Remove all deployed cones',
                icon = 'trash',
                disabled = #cones == 0,
                onSelect = function()
                    cones = {}
                    spawnCones()
                    saveLayout()
                end
            }
        }
    })
    lib.showContext('wonkys_laneclosure_menu')
end

local function getClosureGeometry()
    if #cones < 2 then return nil end
    local first = cones[1]
    local last = cones[#cones]
    local dx, dy = last.x - first.x, last.y - first.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 1.0 then return nil end
    return vector3(dx / length, dy / length, 0.0), length, vector3(first.x, first.y, first.z)
end

local function rerouteTraffic()
    if not Config.Traffic.enabled then return end
    local direction, length, start = getClosureGeometry()
    if not direction then return end

    local right = vector3(-direction.y, direction.x, 0.0)
    local count = 0
    local now = GetGameTimer()

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if count >= Config.Traffic.maxVehicles then break end
        local driver = GetPedInVehicleSeat(vehicle, -1)
        if driver ~= 0 and DoesEntityExist(driver) and not IsPedAPlayer(driver) and not IsEntityDead(driver) then
            local position = GetEntityCoords(vehicle)
            local rel = position - start
            local along = rel.x * direction.x + rel.y * direction.y
            local side = rel.x * right.x + rel.y * right.y
            local approaching = along >= -Config.Traffic.approachDistance and along <= length + Config.Traffic.barrierDistance
            if approaching and math.abs(side) <= Config.Traffic.diversionOffset * 1.5 and (not routedVehicles[vehicle] or now - routedVehicles[vehicle] > Config.Traffic.cooldown) then
                local targetAlong = math.max(0.0, math.min(length, along)) + Config.Traffic.diversionDistance
                local target = start + direction * targetAlong + right * (side >= 0.0 and Config.Traffic.diversionOffset or -Config.Traffic.diversionOffset)
                TaskVehicleDriveToCoordLongrange(driver, vehicle, target.x, target.y, target.z, 18.0, 786603, 4.0)
                routedVehicles[vehicle] = now
                count = count + 1
            end
        end
    end
end

RegisterNetEvent('wonkys_laneclosure:client:loadLayout', function(layout)
    cones = type(layout) == 'table' and layout or {}
    spawnCones()
end)

CreateThread(function()
    canManage = lib.callback.await('wonkys_laneclosure:server:canManage', false)
    TriggerServerEvent('wonkys_laneclosure:server:requestLayout')

    RegisterCommand('laneclosure', function()
        if not canManage then
            notify('You are not allowed to manage lane closures.', 'error')
            return
        end
        openMenu()
    end, false)
end)

CreateThread(function()
    while true do
        if editing then
            local placement = drawPlacementMarker()
            lib.showTextUI('[E] Place cone   [Backspace] Remove last   [G] Save   [X] Close')
            if IsControlJustReleased(0, 38) then
                cones[#cones + 1] = {
                    x = placement.x,
                    y = placement.y,
                    z = placement.z,
                    heading = GetEntityHeading(PlayerPedId())
                }
                spawnCones()
            elseif IsControlJustReleased(0, 177) and #cones > 0 then
                table.remove(cones)
                spawnCones()
            elseif IsControlJustReleased(0, 47) then
                saveLayout()
            elseif IsControlJustReleased(0, 73) then
                stopEditing()
            end
            Wait(0)
        else
            lib.hideTextUI()
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        rerouteTraffic()
        Wait(Config.Traffic.scanInterval)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    lib.hideTextUI()
    deleteConeObjects()
end)

exports('GetConeLayout', function()
    return cones
end)

exports('ClearLayout', function()
    cones = {}
    spawnCones()
    if canManage then saveLayout() end
end)
