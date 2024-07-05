local stype = require("lua_snippet_repo.snippets.snippet_types")


return {
  stype.s(
    "print",
    stype.fmt([[printf("%{s}\n", {a});]], {
      s = stype.i(1, "s"),
      a = stype.i(2, ""),
    })
  ),
}
