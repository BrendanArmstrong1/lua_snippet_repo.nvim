local stype = require("lua_snippet_repo.snippets.snippet_types")

local M = {
  stype.s(
    "curtime",
    stype.f(function()
      return os.date("%D - %H:%M")
    end)
  ),
}

return M
