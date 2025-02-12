vim.g.mapleader = " "

-- Clipboard
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Copy to system clipboard" })

-- Keep screen centered during vertical movement
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Keep screen centered during Ctrl+d movement" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Keep screen centered during Ctrl+u movement" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Keep screen centered during next search movement" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Keep screen centered during previous search movement" })

-- Because ThePrimeagen said so
vim.keymap.set("n", "Q", "<nop>")
