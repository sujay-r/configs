return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		lazy = vim.fn.argc(-1) == 0,
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				auto_install = { enable = false },
				highlight = { enable = true },
				indent = { enable = true },
				ensure_installed = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "python" },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-Space>",
						node_incremental = "<C-Space>",
						node_decremental = "s",
						scope_incremental = "<Tab>",
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["ab"] = "@block.outer",
							["ib"] = "@block.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = { query = "@function.outer", desc = "Next function start" },
							["]c"] = { query = "@class.outer", desc = "Next class start" },
							["]o"] = { query = "@loop.*", desc = "Next loop start" },
						},
						goto_next_end = {
							["]F"] = { query = "@function.outer", desc = "Next function end" },
							["]C"] = { query = "@class.outer", desc = "Next class end" },
							["]O"] = { query = "@loop.*", desc = "Next loop end" },
						},
						goto_previous_start = {
							["[f"] = { query = "@function.outer", desc = "Next function start" },
							["[c"] = { query = "@class.outer", desc = "Next class start" },
							["[O"] = { query = "@loop.*", desc = "Previous loop start" },
						},
						goto_previous_end = {
							["[F"] = { query = "@function.outer", desc = "Previous function end" },
							["[C"] = { query = "@class.outer", desc = "Previous class end" },
							["[O"] = { query = "@loop.*", desc = "Previous loop end" },
						},
						goto_next = {
							["]d"] = { query = "@conditional.outer", desc = "Next conditional" },
							["]b"] = { query = "@block.*", desc = "Next block" },
						},
						goto_previous = {
							["[d"] = { query = "@conditional.outer", desc = "Previous conditional" },
							["[b"] = { query = "@block.*", desc = "Previous block" },
						},
					},
					swap = {
						enable = true,
						swap_next = { ["<leader>na"] = "@parameter.inner" }, -- Swap argument forward
						swap_previous = { ["<leader>pa"] = "@parameter.inner" }, -- Swap argument backward
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				max_lines = 3,
				multiline_threshold = 1,
			})
		end,
	},
}
