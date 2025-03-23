return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			adapters = {
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						schema = {
							model = {
								default = function()
									return "gpt-4o"
								end,
							},
						},
					})
				end,
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							num_ctx = {
								default = 20000,
							},
						},
					})
				end,
			},
			strategies = {
				chat = {
					adapter = "openai",
				},
				inline = {
					adapter = "openai",
				},
				cmd = {
					adapter = "openai",
				},
			},
		},
		init = function()
			vim.keymap.set(
				{ "n", "v" },
				"<leader>ca",
				"<cmd>CodeCompanionActions<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set({ "n", "v" }, "<leader>cp", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })
			vim.keymap.set(
				{ "n", "v" },
				"<leader>cc",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<leader>ga",
				"<cmd>CodeCompanionChat Add<cr>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
