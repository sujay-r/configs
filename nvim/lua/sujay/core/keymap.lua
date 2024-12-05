vim.g.mapleader = " "

-- Move highlighted lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", {desc = "Move selected lines up (in visual mode)"})
vim.keymap.set("v", "K", ":m '>-1<CR>gv=gv", {desc = "Move selected lines down (in visual mode)"})

-- Keep screen centered during movement
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Keep screen centered during Ctrl+d movement"})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Keep screen centered during Ctrl+u movement"})
vim.keymap.set("n", "n", "nzzzv", {desc = "Keep screen centered during next search movement"})
vim.keymap.set("n", "N", "Nzzzv", {desc = "Keep screen centered during previous search movement"})

-- Clipboard
vim.keymap.set("n", "<leader>y", '"+y', {desc = "Copy to system clipboard"})
vim.keymap.set("v", "<leader>y", '"+y', {desc = "Copy to system clipboard"})
vim.keymap.set("n", "<leader>Y", '"+Y', {desc = "Copy to system clipboard"})

-- Window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", {desc = "Split window vertically"})
vim.keymap.set("n", "<leader>sh", "<C-w>s", {desc = "Split window horizontally"})
vim.keymap.set("n", "<leader>se", "<C-w>=", {desc = "Make window splits equal size"})
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", {desc = "Close current window split"})
vim.keymap.set("n", "<C-h>", "", { noremap = true })  -- Clear default map for harpoon
-- Movement across windows
vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")


-- nvim-tree
vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer"})
vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file"})
vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer"})
vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer"})

-- Because ThePrimeagen said so
vim.keymap.set("n", "Q", "<nop>")
