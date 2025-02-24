# 5h rijschool

## Installatie

1. **Installeer de UI:**
   Om de UI te installeren, heb je twee opties: zelf builden of de voorgebouwde UI downloaden.

   ### Optie 1: Zelf Builden

   1. **Installeer Node.js:**
      Zorg ervoor dat je [Node.js](https://nodejs.org/) geïnstalleerd hebt op je systeem.

   2. **Installeer de benodigde pakketten:**
      Navigeer naar de `html` map van de resource en installeer de benodigde npm-pakketten:
      ```sh
      cd html
      npm install
      ```

   3. **Build de UI:**
      Gebruik het volgende commando om de UI te builden:
      ```sh
      npm run build
      ```

   4. **Controleer de build:**
      Zorg ervoor dat de build succesvol is en dat de gegenereerde bestanden zich in de `dist` map bevinden.

   ### Optie 2: Voorgebouwde UI Downloaden

   1. **Download de voorgebouwde UI:**
      Download de voorgebouwde UI van de link naar de voorgebouwde UI.

   2. **Plaats de bestanden:**
      Plaats de gedownloade bestanden in de [html](http://_vscodecontentref_/1) map van de resource.

2. **Licenties Toevoegen:**
   Voeg de volgende licenties toe aan de `licenses` tabel in je database. Normaal bevat de `licenses` tabel alleen de volgende gegevens:
   ```json
   {
       "table": "licenses",
       "rows": [
           {
               "type": "boat",
               "label": "Boat License"
           },
           {
               "type": "dmv",
               "label": "Driving Permit"
           },
           {
               "type": "drive",
               "label": "Drivers License"
           },
           {
               "type": "drive_bike",
               "label": "Motorcycle License"
           },
           {
               "type": "drive_truck",
               "label": "Commercial Drivers License"
           },
           {
               "type": "weapon",
               "label": "Weapon License"
           },
           {
               "type": "weed_processing",
               "label": "Weed Processing License"
           }
       ]
   }
   ```

   Voeg de volgende SQL-query toe om de licenties in de database in te voegen:
   ```sql
   INSERT INTO `licenses` (`type`, `label`) VALUES
       ('bike', 'Motor Theorie'),
       ('truck', 'Vrachtwagen Theorie');
   ```

3. **Theorie Catogorieën toevoegen aan de config:**

In de [`config.lua`](config.lua)  zijn de volgende opties toegevoegd voor de verschillende theorie-examens:

```lua
Config.TheoryTestCategories = {
    dmv = {
        price = 500,        -- Kosten voor het auto theorie-examen
        label = "Auto Theorie",
        questionsRequired = 2  -- Aantal vragen dat correct beantwoord moet worden
    },
    boat = {
        price = 750,        -- Kosten voor het vaarbewijs theorie-examen
        label = "Vaarbewijs Theorie",
        questionsRequired = 2
    },
    bike = {
        price = 600,        -- Kosten voor het motor theorie-examen
        label = "Motor Theorie",
        questionsRequired = 2
    },
    truck = {
        price = 1000,       -- Kosten voor het vrachtwagen theorie-examen
        label = "Vrachtwagen Theorie",
        questionsRequired = 2
    }
}
```

Vergeet dit niet toe te voegen! In standaard ESX is het autotheorie examen DMV genoemd, check of dit ook zo bij 5H is!

4. **Client Functies Aanpassen:**

In [`client/main.lua`](client/main.lua) moet de `StartTheoryTest` functie worden aangepast om verschillende types examens te ondersteunen:

Oude Functie:
```lua
function StartTheoryTest()
	CurrentTest = 'theory'

	SendNUIMessage({
		openQuestion = true
	})

	ESX.SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)


end
```

Nieuwe Functie:
```lua
function StartTheoryTest(type)
    CurrentTest = 'theory'
    CurrentTestType = type

    SendNUIMessage({
        openQuestion = true,
        testType = type -- type vragen (auto, vrachtwagen, motor etc.)
    })
    
    -- Start tablet animatie
    exports["rpemotes"]:EmoteCommandStart("tablet2")
    
    ESX.SetTimeout(200, function()
        SetNuiFocus(true, true)
    end)
end
```

Deze aanpassing:
- Voegt ondersteuning toe voor verschillende types theorie-examens
- Slaat het type examen op in `CurrentTestType`
- Stuurt het type examen door naar de NUI interface
- Maakt het mogelijk om verschillende vragensets te tonen per examen type

In [`client/main.lua`](client/main.lua) moet ook de `StopTheoryTest` functie worden aangepast om de juiste licentie toe te voegen op basis van het examen type:

Oude Functie:
```lua
function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage({
		openQuestion = false
	})

	SetNuiFocus(false)

	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', 'dmv')
		ESX.ShowNotification(TranslateCap('passed_test'))
	else
		ESX.ShowNotification(TranslateCap('failed_test'))
	end
end
```

Nieuwe Functie:
```lua
function StopTheoryTest(success)
    CurrentTest = nil

    -- Stop tablet animatie
    exports["rpemotes"]:EmoteCancel()

    SendNUIMessage({
        openQuestion = false
    })

    SetNuiFocus(false, false)

    if success then
        TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
        ESX.ShowNotification(TranslateCap('passed_test'))
        -- Speel success animatie als laatste
        exports["rpemotes"]:EmoteCommandStart("cheer")
    else
        ESX.ShowNotification(TranslateCap('failed_test')) 
        -- Speel fail animatie als laatste
        exports["rpemotes"]:EmoteCommandStart("damn")
    end
end
```

Deze aanpassing:
- Voegt de juiste licentie toe op basis van het examen type (`CurrentTestType`)

In [`client/main.lua`](client/main.lua) moet ook de `OpenDMVSchoolMenu` functie worden aangepast om ook de nieuwe theorie examens toe te voegen aan het menu. Let op! in het geval van 5H is het esx_contextmenu wss het 5h_menu
Oude Functie:
```lua
function OpenDMVSchoolMenu()
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	local elements = {
		{unselectable = true, icon = "fas fa-car", title = TranslateCap("driving_school")}
	}

	if not ownedLicenses['dmv'] then
		elements[#elements+1] = {
			icon = "fas fa-car",
			title = (('%s: <span style="color:green;">%s</span>'):format(TranslateCap('theory_test'), TranslateCap('school_item', ESX.Math.GroupDigits(Config.Prices['dmv'])))),
			value = "theory_test"
		}
	end

	if ownedLicenses['dmv'] then
		if not ownedLicenses['drive'] then
			elements[#elements+1] = {
				icon = "fas fa-car",
				title = (('%s: <span style="color:green;">%s</span>'):format(TranslateCap('road_test_car'), TranslateCap('school_item', ESX.Math.GroupDigits(Config.Prices['drive'])))),
				value = "drive_test",
				type = "drive"
			}
		end

		if not ownedLicenses['drive_bike'] then
			elements[#elements+1] = {
				icon = "fas fa-car",
				title = (('%s: <span style="color:green;">%s</span>'):format(TranslateCap('road_test_bike'), TranslateCap('school_item', ESX.Math.GroupDigits(Config.Prices['drive_bike'])))),
				value = "drive_test",
				type = "drive_bike"
			}
		end

		if not ownedLicenses['drive_truck'] then
			elements[#elements+1] = {
				icon = "fas fa-car",
				title = (('%s: <span style="color:green;">%s</span>'):format(TranslateCap('road_test_truck'), TranslateCap('school_item', ESX.Math.GroupDigits(Config.Prices['drive_truck'])))),
				value = "drive_test",
				type = "drive_truck"
			}
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		if element.value == "theory_test" then
			ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
				if haveMoney then
					ESX.CloseContext()
					StartTheoryTest()
				else
					ESX.ShowNotification(TranslateCap('not_enough_money'))
				end
			end, 'dmv')
		elseif element.value == "drive_test" then
			ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
				if haveMoney then
					ESX.CloseContext()
					StartDriveTest(element.type)
				else
					ESX.ShowNotification(TranslateCap('not_enough_money'))
				end
			end, element.type)
		end
	end, function(menu)
		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = TranslateCap('press_open_menu')
		CurrentActionData = {}
	end)
end
```

Nieuwe Functie:
```lua
function OpenDMVSchoolMenu()
    local ownedLicenses = {}

    for i=1, #Licenses, 1 do
        ownedLicenses[Licenses[i].type] = true
    end

    local elements = {
        {unselectable = true, icon = "fas fa-car", title = TranslateCap("driving_school")}
    }

    -- Voeg de theorie testen van de config toe
    for type, data in pairs(Config.TheoryTestCategories) do
        if not ownedLicenses[type] then
            elements[#elements+1] = {
                icon = "fas fa-book",
                title = (('%s: <span style="color:green;">%s</span>'):format(data.label, TranslateCap('school_item', ESX.Math.GroupDigits(data.price)))),
                value = "theory_test",
                testType = type
            }
        end
    end
    -- Koppel theorie licenties aan praktijk licenties
    local theoryToPractical = {
        dmv = 'drive',      -- Auto theorie -> Auto praktijk
        bike = 'drive_bike', -- Motor theorie -> Motor praktijk
        truck = 'drive_truck' -- Vrachtwagen theorie -> Vrachtwagen praktijk
    }

    -- Voeg praktijkexamens alleen toe als de speler de bijbehorende theorie licentie heeft
    for theoryType, practicalType in pairs(theoryToPractical) do
        if ownedLicenses[theoryType] and not ownedLicenses[practicalType] then
            elements[#elements+1] = {
                icon = "fas fa-car",
                title = (('%s: <span style="color:green;">%s</span>'):format(
                    TranslateCap('road_test_' .. practicalType), 
                    TranslateCap('school_item', ESX.Math.GroupDigits(Config.Prices[practicalType]))
                )),
                value = "drive_test",
                type = practicalType
            }
        end
    end

    ESX.OpenContext("right", elements, function(menu,element)
        if element.value == "theory_test" then
            ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
                if haveMoney then
                    ESX.CloseContext()
                    StartTheoryTest(element.testType)
                else
                    ESX.ShowNotification(TranslateCap('not_enough_money'))
                end
            end, element.testType)
        elseif element.value == "drive_test" then
            ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
                if haveMoney then
                    ESX.CloseContext()
                    StartDriveTest(element.type)
                else
                    ESX.ShowNotification(TranslateCap('not_enough_money'))
                end
            end, element.type)
        end
    end, function(menu)
        CurrentAction     = 'dmvschool_menu'
        CurrentActionMsg  = TranslateCap('press_open_menu')
        CurrentActionData = {}
    end)
end
```
5. **Server Functies Aanpassen:**
de inhoud van de [`server/main.lua`](server/main.lua) is best wel weinig laten we hierdoor ook de volledige inhoud copy pasten

Oude inhoud:
```lua
ESX.RegisterServerCallback('esx_dmvschool:canYouPay', function(source, cb, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.Prices[type] then
		xPlayer.removeMoney(Config.Prices[type], "DMV Purchase")
		TriggerClientEvent('esx:showNotification', source, TranslateCap('you_paid', Config.Prices[type]))
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

	TriggerEvent('esx_license:addLicense', source, type, function()
		TriggerEvent('esx_license:getLicenses', source, function(licenses)
			TriggerClientEvent('esx_dmvschool:loadLicenses', source, licenses)
		end)
	end)
end)
```
Nieuwe inhoud:
```lua
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
```

Deze aanpassing:
- Haalt de prijs direct uit de config 
- Voegt een mapping systeem toe voor licentie type