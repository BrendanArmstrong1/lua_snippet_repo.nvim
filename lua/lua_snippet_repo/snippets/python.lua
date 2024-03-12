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
	local nodes = { t({ "'''", string.rep("\t", ilevel) }) }
	nodes[#nodes + 1] = i(1, "Small Description.")
	nodes[#nodes + 1] = t({ "", "", string.rep("\t", ilevel) })
	nodes[#nodes + 1] = i(2, "Long Description")
	nodes[#nodes + 1] = t({ "", "", string.rep("\t", ilevel) .. "Parameters" })
	nodes[#nodes + 1] = t({ "", string.rep("\t", ilevel) .. "----------" })

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
			nodes[#nodes + 1] = t({
				"",
				string.rep("\t", ilevel + 1) .. vim.trim(type_hint_check[1]) .. " : " .. vim.trim(type_hint_check[2]),
				string.rep("\t", ilevel + 2),
			})
		else
			nodes[#nodes + 1] = t({ "", string.rep("\t", ilevel + 1) .. v .. " : ", string.rep("\t", ilevel + 2) })
		end
		nodes[#nodes + 1] = i(idx + 2, "Description For " .. v)
	end

	return nodes, #a
end

local function pyfdoc(args, _, ostate)
	local nodes, a = generic_pdoc(1, args)
	nodes[#nodes + 1] = t({ "", "\t'''" })
	nodes[#nodes + 1] = t({ "", "\t", "", "\t" })
	nodes[#nodes + 1] = i(a + 2 + 1, "pass")
	local snip = sn(nil, nodes)
	snip.old_state = ostate or {}
	return snip
end

local function pycdoc(args, _, ostate)
	local nodes, a = generic_pdoc(2, args)
	nodes[#nodes + 1] = t({ "", "\t\t'''" })
	nodes[#nodes + 1] = t({ "", "\t\t", "\t\t" })
	nodes[#nodes + 1] = i(a + 2 + 1, "pass")
	local snip = sn(nil, nodes)
	snip.old_state = ostate or {}
	print(snip.old_state[1])
	return snip
end

local function lims_process(_, snip)
	local env = snip.env
	print(vim.inspect(env))
	if type(next(env.TM_SELECTED_TEXT)) == "nil" then
		return sn(nil, { i(1, "value") })
	end
	return sn(nil, { i(1, env.TM_SELECTED_TEXT[1]) })
end

return {
	s(
		"lims",
		fmta([[{"value": <value>, "max": <max>, "min": <min>}]], {
			value = d(1, lims_process, {}, { user_args = {} }),
			max = i(2, "max"),
			min = i(3, "min"),
		})
	),
	s(
		{
			trig = "cls",
			dscr = "Documented class structure",
			name = "class",
		},
		fmt(
			[[
    class {}({}):
        def init(self,{}):
            {}

    ]],
			{
				i(1, "CLASS"),
				i(2, ""),
				i(3),
				c(4, { d(nil, pycdoc, { 3 }), i(1, "pass") }),
			}
		)
	),
	-- try/except/else/finally
	s(
		{
			trig = "try",
			dscr = "Try except block",
		},
		fmt(
			[[
    try:
        {}
    except {}{}:
        {}
    {}
    ]],
			{
				i(1, "statement"),
				i(2, "Exception"),
				c(3, { t(""), sn(nil, { t(" as "), i(1, "e") }) }),
				i(4, "..."),
				c(5, {
					t(""),
					sn(nil, { t("finally:"), t({ "", "\t" }), i(1, "...") }),
					sn(nil, { t("else:"), t({ "", "\t" }), i(1, "...") }),
					sn(nil, {
						t("else:"),
						t({ "", "\t" }),
						i(1, "..."),
						t({ "", "finally:" }),
						t({ "", "\t" }),
						i(2, "..."),
					}),
				}),
			}
		)
	),

	-- main fn setup with async choice
	s(
		{ trig = "main", dscr = "def name if name main" },
		fmt(
			[[
        {}def main():
            {}

        if __name__ == "__main__":
            {}
        ]],
			{
				c(1, { t(""), t("async ") }),
				i(0, "pass"),
				f(function(args)
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
	s(
		{
			trig = "def",
			dscr = "Function define",
			name = "function",
		},
		fmt(
			[[
    {async}def {name}({args}):
        {docs}

    ]],
			{
				async = c(1, { t(""), t("async ") }),
				name = i(2, "fn"),
				args = i(3, ""),
				docs = c(4, { i(1, "pass"), d(nil, pyfdoc, { 3 }) }),
			}
		)
	),

	-- with/for
	s(
		{
			trig = "with",
			dscr = "with async or not",
			name = "with",
		},
		fmt(
			[[
    {async}with {name} as {var}:
        {body}

    ]],
			{
				async = c(1, { t(""), t("async ") }),
				name = i(2, "enter"),
				var = i(3, "var"),
				body = i(4, "..."),
			}
		)
	),
	s(
		{
			trig = "for",
			dscr = "for async or not",
			name = "for",
		},
		fmt(
			[[
    {async}for {var} in {iterable}:
        {body}

    ]],
			{
				async = c(1, { t(""), t("async ") }),
				var = i(2, "var"),
				iterable = i(3, "iterable"),
				body = i(4, "..."),
			}
		)
	),

	-- logging
	s(
		{
			trig = "logsetup",
			dscr = "setup the logger",
			name = "logger_setup",
		},
		fmt(
			[[
      {root} = logging.getLogger()
      {}.setLevel(logging.DEBUG)

      handler = logging.StreamHandler(sys.stdout)
      handler.setLevel(logging.DEBUG)
      formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
      handler.setFormatter(formatter)
      {}.addHandler(handler)
      ]],
			{
				root = i(1, "root"),
				re(1),
				re(1),
			}
		)
	),
	-- debugging
	s({
		trig = "pdb",
		dscr = "debugger",
		name = "py-debugger",
		snippetType = "autosnippet",
	}, t("__import__('pdb').set_trace()")),
}
