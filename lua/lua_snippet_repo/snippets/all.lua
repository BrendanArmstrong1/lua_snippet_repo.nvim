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
    "curtime",
    f(function()
      return os.date("%D - %H:%M")
    end)
  ),
  s("part", p(os.date, "%Y")),
  s("mat", {
    i(1, { "sample_text" }),
    t(": "),
    m(1, "%d", "contains a number", "no number :("),
    c(2, {
      t(""),
      sn(nil, {
        t({ "", " throws " }),
        i(1),
      }),
    }),
  }),
  s("dl2", {
    i(1, "sample_text"),
    i(2, "sample_text_2"),
    t({ "", "" }),
    dl(3, l._1:gsub("\n", " linebreak") .. l._2, { 1, 2 }),
  }),
  s("transform", {
    i(1, "initial text"),
    t("::"),
    i(2, "replacement for e"),
    t({ "", "" }),
    l(l._1:gsub("e", l._2), { 1, 2 }),
  }),
  s("sametest", fmt([[example: {}, function: {}]], { i(1), re(1) })),
}
