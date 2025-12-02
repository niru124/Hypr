return {
    entry = function()
        local items = {
            { name = "Test Command 1", value = "echo 'Hello from Test 1'" },
            { name = "Test Command 2", value = "echo 'Hello from Test 2'" },
        }

        local selected, event = ya.select({
            title = "TEST MENU - If you see this, the plugin is working!",
            items = items,
            position = { "hovered", y = 1, w = 50 },
        })

        if event == 1 and selected then
            ya.manager_emit("shell", {
                selected.value,
                block = true,
                orphan = true,
                confirm = true,
            })
        end
    end,
}
