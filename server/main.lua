local QBCore

local function hasPermission(source)
    if not Config.RequireJob then return true end
    if GetResourceState('qb-core') ~= 'started' then return false end
    QBCore = QBCore or exports['qb-core']:GetCoreObject()
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false end
    local job = player.PlayerData.job
    local minimumGrade = Config.AllowedJobs[job.name]
    return minimumGrade ~= nil and job.grade.level >= minimumGrade
end

lib.callback.register('wonkys_laneclosure:server:canManage', hasPermission)

RegisterNetEvent('wonkys_laneclosure:server:saveLayout', function(layout)
    local source = source
    if not hasPermission(source) then return end
    if type(layout) ~= 'table' or #layout > 200 then return end

    local clean = {}
    for _, cone in ipairs(layout) do
        if type(cone) == 'table' and
            type(cone.x) == 'number' and type(cone.y) == 'number' and type(cone.z) == 'number' and
            type(cone.heading) == 'number' and
            math.abs(cone.x) < 10000 and math.abs(cone.y) < 10000 and math.abs(cone.z) < 2000 then
            clean[#clean + 1] = { x = cone.x, y = cone.y, z = cone.z, heading = cone.heading }
        end
    end
    SaveResourceFile(GetCurrentResourceName(), 'layout.json', json.encode(clean), -1)
    TriggerClientEvent('wonkys_laneclosure:client:loadLayout', -1, clean)
end)

RegisterNetEvent('wonkys_laneclosure:server:requestLayout', function()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'layout.json')
    local layout = raw and json.decode(raw) or {}
    TriggerClientEvent('wonkys_laneclosure:client:loadLayout', source, layout)
end)
