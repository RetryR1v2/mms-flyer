local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local FeatherMenu =  exports['feather-menu'].initiate()
local progressbar = exports.vorp_progressbar:initiate()

local SelectFlyerOpen = false
local ReadFlyerOpen = false
local ReadFlyerPost = false
local CreatedBlips = {}
local FlyerObjects = {}

local Active = false
---------------------------------------------------------------------------------------------------------
--------------------------------------------- Main Menu -------------------------------------------------
---------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function ()
    FlyerMain = FeatherMenu:RegisterMenu('FlyerMain', {
        top = '10%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '350px',
                ['min-height'] = '350px'
            }
        },
        draggable = true,
    --canclose = false
}, {
    opened = function()
        --print("MENU OPENED!")
    end,
    closed = function()
        --print("MENU CLOSED!")
    end,
    topage = function(data)
        --print("PAGE CHANGED ", data.pageid)
    end
})
FlyerMainPage1 = FlyerMain:RegisterPage('seite1')
    FlyerMainPage1:RegisterElement('header', {
        value = _U('CreateFlyerHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerMainPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    local inputName = ''
    FlyerMainPage1:RegisterElement('input', {
    label = _U('FlyerName'),
    placeholder = "...",
    persist = false,
    style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
    }
    }, function(data)
        inputName = data.value
    end)
    local inputLink = ''
    FlyerMainPage1:RegisterElement('input', {
    label = _U('DirektLink'),
    placeholder = "...",
    persist = false,
    style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
    }
    }, function(data)
        inputLink = data.value
    end)
    FlyerMainPage1:RegisterElement('button', {
        label = _U('CreateFlyer'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
            if inputName and inputLink ~= nil then
                VORPcore.NotifyTip(_U('FlyerCreated'),5000)
                FlyerMain:Close({ 
                })
                TriggerServerEvent('mms-flyer:server:CreateFlyer',inputName,inputLink)
            else
                VORPcore.NotifyTip(_U('WrongInput'),5000)
            end
        end)
    FlyerMainPage1:RegisterElement('button', {
        label =  _U('CloseFlyer'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        FlyerMain:Close({ 
        })
    end)
    FlyerMainPage1:RegisterElement('subheader', {
        value = _U('CreateFlyerSubHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerMainPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
end)

Citizen.CreateThread(function ()
    FlyerSubMain = FeatherMenu:RegisterMenu('FlyerSubMain', {
        top = '10%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '750px',
                ['min-height'] = '450px'
            }
        },
        draggable = true,
    --canclose = false
}, {
    opened = function()
        --print("MENU OPENED!")
    end,
    closed = function()
        --print("MENU CLOSED!")
    end,
    topage = function(data)
        --print("PAGE CHANGED ", data.pageid)
    end
})
end)

RegisterNetEvent('mms-flyer:client:OpenCreator',function ()
    FlyerMain:Open({
        startupPage = FlyerMainPage1,
    })
end)

RegisterNetEvent('mms-flyer:client:selectflyer')
AddEventHandler('mms-flyer:client:selectflyer',function(Inventory)
    if not SelectFlyerOpen then
        SelectFlyerOpen = true
    elseif SelectFlyerOpen then
        FlyerMainPage2:UnRegister()
    end
    FlyerMainPage2 = FlyerMain:RegisterPage('seite2')
    FlyerMainPage2:RegisterElement('header', {
        value = _U('SelectFlyerHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerMainPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for h,v in ipairs(Inventory) do
        if v.name == Config.FlyerItem then
            local buttonLabel = ' ' .. v.metadata.description .. _U('FlyerID') .. v.metadata.FlyerID
            FlyerMainPage2:RegisterElement('button', {
                label = buttonLabel,
                style = {
                ['background-color'] = '#FF8C00',
                ['color'] = 'orange',
                ['border-radius'] = '6px'
                }
            }, function()
                local FlyerID = v.metadata.FlyerID
                local ItemIDtoDelte = v.id
                FlyerMain:Close({ 
                })
                TriggerServerEvent('mms-flyer:server:OpenFlyer',FlyerID,ItemIDtoDelte)
            end)
        end
    end
    FlyerMainPage2:RegisterElement('button', {
        label =  _U('StopSelect'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        FlyerMain:Close({ 
        })
    end)
    FlyerMainPage2:RegisterElement('subheader', {
        value = _U('SelectFlyerSubHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerMainPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerMain:Open({
        startupPage = FlyerMainPage2,
    })
end)

RegisterNetEvent('mms-flyer:client:openflyer')
AddEventHandler('mms-flyer:client:openflyer',function(FlyerData,ItemIDtoDelte)
    if not ReadFlyerOpen then
        ReadFlyerOpen = true
    elseif ReadFlyerOpen then
        FlyerSubMainPage1:UnRegister()
    end
    FlyerSubMainPage1 = FlyerSubMain:RegisterPage('seite1')
    FlyerSubMainPage1:RegisterElement('header', {
        value = FlyerData.flyername,
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMainPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMainPage1:RegisterElement("html", {
        slot = 'content',
        value = {
            [[
                <img width="500px" height="600px" style="margin: 0 auto;" src="]] .. FlyerData.photolink .. [[" />
            ]]
        }
    })
    FlyerSubMainPage1:RegisterElement('button', {
        label = _U('HangFlyer'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            }
        }, function()
            local FlyerID = FlyerData.id
            local FlyerDesc = FlyerData.flyername
            HangFlyer(FlyerID,FlyerDesc,ItemIDtoDelte)
            FlyerSubMain:Close({ 
            })
    end)
    FlyerSubMainPage1:RegisterElement('button', {
        label = _U('DeleteFlyer'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            }
        }, function()
            local FlyerID = FlyerData.id
            local FlyerDesc = FlyerData.flyername
            TriggerServerEvent('mms-flyer:server:DeleteFlyer',FlyerID,FlyerDesc,ItemIDtoDelte)
            FlyerSubMain:Close({ 
            })
    end)
    FlyerSubMainPage1:RegisterElement('button', {
        label =  _U('CloseFlyer2'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        FlyerSubMain:Close({ 
        })
    end)
    FlyerSubMainPage1:RegisterElement('subheader', {
        value = FlyerData.flyername,
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMainPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMain:Open({
        startupPage = FlyerSubMainPage1,
    })
end)

function HangFlyer(FlyerID,FlyerDesc,ItemIDtoDelte)
    local PostFound = false
    local PostCoords = nil
    local PostModel = nil
    local PlayerCoords = GetEntityCoords(PlayerPedId())
    for h,v in ipairs(Config.Objects) do
        CloseHangingPost = Citizen.InvokeNative(0xBFA48E2FF417213F, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.HangDistance,GetHashKey(v.Model), 0)
        if CloseHangingPost then
            local ClosePost = Citizen.InvokeNative(0xE143FA2249364369, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, Config.HangDistance,GetHashKey(v.Model), false, false, false)
            PostCoords = GetEntityCoords(ClosePost)
            PostModel = v.Model
            PostFound = true
        end
    end
        if  PostFound then
            TriggerServerEvent('mms-flyer:server:GetFlyer',FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords,PostModel)
        else
            print('Hier kann man nicht Aufhängen')
        end
        
end

RegisterNetEvent('mms-flyer:client:ReciveFlyer')
AddEventHandler('mms-flyer:client:ReciveFlyer',function(FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords,AllFlyer,PostModel)
    local FlyerClose = false
    local NewFlyerX = PostCoords.x
    local NewFlyerY = PostCoords.y
    local NewFlyerZ = PostCoords.z
        for h,v in ipairs(AllFlyer) do
            local HangingX = v.posx
            local HangingY = v.posy
            local HangingZ = v.posz
            local Distance = GetDistanceBetweenCoords(NewFlyerX,NewFlyerY,NewFlyerZ,HangingX,HangingY,HangingZ,true)
            if Distance < 5 and v.hanging == 1 then
                FlyerClose = true
            end
        end

    if not FlyerClose then
        TriggerServerEvent('mms-flyer:server:HangFlyer',FlyerID,FlyerDesc,ItemIDtoDelte,PostCoords,NewFlyerX,NewFlyerY,NewFlyerZ,PostModel)
    else
        VORPcore.NotifyTip(_U('AlreadyHanging'),5000)
    end
end)

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Citizen.Wait(10000)
    TriggerEvent('mms-flyer:client:ReloadFlyer')
end)

Citizen.CreateThread(function ()
    Citizen.Wait(5000)
    TriggerEvent('mms-flyer:client:ReloadFlyer')
end)

RegisterNetEvent('mms-flyer:client:ReloadFlyer')
AddEventHandler('mms-flyer:client:ReloadFlyer',function()
    Active = false
    for _, blips in ipairs(CreatedBlips) do
        blips:Remove()
    end
    for _, objects in ipairs(FlyerObjects) do
        DeleteObject(objects)
    end
    TriggerServerEvent('mms-flyer:server:AllFlyer')
end)

RegisterNetEvent('mms-flyer:client:GetFlyerData')
AddEventHandler('mms-flyer:client:GetFlyerData',function(AllFlyer,MycharIdentifier)
    Active = true
    FlyerPromptGroup = BccUtils.Prompts:SetupPromptGroup()
    ReadFlyerPrompt =  FlyerPromptGroup:RegisterPrompt(_U('ReadFlyerPrompt'), Config.KeyG, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    DeleteFlyerPrompt =  FlyerPromptGroup:RegisterPrompt(_U('DeleteFlyerPrompt'), Config.KeyR, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    for h,v in pairs(AllFlyer) do
        if v.hanging == 1 and Config.UseBlips then
            local FlyerBlip = BccUtils.Blips:SetBlip(_U('FlyerBlip'), Config.BlipSprite, 2.0, v.posx, v.posy, v.posz)
            CreatedBlips[#CreatedBlips + 1] = FlyerBlip
            local Flyerobj = CreateObject(Config.PosterProp, v.posx, v.posy, v.posz +1.5,true,true,false)
            SetEntityInvincible(Flyerobj,true)
            FreezeEntityPosition(Flyerobj,true)
            FlyerObjects[#FlyerObjects + 1] = Flyerobj
        end
    end
    while Active do
        Citizen.Wait(2)
        for h,v in pairs(AllFlyer) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, v.posx, v.posy, v.posz, true)
        if dist < Config.FylerDistanceToShow then
            FlyerPromptGroup:ShowGroup(_U('FlyerPromptGroup'))

            if ReadFlyerPrompt:HasCompleted() then
                local FlyerData = v
                TriggerEvent('mms-flyer:client:openflyerpost',FlyerData)
            end

            if DeleteFlyerPrompt:HasCompleted() then
                if v.charidentifier == MycharIdentifier then
                    FlyerID = v.id
                    TriggerServerEvent('mms-flyer:server:DeleteFlyerPost',FlyerID)
                    Active = false
                else
                    VORPcore.NotifyTip(_U('NotYourFlyer'),5000)
                end
            end
        end
    end
    end
end)

RegisterNetEvent('mms-flyer:client:openflyerpost')
AddEventHandler('mms-flyer:client:openflyerpost',function(FlyerData)
    if not ReadFlyerPost then
        ReadFlyerPost = true
    elseif ReadFlyerPost then
        FlyerSubMainPage4:UnRegister()
    end
    FlyerSubMainPage4 = FlyerSubMain:RegisterPage('seite1')
    FlyerSubMainPage4:RegisterElement('header', {
        value = FlyerData.flyername,
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMainPage4:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMainPage4:RegisterElement("html", {
        slot = 'content',
        value = {
            [[
                <img width="500px" height="600px" style="margin: 0 auto;" src="]] .. FlyerData.photolink .. [[" />
            ]]
        }
    })
    FlyerSubMainPage4:RegisterElement('button', {
        label =  _U('CloseFlyer2'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        FlyerSubMain:Close({ 
        })
    end)
    FlyerSubMainPage4:RegisterElement('subheader', {
        value = FlyerData.flyername,
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMainPage4:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    FlyerSubMain:Open({
        startupPage = FlyerSubMainPage4,
    })
end)

---- CleanUp on Resource Restart 

RegisterNetEvent('onResourceStop',function(resource)
    if resource == GetCurrentResourceName() then
        for _, blips in ipairs(CreatedBlips) do
            blips:Remove()
	    end
        for _, objects in ipairs(FlyerObjects) do
            DeleteObject(objects)
	    end
    end
end)

--- Utilities

 
------ Progressbar

function Progressbar(Time,Text)
    progressbar.start(Text, Time, function ()
    end, 'linear')
    Wait(Time)
    ClearPedTasks(PlayerPedId())
end

------ Animation

function CrouchAnim()
    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TaskPlayAnim(ped, dict, "inspectfloor_player", 0.5, 8.0, -1, 1, 0, false, false, false)
end
