return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},

	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		mason.setup()
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"clangd",
				"ts_ls",
			},
		})

		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.diagnostic.config({
			virtual_text = true, -- show errors inline
			signs = true, -- show in sign column
			underline = true,
			update_in_insert = false, -- don’t spam during typing
		})
	end,
}
