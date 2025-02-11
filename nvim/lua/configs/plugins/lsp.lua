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
						require("lspconfig")[server_name].setup({})
					end,
				},
			})
		end,
	},
	{ "hrsh7th/cmp-nvim-lsp" },
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		init = function()
			vim.opt.signcolumn = "yes"
		end,
		config = function()
			local lspconfig_defaults = require("lspconfig").util.default_config
			lspconfig_defaults.capabilities = vim.tbl_deep_extend(
				"force",
				lspconfig_defaults.capabilities,
				require("cmp_nvim_lsp").default_capabilities()
			)

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
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		run = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
	},
	{ "saadparwaiz1/cmp_luasnip" },
	{ "hrsh7th/cmp-buffer" },
	{ "onsails/lspkind.nvim" },
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter" },
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				-- Autocomplete sources
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "luasnip" },
				},

				-- Snippet engine configuration
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},

				-- Autocomplete keyboard mappings
				mapping = cmp.mapping.preset.insert({
					-- Jump to next snippet placeholder
					["<C-f>"] = cmp.mapping(function(fallback)
						local luasnip = require("luasnip")
						if luasnip.locally_jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
					-- Jump to previous snippet placeholder
					["<C-b>"] = cmp.mapping(function(fallback)
						local luasnip = require("luasnip")
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				-- Autocomplete formatting options
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = {
							menu = 50,
							abbr = 50,
						},
						ellipsis_char = "...",
						show_labelDetails = true,
					}),
				},
			})
		end,
	},
}
