return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				java = { "google-java-format" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},
		})
	end,
}
