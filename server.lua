RedEM = exports["redem_roleplay"]:RedEM()

data = {}
TriggerEvent("redemrp_inventory:getData",function(call)
    data = call
end)


local harvestXPmultiplier = 1

RegisterServerEvent("RegisterUsableItem:fishtrap")
AddEventHandler("RegisterUsableItem:fishtrap", function(source)
	local _source = source
    print('call placetrap')
    TriggerClientEvent('dw_traps:placetrap', _source, 'fishtrap',`mp001_p_mp_trap05x_nolid`)
end)

RegisterServerEvent('dw_traps:placeBait')
AddEventHandler('dw_traps:placeBait',function (hash)
       
    for k, v in ipairs(Config.Baits) do
    
        print('Baits', v)
        local bait = data.getItemData(v)
        local baitItemData = data.getItem(source, bait.label)

        if baitItemData.ItemAmount >=1 then
            baitItemData.RemoveItem(1)
            TriggerClientEvent('dw_traps:armtrap',source,hash)
        
           
    else         
        TriggerClientEvent("redem_roleplay:NotifyRight", source, 'você não possui iscas para usar', 5)
    end
end
       
end)

RegisterServerEvent('dw_traps:giveitem')
AddEventHandler('dw_traps:giveitem', function(tipo)
    local _source = source
	local count = math.random(4, 8)
	local ItemData
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
		if tipo == `mp001_p_mp_trap05x_nolid` then
			ItemData = data.getItem(_source, 'smallfish')
			showXP = (count * harvestXPmultiplier) 
			local ItemInfo = data.getItemData('smallfish')
			local itemWeight = ItemInfo.weight * count
			local itemWeightformat = string.format("%.2f", itemWeight)
            TriggerClientEvent("redem_roleplay:NotifyLeft", _source, "Voce pegou", ''..count..' peixe pequeno ('..itemWeightformat.. 'kg)', "generic_textures", "tick", 3000)
        end
    end)
    ItemData.AddItem(count)
end)