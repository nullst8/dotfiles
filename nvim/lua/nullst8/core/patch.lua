-- Monkey patch for deprecated client.supports_method
-- Redirects old `client.supports_method(...)` calls to `client:supports_method(...)`

local mt = getmetatable(vim.lsp.protocol.Client or {})
if mt and not mt.__patched_supports_method then
	local orig_index = mt.__index
	mt.__index = function(tbl, key)
		if key == "supports_method" then
			return function(c, ...)
				return c:supports_method(...)
			end
		end
		if type(orig_index) == "function" then
			return orig_index(tbl, key)
		else
			return orig_index[key]
		end
	end
	mt.__patched_supports_method = true
end
