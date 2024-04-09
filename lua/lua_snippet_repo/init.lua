local M = {}

local luasnip_snippets_path = "lua/lua_snippet_repo/snippets"

function M.load_snippets()
  return vim.api.nvim_get_runtime_file(luasnip_snippets_path, true)
end

return M
