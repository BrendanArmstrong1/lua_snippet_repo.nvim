local stype = require("lua_snippet_repo.snippets.snippet_types")

return {
  stype.s(
    "print",
    stype.fmt([[printf("%{s}\n", {a});]], {
      s = stype.i(1, "s"),
      a = stype.i(2, ""),
    })
  ),
  stype.s(
    "sn_fileopen",
    stype.fmt(
      [[
  FILE *fptr;
  char  mystring[100];

  fptr = fopen("{filename}", "r");
  fgets(mystring, 100, fptr);

  ]],
      { filename = stype.i(1, "filename.txt") }
    )
  ),
}
