return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},

	config = function()
		require("nvim-treesitter.configs").setup({
			indent = { enable = true },
			highlight = { enable = true },
			autotag = { enable = true },

			ensure_installed = {
				"vimdoc",
				"javascript",
				"typescript",
				"c",
				"lua",
				"rust",
				"jsdoc",
				"bash",
			},
		})
	end,
	ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact" }, -- you can list more if needed
}
