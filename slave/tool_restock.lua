local component = require("component")
local side = require("sides")
local robot = require("robot")
local inventory = component.inventory_controller;

----------------------------------------------------
--           Designed for a single tool           --
----------------------------------------------------
function tool_restock(toolSlot)
    if robot.durability() == nil or robot.durability() == 0 then
        robot.turnLeft()
        robot.select(toolSlot)
        for slot = 1, inventory.getInventorySize(side.front) do
            local item = inventory.getStackInSlot(side.front, slot)
            if item then
                inventory.suckFromSlot(side.front, slot)
                robot.transferTo(toolSlot)
                inventory.equip()
                break
            else
                print("Slot " .. slot .. " is empty")
            end
        end
        robot.turnRight()
        robot.select(1)
    end
end

return tool_restock