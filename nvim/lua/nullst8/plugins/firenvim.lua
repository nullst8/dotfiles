return {
	-- Other plugins...
	{
		"glacambre/firenvim",
		-- Lazy load Firenvim: only load when triggered by the browser
		lazy = false, -- Firenvim needs to be loaded at startup to work with the browser
		build = function()
			-- Install the Firenvim browser extension script
			vim.fn["firenvim#install"](0)
		end,
		config = function()
			-- Option 1: Inline the firenvim.lua configuration
			vim.g.firenvim_config = {
				globalSettings = {
					alt = "all",
				},
				localSettings = {
					[".*"] = {
						takeover = "once",
						priority = 0,
					},
					["https://www.google.com/"] = {
						takeover = "never",
					},
					["https://www.reddit.com/"] = {
						takeover = "always",
					},
				},
			}
			-- Option 2: Require the external firenvim.lua file
			-- require("firenvim")
		end,
	},
	-- Other plugins...
}
