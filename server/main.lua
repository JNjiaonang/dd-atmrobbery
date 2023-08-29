local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("dd-atmrobbery:server:getReward")
AddEventHandler("dd-atmrobbery:server:getReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local random = math.random(10000, 20000)
    Player.Functions.AddMoney("cash", tonumber(random), "ATM")
    TriggerClientEvent("QBCore:Notify", src, "You got" .. tonumber(random) .. ' $', "success")
end)

RegisterServerEvent("dd-atmrobbery:server:spawnRope")
AddEventHandler("dd-atmrobbery:server:spawnRope", function()
    TriggerClientEvent("dd-atmrobbery:client:spawnRope", -1)
end)

RegisterServerEvent("dd-atmrobbery:server:attachVehicle")
AddEventHandler("dd-atmrobbery:server:attachVehicle", function(NetworkVehicle, NetworkPlayerPed)
    TriggerClientEvent("dd-atmrobbery:client:attachVehicle", -1, NetworkVehicle, NetworkPlayerPed)
end)

RegisterServerEvent("dd-atmrobbery:server:attachATM")
AddEventHandler("dd-atmrobbery:server:attachATM", function(ATMObjectProp, ObjectCoordsx, ObjectCoordsy, ObjectCoordsz, NetworkVehicle, NetObjectConsole)
    TriggerClientEvent("dd-atmrobbery:client:attachATM", -1, ATMObjectProp, ObjectCoordsx, ObjectCoordsy, ObjectCoordsz, NetworkVehicle, NetObjectConsole)
end)

RegisterServerEvent("dd-atmrobbery:server:spawnATM")
AddEventHandler("dd-atmrobbery:server:spawnATM", function(NetObjectConsole)
    TriggerClientEvent("dd-atmrobbery:client:spawnATM", -1, NetObjectConsole)
end)

RegisterServerEvent("dd-atmrobbery:server:deleteATM")
AddEventHandler("dd-atmrobbery:server:deleteATM", function(NetConsoleProp)
    TriggerClientEvent("dd-atmrobbery:client:deleteATM", -1, NetConsoleProp)
end)

RegisterServerEvent("dd-atmrobbery:server:deleteRopeProp")
AddEventHandler("dd-atmrobbery:server:deleteRopeProp", function(Rope)
    TriggerClientEvent("dd-atmrobbery:client:deleteRopeProp", -1, Rope)
end)

RegisterServerEvent("dd-atmrobbery:server:ropeDelete")
AddEventHandler("dd-atmrobbery:server:ropeDelete", function()
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem("rope", 1, false)
end)

QBCore.Functions.CreateUseableItem("rope", function(source, item)
    local src = source
    TriggerClientEvent("dd-atmrobbery:client:ropeUsed", src)
end)