local stype = require("lua_snippet_repo.snippets.snippet_types")

local get_anyhow_presence = function(position)
  return stype.d(position, function()
    local nodes = {}
    table.insert(nodes, stype.t(" "))

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      if line:match("anyhow::Result") then
        table.insert(nodes, stype.t(" -> Result<()> "))
        break
      end
    end
    return stype.sn(nil, stype.c(1, nodes))
  end, {})
end

return {
  -- print snips
  stype.s({ trig = "print" }, stype.fmt([[println!("{{{}}}", {});]], { stype.c(1, { stype.t(":?"), stype.t("") }), stype.i(2) })),
  stype.s({ trig = "format" }, stype.fmt([[format!("{{{}}}", {});]], { stype.c(1, { stype.t(":?"), stype.t("") }), stype.i(2) })),
  -- format

  -- fn snips

  -- Test snips
  stype.s(
    "modtest",
    stype.fmt(
      [[
  #[cfg(test)]
  mod test {{ 
  {} 
    {} 
  }}
  ]],
      { stype.c(1, { stype.t({ "  use super::*", "\t" }), stype.t("") }), stype.i(0) }
    )
  ),
  stype.s(
    "test",
    stype.fmt(
      [[
  #[test]
  fn {}(){}{{
    {}
  }}
  ]],
      { stype.i(1, "testname"), get_anyhow_presence(2), stype.i(0) }
    )
  ),
}
