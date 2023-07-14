local myTraps = {}
local myArmedTraps = {}
local myCaughtTraps = {}
local TrapPrompt

local prompt = false
local armPromt = false

-------------------------
--Prompt Register begin
-------------------------
function SetupTrapPrompt()
    Citizen.CreateThread(function()
        local str = 'Colocar'
        TrapPrompt = PromptRegisterBegin()
        PromptSetControlAction(TrapPrompt, 0x07CE1E61)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(TrapPrompt, str)
        PromptSetEnabled(TrapPrompt, false)
        PromptSetVisible(TrapPrompt, false)
        PromptSetHoldMode(TrapPrompt, true)
        PromptRegisterEnd(TrapPrompt)

    end)
end

function SetupArmTrapPrompt()
    Citizen.CreateThread(function()
        local str = 'Colocar isca'
       ArmTrapPrompt = PromptRegisterBegin()
        PromptSetControlAction(ArmTrapPrompt, 0xCEFD9220)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(ArmTrapPrompt, str)
        PromptSetEnabled(ArmTrapPrompt, false)
        PromptSetVisible(ArmTrapPrompt, false)
        PromptSetHoldMode(ArmTrapPrompt, true)
        PromptRegisterEnd(ArmTrapPrompt)

    end)
end


--
-------------------------
--Prompt Register end
-------------------------

Citizen.CreateThread(function()
    SetupTrapPrompt()
    SetupArmTrapPrompt()
    while true do
        Wait(1000)
       
        --print(t)
        local pos = GetEntityCoords(PlayerPedId(), true)
                if myArmedTraps ~= nil then
                    for k, v in ipairs(myArmedTraps) do
                        if GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) < 15.0 then
                            if v.stage == 1 then
                                v.timer = v.timer-1
                                if v.timer == 0 then
                                    v.stage = 2
                                    local key = k
                                    TriggerEvent('dw_traps:fin2', v.object, v.x, v.y, v.z, key, v.hash, v.name)
                                end
                            end    
                        end
                    end
                end
                if myCaughtTraps ~= nil then
                    for k, v in ipairs(myCaughtTraps) do
                        if GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) < 15.0 then
                            if v.stage == 2 and GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) <= 2.0 then
                                if not v.prompt then
                                    v.prompt = true
                                end
                            end   
                            if v.stage == 2 and GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) > 2.1 then
                                if v.prompt then
                                    v.prompt = false
                                end
                            end
                        end
                    end
                end
    end
end)


local isPlacing = false

RegisterNetEvent('dw_traps:placetrap')
AddEventHandler('dw_traps:placetrap', function(itemn, hash)
    local myPed = PlayerPedId()
    if isPlacing == false then
        isPlacing= true
        local itemname = tostring(itemn)
        local pHead = GetEntityHeading(myPed)
        local pos = GetEntityCoords(myPed, true)
        local trap = hash
            if not HasModelLoaded(trap) then
                RequestModel(trap)
            end

            while not HasModelLoaded(trap) do
                Citizen.Wait(100)
            end
            local placing = true
            local tempObj = CreateObject(trap, pos.x, pos.y, pos.z, true, true, false)
            SetEntityHeading(tempObj, pHead)
           -- SetEntityAlpha(tempObj, 51)
            AttachEntityToEntity(tempObj, myPed, 0, 0.0, 1.0, -0.7, 0.0, 0.0, 0.0, true, false, false, false,false)

            while placing do
                Wait(1)
                if prompt == false then
                    PromptSetEnabled(TrapPrompt, true)
                    PromptSetVisible(TrapPrompt, true)
                    prompt = true
                end
            if PromptHasHoldModeCompleted(TrapPrompt) then

              if IsEntityInWater(myPed) and  IsEntityInWater(tempObj)  then 

                PromptSetEnabled(TrapPrompt, false)
                PromptSetVisible(TrapPrompt, false)
                prompt = false
                local pPos = GetEntityCoords(tempObj, true)
                DeleteObject(tempObj)
                TaskTurnPedToFaceCoord(myPed, pPos.x, pPos.y , pPos.z, 3000)
                Citizen.Wait(3000)
                
                Animation(5000,'Colocando')
            

                local object = CreateObject(trap, pPos.x, pPos.y, pPos.z, true, true, false)
             
             
                local trapsCount = #myTraps+1
                myTraps[trapsCount] = {["object"] = object, ['x'] = pPos.x, ['y'] = pPos.y, ['z'] = pPos.z, ['stage'] = 0, ['hash'] = hash}

                PlaceObjectOnGroundProperly(myTraps[trapsCount].object)
                SetEntityCompletelyDisableCollision(myTraps[trapsCount].object,false,true)
                SetEntityAsMissionEntity(myTraps[trapsCount].object, true)
                SetModelAsNoLongerNeeded(trap)
                isPlacing= false
                break
              else
                TriggerEvent("redemrp_notification:start", 'Não está na agua!', 5)
                end
            end
                
            end
       
    end

end)

RegisterNetEvent('dw_traps:armtrap')
AddEventHandler('dw_traps:armtrap', function(itemn, hash)

    if isPlacing == false then
        local pos = GetEntityCoords(PlayerPedId(), true)
        local object = nil
        local key = nil
        local hash1=  nil
        local x, y, z = nil, nil, nil
        local itemname 
        local holeObject
        
        for k, v in ipairs(myTraps) do
            if v.stage == 0 then
                if GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) < 2.0 then
                    object = v.object
                    key = k
                    x, y, z = v.x, v.y, v.z
                    hash1 = v.hash 
                    itemname =v.name
                    break
                end
            end
        end
        
        local trap = hash1
        
        if DoesEntityExist(object) then
            isPlacing = true
            
            RequestModel(trap)

            while not HasModelLoaded(trap) do
                Citizen.Wait(1)
            end

            Animation(5000,'Armando')

            DeleteObject(object)
            table.remove(myTraps, key)
            Wait(800)
            local object = CreateObject(trap, x, y, z, true, true, false)
            local trapsCount = #myArmedTraps+1
            myArmedTraps[trapsCount] = {["object"] = object, ['x'] = x, ['y'] = y, ['z'] = z, ['stage'] = 1, ['timer'] = Config.TimeToHarvest, ['hash'] = hash1,['prompt'] = false, }

            SetEntityCompletelyDisableCollision(myArmedTraps[trapsCount].object,false,true)
         PlaceObjectOnGroundProperly(myArmedTraps[trapsCount].object)
            SetEntityAsMissionEntity(myArmedTraps[trapsCount].object, true)
            SetModelAsNoLongerNeeded(trap)
            isPlacing = false
            armPromt =false
        end
    else
        TriggerEvent("redemrp_notification:start", 'Finish first what you started!', 5)
    end
end)

RegisterNetEvent('dw_traps:fin2')
AddEventHandler('dw_traps:fin2', function(object2, x, y, z, key, hash,itemname )
    --
   
    
    TriggerEvent("redemrp_notification:start", 'Sua armadilha pegou algo!', 5)
    
    local trap  = hash
    
    RequestModel(trap)

    while not HasModelLoaded(trap) do
        Citizen.Wait(1)
    end
    
    DeleteObject(object2)
    Wait(800)
    local object3 = CreateObject(trap, x, y, z, true, true, false)
    PlaceObjectOnGroundProperly(object3)
    local trapsCount = #myCaughtTraps+1
    myCaughtTraps[trapsCount] = {["object"] = object3, ['x'] = x, ['y'] = y, ['z'] = z, ['stage'] = 2, ['prompt'] = false, ['hash'] = hash, ['name'] = itemname}

    SetEntityCompletelyDisableCollision(myCaughtTraps[trapsCount].object,false,true)
     PlaceObjectOnGroundProperly(myCaughtTraps[trapsCount].object)
    SetEntityAsMissionEntity(myCaughtTraps[trapsCount].object, true)
    SetModelAsNoLongerNeeded(trap)
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
        local pos = GetEntityCoords(PlayerPedId(), true)
        if myTraps ~= nil  then
			for k, v in ipairs(myTraps) do
				if GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) < 1.0 then
					if v.stage == 0 then
                        DrawText3D(v.x, v.y, v.z, 'Precisa de Isca!')
                        if armPromt == false then
                            PromptSetEnabled(ArmTrapPrompt, true)
                            PromptSetVisible(ArmTrapPrompt, true)
                            armPromt = true                            
                        end
                        if isPlacing == false then
                            if PromptHasHoldModeCompleted(ArmTrapPrompt) then
                                print('placeBait')
                                PromptSetEnabled(ArmTrapPrompt, false)
                                PromptSetVisible(ArmTrapPrompt, false)
                                TriggerServerEvent("dw_traps:placeBait", v.hash)
                            end
                        end
					end
				else 
                    PromptSetEnabled(ArmTrapPrompt, false)
                    PromptSetVisible(ArmTrapPrompt, false)
                    armPromt = false          
                end
                
			end
        end
        if myArmedTraps ~= nil then
            for k, v in ipairs(myArmedTraps) do
				if GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) < 1.0 then
					if v.stage == 1 then
                        DrawText3D(v.x, v.y, v.z, 'Até pegar algo: ' .. v.timer)
					end
				end
			end
        end
        if myCaughtTraps ~= nil then
            for k, v in ipairs(myCaughtTraps) do
				if GetDistanceBetweenCoords(v.x, v.y, v.z, pos.x, pos.y, pos.z, true) < 1.0 then
					if v.stage == 2 then
                        DrawText3D(v.x, v.y, v.z, 'pegar [U]')
					end
					if v.prompt then
                        if isPlacing == false then
                            if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0xD8F73058) then
                                local key = k
                                HarvestTrap(key,v.name)
                                TriggerServerEvent("dw_traps:giveitem", v.hash)
                            end
                        end
					end
				end
			end
        end
	end
end)

function Animation (time,text)
    
    local playerpedid = PlayerPedId()
        
    RequestAnimDict("amb_work@world_human_farmer_weeding@male_a@idle_a")
    while ( not HasAnimDictLoaded( "amb_work@world_human_farmer_weeding@male_a@idle_a" ) ) do
            Citizen.Wait( 100 )
    end
 TaskPlayAnim(playerpedid, "amb_work@world_human_farmer_weeding@male_a@idle_a", "idle_a", 8.0, -8.0, time, 1, 0, true, 0, false, 0, false)

 exports.redemrp_progressbars:DisplayProgressBar(time, text, function()
    Wait(time)
end) 
    ClearPedTasksImmediately(playerpedid)
end

function HarvestTrap(key, itemname)
    if isPlacing == false then
        isPlacing = true
       
        Animation(5000,'Pegando')    
        isPlacing = false
       
        DeleteObject(myCaughtTraps[key].object)
        table.remove(myCaughtTraps, key)
    else
        TriggerEvent("redemrp_notification:start", 'Finish first what you started!', 5)
    end
end


function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)

    --Citizen.InvokeNative(0x66E0276CC5F6B9DA, 2)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic)
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 52, 52, 52, 190, 0)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        for k, v in ipairs(myTraps) do
            DeleteObject(v.object)
			table.remove(myTraps, k)
		end
		for k, v in ipairs(myArmedTraps) do
			DeleteObject(v.object)
			table.remove(myArmedTraps, k)
		end
        for k, v in ipairs(myCaughtTraps) do
			DeleteObject(v.object)
			table.remove(myCaughtTraps, k)
		end
	end
end)