local VORPcore = exports.vorp_core:GetCore()

exports.vorp_inventory:registerUsableItem(Config.EmptyFlyerItem, function(data)
    local source = data.source
    TriggerClientEvent('mms-flyer:client:OpenCreator',source)
end)
exports.vorp_inventory:registerUsableItem(Config.FlyerItem, function(data)
    local src = data.source
    if next(data.item) ~= nil and data.item.metadata then --Item has Metadata
        local flyerId = data.item.metadata.FlyerID
		OpenFlyer(src, flyerId, data.item.id)
		return
    end
    -- If metadata not found just open the select menu
    local Inventory = exports.vorp_inventory:getUserInventoryItems(src,nil)
    Citizen.Wait(250)
    TriggerClientEvent('mms-flyer:client:selectflyer',src,Inventory)
end)

RegisterServerEvent('mms-flyer:server:CreateFlyer',function (inputName,inputLink)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Name = Character.firstname .. ' ' .. Character.lastname
    local identifier = Character.identifier
    local charIdentifier = Character.charIdentifier
    MySQL.insert('INSERT INTO `mms_flyer` (identifier, charidentifier, name, flyername, photolink) VALUES (?, ?, ?, ?, ?)',
    {identifier,charIdentifier,Name,inputName,inputLink}, function()end)
    exports.vorp_inventory:subItem(src, Config.EmptyFlyerItem, 1, {})
    Citizen.Wait(1000)
    local result = MySQL.query.await("SELECT * FROM mms_flyer WHERE charidentifier=@charidentifier", { ["charidentifier"] = charIdentifier})
        if #result > 0 then
            local LatestFlyer = #result
            local FlyerId = result[LatestFlyer].id
            exports.vorp_inventory:addItem(src, Config.FlyerItem, 1, { description = _U('FlyerMetaName') .. inputName, FlyerID =  FlyerId })
        end
end)

RegisterServerEvent('mms-flyer:server:OpenFlyer',function(FlyerID,ItemIDtoDelte)
    local src = source
	OpenFlyer(src, FlyerID, ItemIDtoDelte)
end)

function OpenFlyer(src, flyerId, itemIdToDelete)
    local FlyerData = MySQL.query.await("SELECT * FROM mms_flyer WHERE id=@id", { ["id"] = flyerId})
    if #FlyerData > 0 then
        local Data = FlyerData[1]
        TriggerClientEvent('mms-flyer:client:openflyer',src, Data, itemIdToDelete)
    else
        VORPcore.NotifyTip(src,_U('NoFlyerFound'),5000)
    end
end

RegisterServerEvent('mms-flyer:server:GetFlyer',function(FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords,PostModel)
    local src = source
    local AllFlyer = MySQL.query.await("SELECT * FROM mms_flyer", { })
        if #AllFlyer > 0 then
            TriggerClientEvent('mms-flyer:client:ReciveFlyer',src,FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords,AllFlyer,PostModel)
        end
end)

RegisterServerEvent('mms-flyer:server:AllFlyer',function(FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local MycharIdentifier = Character.charIdentifier
    local AllFlyer = MySQL.query.await("SELECT * FROM mms_flyer", { })
        if #AllFlyer > 0 then
            TriggerClientEvent('mms-flyer:client:GetFlyerData',src,AllFlyer,MycharIdentifier)
        end
end)

RegisterServerEvent('mms-flyer:server:HangFlyer',function(FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords,NewFlyerX,NewFlyerY,NewFlyerZ,PostModel)
    local src = source

        if not Config.LatestVORPInvetory then
            exports.vorp_inventory:subItemID(src, ItemIDtoDelte,nil,nil)
        else
            exports.vorp_inventory:subItemById(src, ItemIDtoDelte,nil,nil,1)
        end

        MySQL.update('UPDATE `mms_flyer` SET hanging = ? WHERE id = ?',{1, FlyerID})
        MySQL.update('UPDATE `mms_flyer` SET hangtime = ? WHERE id = ?',{Config.PosterHours * 60, FlyerID})
        MySQL.update('UPDATE `mms_flyer` SET posx = ? WHERE id = ?',{NewFlyerX, FlyerID})
        MySQL.update('UPDATE `mms_flyer` SET posy = ? WHERE id = ?',{NewFlyerY, FlyerID})
        MySQL.update('UPDATE `mms_flyer` SET posz = ? WHERE id = ?',{NewFlyerZ, FlyerID})
        MySQL.update('UPDATE `mms_flyer` SET postmodel = ? WHERE id = ?',{PostModel, FlyerID})

        Citizen.Wait(500)
        for h,player in ipairs(GetPlayers()) do
            TriggerClientEvent('mms-flyer:client:ReloadFlyer',player)
        end

        VORPcore.NotifyTip(src,_U('FlyerHanging'),5000)
end)

RegisterServerEvent('mms-flyer:server:DeleteFlyer',function(FlyerID,FlyerDesc,ItemIDtoDelte)
    local src = source
    if not Config.LatestVORPInvetory then
        exports.vorp_inventory:subItemID(src, ItemIDtoDelte,nil,nil)
    else
        exports.vorp_inventory:subItemById(src, ItemIDtoDelte,nil,nil,1)
    end
    MySQL.execute('DELETE FROM mms_flyer WHERE id = ?', {FlyerID}, function() end)
    VORPcore.NotifyTip(src,_U('FlyerDeleted'),5000)
end)

RegisterServerEvent('mms-flyer:server:DeleteFlyerPost',function(FlyerID)
    local src = source
    MySQL.execute('DELETE FROM mms_flyer WHERE id = ?', {FlyerID}, function() end)
    VORPcore.NotifyTip(src,_U('FlyerDeleted'),5000)
    for h,player in ipairs(GetPlayers()) do
        TriggerClientEvent('mms-flyer:client:ReloadFlyer',player)
    end
    VORPcore.NotifyTip(src,_U('FlyerDeletedfromPost'),5000)
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(300000)
        local AllFlyer = MySQL.query.await("SELECT * FROM mms_flyer", { })
        if #AllFlyer > 0 then
            for h,v in ipairs(AllFlyer) do
                if v.hanging == 1 then
                    local OldTimer = v.hangtime
                    local NewTimer = OldTimer - 5
                    local FlyerID = v.id
                    if NewTimer <= 0 then
                        MySQL.execute('DELETE FROM mms_flyer WHERE id = ?', {FlyerID}, function() end)
                        for h,player in ipairs(GetPlayers()) do
                            TriggerClientEvent('mms-flyer:client:ReloadFlyer',player)
                        end
                    else
                        MySQL.update('UPDATE `mms_flyer` SET hangtime = ? WHERE id = ?',{NewTimer, FlyerID})
                    end
                end
            end
        end
    end
end)
