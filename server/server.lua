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
