local CurrentAction     = nil
local CurrentActionMsg  = nil
local CurrentActionData = nil
local Licenses          = {}
local CurrentTest       = nil
local CurrentTestType   = nil
local CurrentVehicle    = nil
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint    = -1
local CurrentBlip       = nil
local CurrentZoneType   = nil
local LastVehicleHealth = nil
local failedTest = false
local isDev = false -- Set this to true when testing with dev server

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

function StartTheoryTest(type)
    CurrentTest = 'theory'
    CurrentTestType = type

    SendNUIMessage({
        openQuestion = true,
        testType = type -- This will determine which question set to use
    })
    
    ESX.SetTimeout(200, function()
        SetNuiFocus(true, true)
    end)
end

function StopTheoryTest(success)
    CurrentTest = nil

    SendNUIMessage({
        openQuestion = false
    })

    SetNuiFocus(false)

    if success then
        -- Add license based on test type
        TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
        ESX.ShowNotification(TranslateCap('passed_test'))
    else
        ESX.ShowNotification(TranslateCap('failed_test'))
    end
end

function StartDriveTest(type)
	ESX.Game.SpawnVehicle(Config.VehicleModels[type], vector3(Config.Zones.VehicleSpawnPoint.Pos.x, Config.Zones.VehicleSpawnPoint.Pos.y, Config.Zones.VehicleSpawnPoint.Pos.z), Config.Zones.VehicleSpawnPoint.Pos.h, function(vehicle)
		CurrentTest       = 'drive'
		CurrentTestType   = type
		CurrentCheckPoint = 0
		LastCheckPoint    = -1
		CurrentZoneType   = 'residence'
		DriveErrors       = 0
		IsAboveSpeedLimit = false
		CurrentVehicle    = vehicle
		LastVehicleHealth = GetEntityHealth(vehicle)
		failedTest = false

		local playerPed   = PlayerPedId()
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleFuelLevel(vehicle, 100.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	end)
end

function StopDriveTest(success)
	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
		ESX.ShowNotification(TranslateCap('passed_test'))
		ESX.ShowNotification(TranslateCap('driving_test_complete'))
	else
		ESX.ShowNotification(TranslateCap('failed_test'))
	end

	CurrentTest     = nil
	CurrentTestType = nil
end

function SetCurrentZoneType(type)
CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	local elements = {
		{unselectable = true, icon = "fas fa-car", title = TranslateCap("driving_school")}
	}

	-- Add theory tests
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
					-- Hier geven we het juiste testType mee
					StartTheoryTest(element.testType)
				else
					ESX.ShowNotification(TranslateCap('not_enough_money'))
				end
			end, element.testType)  -- Pass correct type to server callback
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

RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({
		openSection = 'question'
	})

	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

AddEventHandler('esx_dmvschool:hasEnteredMarker', function(zone)
	if zone == 'DMVSchool' then
		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = TranslateCap('press_open_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_dmvschool:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.CloseContext()
end)

RegisterNetEvent('esx_dmvschool:loadLicenses')
AddEventHandler('esx_dmvschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

-- Create Blips
CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)

	SetBlipSprite (blip, 408)
	SetBlipColour (blip, 0)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.2)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(TranslateCap('driving_school_blip'))
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
CreateThread(function()
	while true do
		local sleep = 1500
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		for k,v in pairs(Config.Zones) do
			local Pos = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
			if(v.Type ~= -1 and #(coords - Pos) < Config.DrawDistance) then
				sleep = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end

		if CurrentTest == 'theory' then
			
			sleep = 0
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisablePlayerFiring(playerPed, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		end

		if CurrentTest == 'drive' then
			sleep = 0
			local nextCheckPoint = CurrentCheckPoint + 1

			if Config.CheckPoints[nextCheckPoint] == nil then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end

				CurrentTest = nil
				StopDriveTest(DriveErrors < Config.MaxErrors)
			else
				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end

					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)

					LastCheckPoint = CurrentCheckPoint
				end
            
				local Pos = vector3(Config.CheckPoints[nextCheckPoint].Pos.x,Config.CheckPoints[nextCheckPoint].Pos.y,Config.CheckPoints[nextCheckPoint].Pos.z)
				local distance = #(coords - Pos)
            
				if distance <= Config.DrawDistance then
					DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end
			end
		end

		if CurrentAction then
			sleep = 0
			ESX.ShowHelpNotification(CurrentActionMsg)

			if (IsControlJustReleased(0, 38)) and (CurrentAction == 'dmvschool_menu') then
				OpenDMVSchoolMenu()
				CurrentAction = nil
			end
		end
		
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			local Pos = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
			if(#(coords - Pos) < v.Size.x) then
				sleep = 0
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_dmvschool:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_dmvschool:hasExitedMarker', LastZone)
		end
		Wait(sleep)
	end
end)


function TestFailedGoToLastCheckPoint()
	CurrentCheckPoint = #Config.CheckPoints - 1
	failedTest = true
end

-- Speed / Damage control
CreateThread(function()
	while true do
		local sleep = 1500
		if CurrentTest == 'drive' then
			sleep = 0
			local playerPed = PlayerPedId()
			
			if IsPedInAnyVehicle(playerPed, false) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				local speed = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
				local health = GetEntityHealth(vehicle)

				-- Speed check
				for k, v in pairs(Config.SpeedLimits) do

					if CurrentZoneType == k and speed > v then
						DriveErrors += 1

						if DriveErrors <= Config.MaxErrors then
							ESX.ShowNotification(TranslateCap('driving_too_fast', v))
							ESX.ShowNotification(TranslateCap('errors', DriveErrors, Config.MaxErrors))
						end

						sleep = (Config.SpeedingErrorDelay < 5000) and 5000 or Config.SpeedingErrorDelay
					end
				end

				-- Vehicle damage check
				if health < LastVehicleHealth then
					DriveErrors += 1
					if DriveErrors <= Config.MaxErrors then
						ESX.ShowNotification(TranslateCap('you_damaged_veh'))
						ESX.ShowNotification(TranslateCap('errors', DriveErrors, Config.MaxErrors))
					end
					
					LastVehicleHealth = health
					sleep = 1500
				end

				if DriveErrors > Config.MaxErrors then
					ESX.ShowNotification(TranslateCap('test_failed_go_to_start_point'))
					if not failedTest then
						TestFailedGoToLastCheckPoint()
					end
					sleep = 5000
				end
			end
		end
		Wait(sleep)
	end
end)

-- Add this near your other command registrations
-- Replace the existing dmv_debug command with this:
RegisterCommand('dmv_debug', function(source, args)
    -- Remove the debug check to always allow the command
    if args[1] == 'open' then
        SetNuiFocus(true, true)
        SendNUIMessage({
            openQuestion = true
        })
        -- Set visible to true in the NUI
        visible = true
    elseif args[1] == 'close' then
        SetNuiFocus(false, false)
        SendNUIMessage({
            openQuestion = false
        })
        -- Set visible to false in the NUI
        visible = false
    end
end, false)

