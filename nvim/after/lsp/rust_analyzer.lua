return {
	settings = {
		["rust-analyzer"] = {
			check = { command = "check" },
			diagnostics = {
				enable = true,
			},
			cargo = {
				loadOutDirsFromCheck = true,
			},
			files = {
				excludeDirs = { "target", "node_modules" },
			},
		},
	},
}
