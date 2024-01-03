-- CONFIG --
local DecompteTextTitle = nil
local DecompteTextReason = nil

local secondsRemaining = 0
local holdingupTest = false
local hasBeenInitialised = false
local notificationParam = 1

announcestringT = false
lastforT = 5

local volume = 0.5
local sondecompte = 'decompte';

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function Notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
end

RegisterCommand('test', function(source, args, rawCommand)
	TriggerServerEvent('decompte:checkperms', source)
end)

RegisterNetEvent('Decompte:LaunchCommand')
AddEventHandler('Decompte:LaunchCommand', function()
	TriggerServerEvent('decompte:checkperms')
end)

-- lancement de l'alerte evenement
RegisterNetEvent('decompte:ISNOTOK')
AddEventHandler('decompte:ISNOTOK', function(source)
	TriggerEvent("AdminTools_Decompte:sendNotification", notificationParam, "~r~Vous n'avez pas le droit de faire cela !", 0.3)
end)

-- pas de lancement
RegisterNetEvent('decompte:ISOK')
AddEventHandler('decompte:ISOK', function(source)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)
	while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
	if GetOnscreenKeyboardResult() then
		DecompteTextTitle = GetOnscreenKeyboardResult()
		DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 60)
		while UpdateOnscreenKeyboard() == 0 do
			DisableAllControlActions(0)
			Wait(0)
		end
		if GetOnscreenKeyboardResult() then
			DecompteTextReason = GetOnscreenKeyboardResult()
			TriggerEvent('decompte:test', -1)
			TriggerServerEvent('InteractSound_SV:PlayOnAll', sondecompte, volume)
			TriggerEvent("AdminTools_Decompte:sendNotification", notificationParam, "~r~".. DecompteTextTitle.. " \n~w~" .. DecompteTextReason ..".", 2.0)
		end
	end
end)

RegisterNetEvent('decompte:test')
AddEventHandler('decompte:test', function()
	holdingupTest = true
	secondsRemaining = 30
end)


Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(0)
		
		if holdingupTest then
			Citizen.Wait(1000)
			if(secondsRemaining > 0)then
				secondsRemaining = secondsRemaining - 1
			end
		end

	end
end)

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(0)
	  
		if holdingupTest then
			if (secondsRemaining >= 2) then
				DisplayHelpText("~w~Il vous reste ~r~".. secondsRemaining .. " ~w~Secondes.")
			elseif (secondsRemaining == 1) then
				DisplayHelpText("~w~Il vous reste ~r~".. secondsRemaining .. " ~w~Seconde.")
			elseif (secondsRemaining == 0) then
				TriggerEvent('announceT')
				--TriggerEvent("AdminTools_Decompte:sendNotification", notificationParam, "~w~".. DecompteTextReason ..".", 1.0)
				holdingupTest = false
			end
		end
	end
end)

RegisterNetEvent('announceT')
announcestringT = false
AddEventHandler('announceT', function()
	announcestringT = "~w~".. DecompteTextReason .." ."
	PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
	Citizen.Wait(lastforT * 1000)
	announcestringT = false
end)

function InitializeT(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	PushScaleformMovieFunctionParameterString("~r~".. DecompteTextTitle .."")
    PushScaleformMovieFunctionParameterString(announcestringT)
    PopScaleformMovieFunctionVoid()
    return scaleform
end


Citizen.CreateThread(function()
while true do
	Citizen.Wait(0)
    if announcestringT then
		scaleform = InitializeT("mp_big_message_freemode")
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end
end
end)