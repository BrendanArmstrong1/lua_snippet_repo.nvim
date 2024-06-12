local stype = require("lua_snippet_repo.snippets.snippet_types")

return {
  stype.s(
    "curtime",
    stype.f(function()
      return os.date("%D - %H:%M")
    end)
  ),
  stype.s("part", stype.p(os.date, "%Y")),
  stype.s("mat", {
    stype.i(1, { "sample_text" }),
    stype.t(": "),
    stype.m(1, "%d", "contains a number", "no number :("),
    stype.c(2, {
      stype.t(""),
      stype.sn(nil, {
        stype.t({ "", " throws " }),
        stype.i(1),
      }),
    }),
  }),
  stype.s("dl2", {
    stype.i(1, "sample_text"),
    stype.i(2, "sample_text_2"),
    stype.t({ "", "" }),
    stype.dl(3, stype.l._1:gsub("\n", " linebreak") .. stype.l._2, { 1, 2 }),
  }),
  stype.s("transform", {
    stype.i(1, "initial text"),
    stype.t("::"),
    stype.i(2, "replacement for e"),
    stype.t({ "", "" }),
    stype.l(stype.l._1:gsub("e", stype.l._2), { 1, 2 }),
  }),
  stype.s("sametest", stype.fmt([[example: {}, function: {}]], { stype.i(1), stype.re(1) })),
}
