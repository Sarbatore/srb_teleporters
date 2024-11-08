local prompt = 0

AddEventHandler("onResourceStop", function(resource)
    if (GetCurrentResourceName() ~= resource) then return end

    PromptDelete(prompt)
end)

---Return whether the player is near a teleporter
---@param teleporter table
---@return boolean
local function IsNearTeleporter(teleporter)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - teleporter.fromCoords)

    return distance <= teleporter.distanceToShow
end

---Return the nearest teleporter
---@return table
local function GetNearestTeleporter()
    for _, teleporter in ipairs(Config.teleporters) do
        if (IsNearTeleporter(teleporter)) then
            return teleporter
        end
    end
    return nil
end

Citizen.CreateThread(function()
    local promptGroup = GetRandomIntInRange(0, 0xffffff)
    prompt = PromptRegisterBegin()
        UiPromptSetControlAction(prompt, Config.controlKey)
        UiPromptSetText(prompt, VarString(10, "LITERAL_STRING", ""))
        UiPromptSetEnabled(prompt, true)
        UiPromptSetVisible(prompt, true)
        UiPromptSetStandardMode(prompt, true)
        UiPromptSetGroup(prompt, promptGroup, 0)
    UiPromptRegisterEnd(prompt)

    local nearestTeleporter = nil

    local sleep = true
    while true do
        if (sleep) then
            Citizen.Wait(1000)
        else
            Citizen.Wait(0)
        end

        sleep = true

        local playerPed = PlayerPedId()

        -- Reset nearest teleporter if too far
        if (nearestTeleporter) and (not IsNearTeleporter(nearestTeleporter)) then
            nearestTeleporter = nil
        end

        -- Update prompt if near teleporter
        if (not IsEntityDead(playerPed)) then
            nearestTeleporter = GetNearestTeleporter()
            if (nearestTeleporter) then
                PromptSetText(prompt, VarString(10, "LITERAL_STRING", nearestTeleporter.promptName))
            end
        end

        -- Show prompt if near teleporter
        if (nearestTeleporter) then
            sleep = false

            PromptSetActiveGroupThisFrame(promptGroup, VarString(10, "LITERAL_STRING", nearestTeleporter.press))
            if (PromptIsJustPressed(prompt)) then
                SetEntityCoordsAndHeading(playerPed, nearestTeleporter.toCoords)
            end
        end
    end
end)
