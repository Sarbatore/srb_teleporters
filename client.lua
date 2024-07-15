Citizen.CreateThread(function()
    local promptGroup = UipromptGroup:new("")
    local prompt = Uiprompt:new(Config.teleportersKey, "", promptGroup)
    :setOnControlJustPressed(function(p, playerPed, coords)
        SetEntityCoordsAndHeading(playerPed, coords.x, coords.y, coords.z, coords.h)
    end)

    local nearestTeleporter = nil

    local sleep = true
    while true do
        if (sleep) then
            Citizen.Wait(1000)
        else
            Citizen.Wait(5)
        end

        local playerPed = PlayerPedId()

        -- Reset nearest teleporter if too far
        if (nearestTeleporter) and (#(GetEntityCoords(playerPed) - nearestTeleporter.pos) > nearestTeleporter.distanceToShow) then
            nearestTeleporter = nil
        end

        -- Update prompt if near teleporter
        if (not IsEntityDead(playerPed)) then
            if (not nearestTeleporter) then
                for _, v in ipairs(Config.teleporters) do
                    local distance = #(GetEntityCoords(playerPed) - v.pos)
    
                    if (distance <= v.distanceToShow) then
                        promptGroup:setText(v.press)
                        prompt:setText(v.promptName)

                        nearestTeleporter = v
    
                        break
                    end
                end
            end
        end

        -- Show prompt if near teleporter
        if (nearestTeleporter) then
            promptGroup:setActiveThisFrame()
            promptGroup:handleEvents(playerPed, nearestTeleporter.goTo)

            sleep = false
        else
            sleep = true
        end
    end
end)