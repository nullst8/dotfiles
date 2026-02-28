vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	callback = function()
		if vim.bo.filetype == "" then
			vim.cmd("filetype detect")
		end
	end,
})
