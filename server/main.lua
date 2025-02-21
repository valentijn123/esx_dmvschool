ESX.RegisterServerCallback('esx_dmvschool:canYouPay', function(source, cb, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.TheoryTestCategories[type].price

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        cb(true)
    else
        cb(false)
    end
end)

AddEventHandler('esx:playerLoaded', function(source)
    TriggerEvent('esx_license:getLicenses', source, function(licenses)
        TriggerClientEvent('esx_dmvschool:loadLicenses', source, licenses)
    end)
end)

RegisterNetEvent('esx_dmvschool:addLicense')
AddEventHandler('esx_dmvschool:addLicense', function(type)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Map test types to license types
    local licenseTypes = {
        dmv = 'dmv',
        boat = 'boat',
        bike = 'bike',
        truck = 'truck'
    }

    -- Get the correct license type
    local licenseType = licenseTypes[type]
    
    if licenseType then
        TriggerEvent('esx_license:addLicense', source, licenseType, function()
            TriggerEvent('esx_license:getLicenses', source, function(licenses)
                TriggerClientEvent('esx_dmvschool:loadLicenses', source, licenses)
            end)
        end)
    end
end)

