return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local mason_config = require("mason-lspconfig")

			mason_config.setup({
				handlers = {
					function(server_name)
						local config = { capabilities = {} }
						config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
						require("lspconfig")[server_name].setup(config)
					end,
				},
			})
		end,
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"nvim-tree/nvim-web-devicons",
			"onsails/lspkind.nvim",
			"fang2hou/blink-copilot",
		},
		version = "*",
		opts = {
			keymap = { preset = "default" },
			appearance = {
				nerd_font_variant = "normal",
			},
			sources = {
				default = { "lsp", "copilot", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						name = "lsp",
						enabled = true,
						module = "blink.cmp.sources.lsp",
						score_offset = 1000,
					},
					path = {
						name = "path",
						enabled = true,
						module = "blink.cmp.sources.path",
						score_offset = 950,
					},
					snippets = {
						name = "snippets",
						enabled = true,
						module = "blink.cmp.sources.snippets",
						score_offset = 900,
					},
					buffer = {
						name = "buffer",
						enabled = true,
						module = "blink.cmp.sources.buffer",
						score_offset = 850,
						min_keyword_length = 3,
					},
					copilot = {
						name = "copilot",
						enabled = true,
						module = "blink-copilot",
						score_offset = 0,
						async = true,
						opts = {
							max_completions = 1,
						},
					},
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
			snippets = { preset = "default" },
			signature = { enabled = true, window = { border = "single" } },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "single" } },
				ghost_text = { enabled = true },
				menu = {
					border = "single",
					draw = {
						columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local icon = ctx.kind_icon
									if vim.tbl_contains({ "path", "copilot" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbolic(ctx.kind, {
											mode = "symbol",
										})
									end

									return icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									local hl = ctx.kind_hl
									if vim.tbl_contains({ "path", "copilot" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end

									return hl
								end,
							},
							kind = {
								highlight = function(ctx)
									local hl = ctx.kind_hl
									if vim.tbl_contains({ "path", "copilot" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end

									return hl
								end,
							},
						},
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		event = { "BufReadPre", "BufNewFile" },
		init = function()
			vim.opt.signcolumn = "yes"
		end,
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP Actions",
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
					vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
					vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
					-- vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
					-- vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
					vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					vim.keymap.set("n", "<C-.>", "<cmd>lua vim.lsp.buf.code_actions()<cr>", opts)
				end,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local id = vim.tbl_get(event, "data", "client_id")
					local client = id and vim.lsp.get_client_by_id(id)
					if client == nil then
						return
					end

					-- Disable semantic highlights
					client.server_capabilities.semanticTokensProvider = nil
				end,
			})
		end,
	},
}
