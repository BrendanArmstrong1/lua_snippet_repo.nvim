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
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

local get_anyhow_presence = function(position)
  return d(position, function()
    local nodes = {}
    table.insert(nodes, t(" "))

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      if line:match("anyhow::Result") then
        table.insert(nodes, t(" -> Result<()> "))
        break
      end
    end
    return sn(nil, c(1, nodes))
  end, {})
end

return {
  -- print snips
  s({ trig = "print" }, fmt([[println!("{{{}}}", {});]], { c(1, { t(":?"), t("") }), i(2) })),
  s({ trig = "format" }, fmt([[format!("{{{}}}", {});]], { c(1, { t(":?"), t("") }), i(2) })),
  -- format

  -- fn snips

  -- Test snips
  s(
    "modtest",
    fmt(
      [[
  #[cfg(test)]
  mod test {{ 
  {} 
    {} 
  }}
  ]],
      { c(1, { t({ "  use super::*", "\t" }), t("") }), i(0) }
    )
  ),
  s(
    "test",
    fmt(
      [[
  #[test]
  fn {}(){}{{
    {}
  }}
  ]],
      { i(1, "testname"), get_anyhow_presence(2), i(0) }
    )
  ),
}
