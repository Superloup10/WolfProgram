--[[
-- Ce programme ne fonctionne que pour les plantes de 1 bloc de haut
 ]]
local farm = {}
local component = require("component")
local robot = require("robot")
local drop = require("drop")
local tool_restock = require("tool_restock")
local inventory = component.inventory_controller

local PLANT_NAME = "minecraft:potato" -- nom à changer
local SLOT_SEED = 1
local SLOT_TOOL = robot.inventorySize() - 1
local SLOT_DIRT = robot.inventorySize()

function farm.swapSeedSlot(plantName)
    robot.select(SLOT_SEED)
    if robot.count() == 0 then
        for i = 2, robot.inventorySize() - 2 do
            local slotRobot = robot.select(i)
            local item = inventory.getStackInInternalSlot(slotRobot)
            if item and item.name == plantName then
                robot.transferTo(SLOT_SEED)
                break
            end
        end
    end
    robot.select(SLOT_SEED)
end

function farm.isFrontEntity()
    local _, value = robot.detect()
    while value == "entity" do
        os.sleep(1)
        _, value = robot.detect()
    end
end

function farm.processDirt()
    robot.select(SLOT_DIRT)
    local _, value = robot.detectDown()
    if value == "air" then
        robot.down()
        if robot.compareDown() then
            robot.up()
            robot.useDown() -- Laboure le sol
        else
            robot.up()
        end
    end
    robot.select(SLOT_SEED)
end

function farm.plant(plantName)
    farm.swapSeedSlot(plantName)
    farm.processDirt()
    robot.swingDown() -- Casse la plante
    robot.suckDown() -- Aspire tous les items en dessous
    robot.placeDown() -- Fais un clic droit avec une graine
end

function farm.reverseRight()
    for i = 1, 2 do
        robot.forward()
        robot.turnRight()
    end
end

function farm.reverseLeft()
    for i = 1, 2 do
        robot.forward()
        robot.turnLeft()
    end
end

function farm.plantRow(length, plantName) -- Nom de la fonction à changer
    for i = 1, length do
        farm.isFrontEntity()
        robot.forward()
        farm.plant(plantName)
    end
end

function farm.moveToCharger(length)
    if length % 2 ~= 0 then
        robot.turnAround()
        for i = 1, length do
            robot.forward()
        end
    else
        robot.forward()
    end
    robot.turnRight()
    for i = 1, length - 1 do
        robot.forward()
    end
    robot.turnRight()
end

function farm.run(length, width)
    while true do
        tool_restock(SLOT_TOOL)
        for i = 1, width do
            farm.plantRow(length, PLANT_NAME)
            farm.reverseRight()
            farm.plantRow(length, PLANT_NAME)
            farm.reverseLeft()
        end
        farm.moveToCharger(length)
        drop(SLOT_TOOL - 1)
        os.sleep(300) -- Temps en seconde avant de reprendre le cycle
    end
end

return farm