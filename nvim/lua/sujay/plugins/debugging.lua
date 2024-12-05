return {

}
-- return {
--     "mfussenegger/nvim-dap",
--     dependencies = {
--         "rcarriga/nvim-dap-ui",
--         "mfussenegger/nvim-dap-python",
--     }
--     config = function()
--         local dap = require("dap")
--         local dapui = require("dapui")
--
--         dap.listeners.before.attach.dapui_config = function()
--           dapui.open()
--         end
--         dap.listeners.before.launch.dapui_config = function()
--           dapui.open()
--         end
--         dap.listeners.before.event_terminated.dapui_config = function()
--           dapui.close()
--         end
--         dap.listeners.before.event_exited.dapui_config = function()
--           dapui.close()
--         end
--
--         vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {})
--         vim.keymap.set("n", "<leader>dc", dap.continue, {})
--     end,
-- }
