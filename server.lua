TriggerEvent("getCore",function(core)
    VorpCore = core
end)
VorpInv = exports.vorp_inventory:vorp_inventoryApi()

Citizen.CreateThread(function()
	for k,v in pairs(Config.items) do 
		VorpInv.RegisterUsableItem(k, function(data)
            useditem(data.source,k,v,data)
		end)
	end
end)

function useditem(source,item,iteminfo,info)
    local _source = source
    local meta = info.item.metadata
    local durability 
    if meta ~= nil then 
        durability = meta.durability 
    end
    if durability == nil then 
        durability = Config.items[item].dura
    end
    TriggerClientEvent("syn_miner_lumber:itemused", _source, item, iteminfo, durability,info)
end


---@param source -- player id

---@param item -- item name

---@param amount-- amount of item

---@param callback-- callback function async or sync leave nil
RegisterServerEvent('syn_miner_lumber:addItem')
AddEventHandler('syn_miner_lumber:addItem', function(thetype, itemused)
    local _source = source
    local itemcount = VorpInv.getItemCount(_source, itemused)
    if itemcount <= 0 then
        VorpCore.NotifyRightTip(_source, language.noaxe .. itemused .. language.noaxe2,3000)
        return
    end
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local job = Character.job
    local chance = math.random(1, 10)
    local reward = {}
    for k, v in pairs(Config.rewards[thetype]) do
        if v.chance >= chance then
            table.insert(reward, v)
        end
    end
    local amount2 = keysx(reward)
    if amount2 ~= 0 then
        local chance2 = math.random(1, keysx(reward))
        local count = math.random(1, reward[chance2].amount)
        if containsjob(job, Config.jobs[thetype]) then
            count = count + Config.rewardincrease
        end
        local canCarry2 = exports.vorp_inventory:canCarryItems(_source, count)

        if canCarry2 == false then
            do
                TriggerClientEvent("vorp:TipRight", _source, language.cantcarry, 3000)
            end
        elseif canCarry2 then
            local adding = VorpInv.addItem(_source, reward[chance2].name, count)
            if adding then
                local canCarry = exports.vorp_inventory:canCarryItem(_source, reward[chance2].name, count)
                if canCarry then
                    TriggerClientEvent("vorp:TipRight", _source, language.youfound .. reward[chance2].label, 3000)
                else
                    TriggerClientEvent("vorp:TipRight", _source, language.cantcarry .. reward[chance2].label, 3000)
                end
            end
        end
    end
end)


RegisterServerEvent('syn_miner_lumber:removeitem')
AddEventHandler('syn_miner_lumber:removeitem', function(item,itemdata)
	local _source = source
    local id = itemdata.item.mainid
    VorpInv.subItemID(_source, id)
    TriggerClientEvent("vorp:TipRight", _source, language.axebroken, 2000)
end)

RegisterServerEvent('syn_miner_lumber:updateitem')
AddEventHandler('syn_miner_lumber:updateitem', function(item,newdura,itemdata)
    local _source = source
    local itemmetadata = itemdata.item
    if itemmetadata.metadata ~= nil then 
        local meta = itemmetadata.metadata
        local description = meta.description
        if description ~= nil then 
            if string.match(description,language.durability) then
                local newstring = string.gsub(meta.description, language.durability.."%d+", language.durability..newdura)
                meta.description = newstring
                meta.durability = newdura
            else
                meta.description = meta.description.." <br> "..language.durability..newdura
                meta.durability = newdura
            end
        else
            meta.description = language.durability..newdura
            meta.durability = newdura
        end
        VorpInv.setItemMetadata(_source, itemmetadata.mainid, meta)
    end
end)
