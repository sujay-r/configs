return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		explorer = {
			enabled = true,
			replace_netrw = true,
		},
		picker = {
			enabled = true,
			sources = {
				files = {
					layout = {
						preset = "ivy",
						position = "bottom",
					},
					matcher = {
						cwd_bonus = true,
						frecency = true,
					},
				},
				diagnostics_buffer = {
					layout = {
						preset = "select",
					},
				},
				lsp_symbols = {
					layout = {
						preset = "sidebar",
						position = "right",
					},
				},
			},
		},
		indent = { enabled = true },
		git = { enabled = true },
		lazygit = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		-- File pickers
		{
			"<leader>fe",
			function()
				Snacks.explorer()
			end,
			desc = "File explorer",
		},
		{
			"<leader>fo",
			function()
				Snacks.picker.files()
			end,
			desc = "Find files",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},

		-- Diagnostics
		{
			"<leader>db",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Diagnostics for current buffer",
		},

		-- LSP
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			desc = "LSP references for symbol",
		},
		{
			"gi",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "LSP implementations",
		},
		{
			"<leader>cs",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP symbols",
		},
	},
}
