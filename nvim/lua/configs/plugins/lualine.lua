return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")

		lualine.setup({
			sections = {
				lualine_a = { "mode" },
				lualine_b = { { "filename", path = 1 } },
				lualine_c = { "branch", "diff" },
				lualine_x = { "diagnostics" },
				lualine_y = { "fileformat", "filetype" },
				lualine_z = { "location" },
			},
		})
	end,
}
