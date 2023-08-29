local QBCore, Rope, DrawText, RobberyStarted, Vehicle, inVehicle, CurrentCops = exports['qb-core']:GetCoreObject(), nil, false, false, nil, inVehicle, 0

function ATMObject()
    for k,v in pairs({"prop_atm_02", "prop_atm_03", "prop_fleeca_atm"}) do
        local obj = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 5.0, GetHashKey(v))
        if DoesEntityExist(obj) then
            local ATMObject = {
                prop = obj,
                type = v
            }
            return ATMObject
        end
    end
    return nil
end

function ATMConsole()
    for k,v in pairs({"loq_fleeca_atm_console", "loq_atm_02_console", "loq_atm_03_console"}) do 
        local obj = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 5.0, GetHashKey(v))
        if DoesEntityExist(obj) then
            return obj
        end
    end
    return nil
end

function loadExistModel(hash)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(1)
        end
    end
end

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

CreateThread(function()
    while true do
        if DrawText then
            exports["qb-core"]:DrawText("[E] Attach - [X] Remove", "left")
            if IsControlJustPressed(1, 73) then
                RobberyStarted = false
                DrawText = false
                TriggerServerEvent("dd-atmrobbery:server:deleteRopeProp", Rope)
                exports["qb-core"]:HideText()
            elseif IsControlJustPressed(1, 38) then
                exports["qb-core"]:HideText()
                DrawText = false
                local PlayerPed = PlayerPedId()
                local ATMObject = ATMObject()
                TaskTurnPedToFaceEntity(PlayerPed, ATMObject.prop, 1000)
                QBCore.Functions.Progressbar('attachatm', "Attaching rope to ATM", 12000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = 'anim@gangops@facility@servers@',
                    anim = 'hotwire',
                    flags = 16,
                }, {}, {}, function() -- Play When Done
                    --exports["ps-dispatch"]:SuspiciousActivity()
                    ClearPedTasks(PlayerPed)
                    local ObjectDes = nil
                    local ObjectConsole = nil
                    local ObjectCoords = GetEntityCoords(ATMObject.prop)
                    local ObjectHeading = GetEntityHeading(ATMObject.prop)
    
                    if ATMObject.type == "prop_atm_02" then
                        ObjectDes = CreateObject("loq_atm_02_des", vector3(ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 0.35), true)
                        ObjectConsole = CreateObject("loq_atm_02_console", vector3(ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 0.55), true)
                        SetEntityHeading(ObjectDes, ObjectHeading)
                        SetEntityHeading(ObjectConsole, ObjectHeading)
                        FreezeEntityPosition(ObjectDes, true)
                        FreezeEntityPosition(ObjectConsole, true)
                    elseif ATMObject.type == "prop_atm_03" then
                        ObjectDes = CreateObject("loq_atm_03_des", vector3(ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 0.35), true)
                        ObjectConsole = CreateObject("loq_atm_03_console", vector3(ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 0.65), true)
                        SetEntityHeading(ObjectDes, ObjectHeading)
                        SetEntityHeading(ObjectConsole, ObjectHeading)
                        FreezeEntityPosition(ObjectDes, true)
                        FreezeEntityPosition(ObjectConsole, true)
                    elseif ATMObject.type == "prop_fleeca_atm" then
                        ObjectDes = CreateObject("loq_fleeca_atm_des", vector3(ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 0.35), true)
                        ObjectConsole = CreateObject("loq_fleeca_atm_console", vector3(ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 0.65), true)
                        SetEntityHeading(ObjectDes, ObjectHeading)
                        SetEntityHeading(ObjectConsole, ObjectHeading)
                        FreezeEntityPosition(ObjectDes, true)
                        FreezeEntityPosition(ObjectConsole, true)
                    end
                    RobberyStarted = false
                    Wait(200)
                    local ATMObjectProp = ObjToNet(ATMObject.prop)
                    local NetworkVehicle = VehToNet(Vehicle)
                    local NetObjectConsole = ObjToNet(ObjectConsole)
                    TriggerServerEvent("dd-atmrobbery:server:attachATM", ATMObjectProp, ObjectCoords.x, ObjectCoords.y, ObjectCoords.z, NetworkVehicle, NetObjectConsole)
                    SetEntityCoords(ATMObject.prop, ObjectCoords.x, ObjectCoords.y, ObjectCoords.z - 10.0)
                    inVehicle = true
                    while inVehicle do
                        if IsPedInAnyVehicle(PlayerPed) then
                            Wait(math.random(25000, 45000))
                            local NetObjectConsole = ObjToNet(ObjectConsole)
                            TriggerServerEvent("dd-atmrobbery:server:spawnATM", NetObjectConsole)
                            inVehicle = false
                        end
                        Wait(0)
                    end
                end, function()
                    RobberyStarted = false
                end)
            end
            Wait(1)
        else
            Wait(150)
        end
    end
end)

RegisterNetEvent("dd-atmrobbery:client:ropeUsed")
AddEventHandler("dd-atmrobbery:client:ropeUsed", function()
    if CurrentCops >= 0 then
        local PlayerPed = PlayerPedId()
        Vehicle = QBCore.Functions.GetClosestVehicle()
        if not IsPedInAnyVehicle(PlayerPed, false) then
            TaskTurnPedToFaceEntity(PlayerPed, Vehicle, 1000)
            QBCore.Functions.Progressbar('usingRopeATM', "Attaching rope to vehicle", 15000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = 'anim@gangops@facility@servers@',
                anim = 'hotwire',
                flags = 16,
            }, {}, {}, function()
                ClearPedTasks(PlayerPed)
                TriggerServerEvent("dd-atmrobbery:server:spawnRope")
                RobberyStarted = true
                DrawText = true
                local NetworkVehicle = VehToNet(Vehicle)
                local NetworkPlayerPed = PedToNet(PlayerPed)
                while RobberyStarted do
                    TriggerServerEvent("dd-atmrobbery:server:attachVehicle", NetworkVehicle, NetworkPlayerPed)
                    Wait(0)
                end
            end, function()
                QBCore.Functions.Notify("You canceled attachin rope!", 'error', 7500)
            end)
        end
    else
        QBCore.Functions.Notify("No police are in city!", "error")
    end
end)

RegisterNetEvent("dd-atmrobbery:client:crackATM")
AddEventHandler("dd-atmrobbery:client:crackATM", function()
    local ConsoleProp = ATMConsole()
    QBCore.Functions.Progressbar('crackatm', "Cracking ATM", 12000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@gangops@facility@servers@',
        anim = 'hotwire',
        flags = 16,
    }, {}, {}, function()
        local NetConsoleProp = ObjToNet(ConsoleProp)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent("dd-atmrobbery:server:deleteATM", NetConsoleProp)
        TriggerServerEvent("dd-atmrobbery:server:deleteRopeProp", Rope)
        TriggerServerEvent("dd-atmrobbery:server:getReward")
    end, function()
        QBCore.Functions.Notify("You canceled cracking the ATM!", 'error', 7500)
    end)
end)

RegisterNetEvent("dd-atmrobbery:client:spawnRope")
AddEventHandler("dd-atmrobbery:client:spawnRope", function()
    RopeLoadTextures()
    Rope = AddRope(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1, 7.0, 1.0, 0, 0, 0, 0, 0, 0)
end)

RegisterNetEvent("dd-atmrobbery:client:attachVehicle")
AddEventHandler("dd-atmrobbery:client:attachVehicle", function(NetworkVehicle, NetworkPlayerPed)
    local NetVeh = NetToEnt(NetworkVehicle)
    local NetPed = NetToEnt(NetworkPlayerPed)
    local PedCoords = GetEntityCoords(NetPed)
    AttachEntitiesToRope(Rope, NetVeh, NetPed, GetOffsetFromEntityInWorldCoords(NetVeh, 0, -2.3, 0.5), GetPedBoneCoords(NetPed, 6286, 0.0, 0.0, 0.0), 7.0, 0, 0, "rope_attach_a", "rope_attach_b")
    SlideObject(Rope, PedCoords.x, PedCoords.y, PedCoords.z, 1.0, 1.0, 1.0, true)
end)

RegisterNetEvent("dd-atmrobbery:client:attachATM")
AddEventHandler("dd-atmrobbery:client:attachATM", function(ATMObjectProp, ObjectCoordsx, ObjectCoordsy, ObjectCoordsz, NetworkVehicle, NetObjectConsole)
    NetworkRequestControlOfEntity(ATMObjectProp)
    local NetVeh = NetToEnt(NetworkVehicle)
    local NetObject = NetToEnt(NetObjectConsole)
    local NetProp = NetToEnt(ATMObjectProp)
    local ObjectCoords = GetEntityCoords(NetObject)
    SetEntityCoords(NetProp, ObjectCoordsx, ObjectCoordsy, ObjectCoordsz - 10.0)
    AttachEntitiesToRope(Rope, NetVeh, NetObject, GetOffsetFromEntityInWorldCoords(NetVeh, 0, -2.3, 0.5), ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 1.0, 7.0, 0, 0, "rope_attach_a", "rope_attach_b")
end)

RegisterNetEvent("dd-atmrobbery:client:spawnATM")
AddEventHandler("dd-atmrobbery:client:spawnATM", function(NetObjectConsole)
    local ConsoleObject = NetToEnt(NetObjectConsole)
    FreezeEntityPosition(ConsoleObject, false)
    SetObjectPhysicsParams(ConsoleObject, 170.0, -1.0, 30.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
end)

RegisterNetEvent("dd-atmrobbery:client:deleteATM")
AddEventHandler("dd-atmrobbery:client:deleteATM", function(NetConsoleProp)
    local ConsoleProp = NetToEnt(NetConsoleProp)
    DeleteEntity(ConsoleProp)
end)

RegisterNetEvent("dd-atmrobbery:client:deleteRopeProp")
AddEventHandler("dd-atmrobbery:client:deleteRopeProp", function(Rope)
    DeleteRope(Rope)
    Rope = nil
end)

loadExistModel("loq_atm_02_console")
loadExistModel("loq_atm_02_des")
loadExistModel("loq_atm_03_console")
loadExistModel("loq_atm_03_des")
loadExistModel("loq_fleeca_atm_console")
loadExistModel("loq_fleeca_atm_des")

local models = {
    GetHashKey("loq_fleeca_atm_console"),
    GetHashKey("loq_atm_02_console"),
    GetHashKey("loq_atm_03_console")
}


exports["qb-target"]:AddTargetModel(models, {
    options = {
        {
            event = "dd-atmrobbery:client:crackATM",
            icon = "fas fa-circle",
            label = "Crack ATM"
        }
    }, 
    job = {"all"},
    distance = 2.5
})