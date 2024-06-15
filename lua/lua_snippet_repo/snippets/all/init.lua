local stype = require("lua_snippet_repo.snippets.snippet_types")

local M = {}

local default_opts = {
  use_treesitter = true,
}

M.setup = function(opts)
  opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  stype.ls.config.setup({ enable_autosnippets = true })

  for _,snip in ipairs(require("base_number_conversions")) do
    stype.ls.add_snippets("all", snip)
  end

  for _,snip in ipairs(require("common_snippets")) do
    stype.ls.add_snippets("all", snip)
  end
end

return M
