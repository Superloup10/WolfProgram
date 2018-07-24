local component = require("component")
local side = require("sides")
local robot = require("robot")
local inventory = component.inventory_controller;

function drop(endSlot)
    for i = 1, endSlot do
        local slot = robot.select(i)
        local item = inventory.getStackInInternalSlot(slot)

        if item then
            inventory.dropIntoSlot(side.bottom, slot, item.size)
        else
            print("Slot " .. slot .. " is empty")
        end
    end
    robot.select(1)
end
return drop