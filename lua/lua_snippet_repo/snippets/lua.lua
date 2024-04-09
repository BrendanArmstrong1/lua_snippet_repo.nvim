local ls = require("luasnip")
local re = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local sn = ls.snippet_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")
local types = require("luasnip.util.types")

return {
  s(
    "req",
    fmt([[local {} = require("{}")]], {
      f(function(import_name)
        local parts = vim.split(import_name[1][1], ".", true)
        return parts[#parts] or ""
      end, { 1 }),
      i(1),
    })
  ),
  s(
    "escaped_text",
    fmta(
      [[
local escaped_characters = {
  ["%("] = "\\(",
  ["%)"] = "\\)",
  ["%{"] = "\\{",
  ["%}"] = "\\}",
}
local escaped_text = <text>
for i, v in pairs(escaped_characters) do
  escaped_text = string.gsub(escaped_text, i, v)
end
<>
  ]],
      {
        text = i(1, "target_string"),
        i(2,""),
      }
    )
  ),
  s("snippet_tags",fmt([[
local ls = require("luasnip")
local re = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local sn = ls.snippet_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")
local types = require("luasnip.util.types")
  ]],{})),
}
