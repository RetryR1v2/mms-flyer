local VORPcore = exports.vorp_core:GetCore()

exports.vorp_inventory:registerUsableItem(Config.EmptyFlyerItem, function(data)
    local source = data.source
    TriggerClientEvent('mms-flyer:client:OpenCreator',source)
end)

exports.vorp_inventory:registerUsableItem(Config.FlyerItem, function(data)
    local src = data.source
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
    local FlyerData = MySQL.query.await("SELECT * FROM mms_flyer WHERE id=@id", { ["id"] = FlyerID})
    if #FlyerData > 0 then
        local Data = FlyerData[1]
        TriggerClientEvent('mms-flyer:client:openflyer',src,Data,ItemIDtoDelte)
    else
        VORPcore.NotifyTip(src,_U('NoFlyerFound'),5000)
    end
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