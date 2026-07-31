return {
	{
		"D0nw0r/dark2026.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("dark2026")

			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
			vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		config = function()
			require("gruvbox").setup({
				contrast = "hard",
			})
		end,
	},
}
