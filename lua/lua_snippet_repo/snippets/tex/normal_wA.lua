local ls = require("luasnip")

local normal_wA = {
  ls.parser.parse_snippet({ trig = "mk", name = "Math" }, "\\( ${1:${TM_SELECTED_TEXT}} \\)$0"),
  ls.parser.parse_snippet({ trig = "pac", name = "Package" }, "\\usepackage[${1:options}]{${2:package}}$0"),
  ls.parser.parse_snippet({ trig = "dm", name = "Block Math" }, "\\[\n\t${1:${TM_SELECTED_TEXT}}\n.\\] $0"),
}

return normal_wA
