-- Neovim 0.12's default `filetypedetect` autocmd can lose its `setf` on the
-- very first BufNewFile because lazy.nvim synchronously loads blink.cmp and
-- nvim-lspconfig (both triggered by that same event) mid-autocmd, racing the
-- runtime detection. Subsequent files are fine. Defer the check with
-- vim.schedule so it runs once the event and the plugin load have settled, and
-- only act when detection did not happen (empty filetype).
local group = vim.api.nvim_create_augroup("nullst8.FiletypeGuarantee", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = group,
  pattern = "*",
  callback = function(ev)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then
        return
      end
      if vim.bo[ev.buf].filetype ~= "" then
        return
      end
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if name == "" then
        return
      end
      local ft, on_detect = vim.filetype.match({ buf = ev.buf, filename = name })
      if ft then
        if on_detect then
          on_detect(ev.buf)
        end
        vim.bo[ev.buf].filetype = ft
      end
    end)
  end,
})
