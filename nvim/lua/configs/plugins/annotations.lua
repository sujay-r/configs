return {
	"danymat/neogen",
	config = true,
	init = function()
		vim.keymap.set(
			"n",
			"<leader>df",
			":lua require('neogen').generate()<CR>",
			{ desc = "Generate docstring for function" }
		)
	end,
}
