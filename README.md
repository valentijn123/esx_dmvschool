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
    CurrentTestType = type  -- Slaat het type examen op (dmv, bike, truck, boat)

    SendNUIMessage({
        openQuestion = true,
        testType = type     -- Stuurt type door naar NUI interface
    })
    
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

    SendNUIMessage({
        openQuestion = false
    })

    SetNuiFocus(false)

    if success then
        -- License toevoegen gebaseerd op categorie
        TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
        ESX.ShowNotification(TranslateCap('passed_test'))
    else
        ESX.ShowNotification(TranslateCap('failed_test'))
    end
end
```

Deze aanpassing:
- Voegt de juiste licentie toe op basis van het examen type (`CurrentTestType`)