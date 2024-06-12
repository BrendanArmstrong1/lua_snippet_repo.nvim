local stype = require("lua_snippet_repo.snippets.snippet_types")

local function difference(a, b)
  local aa = {}
  for _, v in pairs(a) do
    aa[v] = true
  end
  for _, v in pairs(b) do
    aa[v] = nil
  end
  local ret = {}
  local n = 0
  for _, v in pairs(a) do
    if aa[v] then
      n = n + 1
      ret[n] = v
    end
  end
  return ret
end

local function generic_pdoc(ilevel, args)
  local nodes = { stype.t({ "'''", string.rep("\t", ilevel) }) }
  nodes[#nodes + 1] = stype.i(1, "Small Description.")
  nodes[#nodes + 1] = stype.t({ "", "", string.rep("\t", ilevel) })
  nodes[#nodes + 1] = stype.i(2, "Long Description")
  nodes[#nodes + 1] = stype.t({ "", "", string.rep("\t", ilevel) .. "Parameters" })
  nodes[#nodes + 1] = stype.t({ "", string.rep("\t", ilevel) .. "----------" })

  local a = vim.tbl_map(function(item)
    local trimed = vim.trim(item)
    return trimed
  end, vim.split(args[1][1], ",", true))

  if args[1][1] == "" then
    a = {}
  end

  for idx, v in pairs(a) do
    local type_hint_check = vim.split(v, ":")
    if #type_hint_check > 1 then
      nodes[#nodes + 1] = stype.t({
        "",
        string.rep("\t", ilevel + 1) .. vim.trim(type_hint_check[1]) .. " : " .. vim.trim(type_hint_check[2]),
        string.rep("\t", ilevel + 2),
      })
    else
      nodes[#nodes + 1] = stype.t({ "", string.rep("\t", ilevel + 1) .. v .. " : ", string.rep("\t", ilevel + 2) })
    end
    nodes[#nodes + 1] = stype.i(idx + 2, "Description For " .. v)
  end

  return nodes, #a
end

local function pyfdoc(args, _, ostate)
  local nodes, a = generic_pdoc(1, args)
  nodes[#nodes + 1] = stype.t({ "", "\t'''" })
  nodes[#nodes + 1] = stype.t({ "", "\t", "", "\t" })
  nodes[#nodes + 1] = stype.i(a + 2 + 1, "pass")
  local snip = stype.sn(nil, nodes)
  snip.old_state = ostate or {}
  return snip
end

local function pycdoc(args, _, ostate)
  local nodes, a = generic_pdoc(2, args)
  nodes[#nodes + 1] = stype.t({ "", "\t\t'''" })
  nodes[#nodes + 1] = stype.t({ "", "\t\t", "\t\t" })
  nodes[#nodes + 1] = stype.i(a + 2 + 1, "pass")
  local snip = stype.sn(nil, nodes)
  snip.old_state = ostate or {}
  print(snip.old_state[1])
  return snip
end

local function lims_process(_, snip)
  local env = snip.env
  print(vim.inspect(env))
  if type(next(env.TM_SELECTED_TEXT)) == "nil" then
    return stype.sn(nil, { stype.i(1, "value") })
  end
  return stype.sn(nil, { stype.i(1, env.TM_SELECTED_TEXT[1]) })
end

return {
  stype.s(
    "lims",
    stype.fmta([[{"value": <value>, "max": <max>, "min": <min>}]], {
      value = stype.d(1, lims_process, {}, { user_args = {} }),
      max = stype.i(2, "max"),
      min = stype.i(3, "min"),
    })
  ),
  stype.s(
    {
      trig = "cls",
      dscr = "Documented class structure",
      name = "class",
    },
    stype.fmt(
      [[
    class {}({}):
        def init(self,{}):
            {}

    ]],
      {
        stype.i(1, "CLASS"),
        stype.i(2, ""),
        stype.i(3),
        stype.c(4, { stype.d(nil, pycdoc, { 3 }), stype.i(1, "pass") }),
      }
    )
  ),
  -- try/except/else/finally
  stype.s(
    {
      trig = "try",
      dscr = "Try except block",
    },
    stype.fmt(
      [[
    try:
        {}
    except {}{}:
        {}
    {}
    ]],
      {
        stype.i(1, "statement"),
        stype.i(2, "Exception"),
        stype.c(3, { stype.t(""), stype.sn(nil, { stype.t(" as "), stype.i(1, "e") }) }),
        stype.i(4, "..."),
        stype.c(5, {
          stype.t(""),
          stype.sn(nil, { stype.t("finally:"), stype.t({ "", "\t" }), stype.i(1, "...") }),
          stype.sn(nil, { stype.t("else:"), stype.t({ "", "\t" }), stype.i(1, "...") }),
          stype.sn(nil, {
            stype.t("else:"),
            stype.t({ "", "\t" }),
            stype.i(1, "..."),
            stype.t({ "", "finally:" }),
            stype.t({ "", "\t" }),
            stype.i(2, "..."),
          }),
        }),
      }
    )
  ),

  -- main fn setup with async choice
  stype.s(
    { trig = "main", dscr = "def name if name main" },
    stype.fmt(
      [[
        {}def main():
            {}

        if __name__ == "__main__":
            {}
        ]],
      {
        stype.c(1, { stype.t(""), stype.t("async ") }),
        stype.i(0, "pass"),
        stype.f(function(args)
          print(args)
          if args[1][1] == "async " then
            return "asyncio.run(main())"
          else
            return "main()"
          end
        end, { 1 }),
      }
    )
  ),

  -- define function
  stype.s(
    {
      trig = "def",
      dscr = "Function define",
      name = "function",
    },
    stype.fmt(
      [[
    {async}def {name}({args}):
        {docs}

    ]],
      {
        async = stype.c(1, { stype.t(""), stype.t("async ") }),
        name = stype.i(2, "fn"),
        args = stype.i(3, ""),
        docs = stype.c(4, { stype.i(1, "pass"), stype.d(nil, pyfdoc, { 3 }) }),
      }
    )
  ),

  -- with/for
  stype.s(
    {
      trig = "with",
      dscr = "with async or not",
      name = "with",
    },
    stype.fmt(
      [[
    {async}with {name} as {var}:
        {body}

    ]],
      {
        async = stype.c(1, { stype.t(""), stype.t("async ") }),
        name = stype.i(2, "enter"),
        var = stype.i(3, "var"),
        body = stype.i(4, "..."),
      }
    )
  ),
  stype.s(
    {
      trig = "for",
      dscr = "for async or not",
      name = "for",
    },
    stype.fmt(
      [[
    {async}for {var} in {iterable}:
        {body}

    ]],
      {
        async = stype.c(1, { stype.t(""), stype.t("async ") }),
        var = stype.i(2, "var"),
        iterable = stype.i(3, "iterable"),
        body = stype.i(4, "..."),
      }
    )
  ),

  -- logging
  stype.s(
    {
      trig = "logsetup",
      dscr = "setup the logger",
      name = "logger_setup",
    },
    stype.fmt(
      [[
      {root} = logging.getLogger()
      {}.setLevel(logging.DEBUG)

      handler = logging.StreamHandler(sys.stdout)
      handler.setLevel(logging.DEBUG)
      formatter = logging.Formatter('%(asctime)stype.s - %(name)stype.s - %(levelname)stype.s - %(message)stype.s')
      handler.setFormatter(formatter)
      {}.addHandler(handler)
      ]],
      {
        root = stype.i(1, "root"),
        stype.re(1),
        stype.re(1),
      }
    )
  ),
  -- debugging
  stype.s({
    trig = "pdb",
    dscr = "debugger",
    name = "py-debugger",
    snippetType = "autosnippet",
  }, stype.t("__import__('pdb').set_trace()")),
}
