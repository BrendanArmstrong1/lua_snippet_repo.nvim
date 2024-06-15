local stype = require("lua_snippet_repo.snippets.snippet_types")

local oct2bin = {
  ["0"] = "000",
  ["1"] = "001",
  ["2"] = "010",
  ["3"] = "011",
  ["4"] = "100",
  ["5"] = "101",
  ["6"] = "110",
  ["7"] = "111",
}

local function get_oct_2_bin(a)
  return oct2bin[a]
end
local function to_bits(num)
  local s = string.format("%o", num)
  s = string.gsub(s, ".", get_oct_2_bin)
  print(s)
  return s
end

local function decimal_from(arg, type)
  local answer
  if type == "binary" then
    answer = tonumber(string.gsub(arg, " ", ""), 2)
  elseif type == "hex" then
    answer = tonumber(arg, 16)
  elseif type == "oct" then
    answer = tonumber(arg, 8)
  end
  return tostring(answer)
end

local function decimal_to(arg, type)
  if type == "binary" then
    local bits = string.gsub(to_bits(arg), "^0+", "")
    local chunk_size = 4
    local remaining = chunk_size - math.fmod(#bits, chunk_size)
    if remaining == 4 then
      remaining = 0
    end

    local return_string = ("0"):rep(remaining) .. bits
    local s = {}
    for i = 1, #return_string, chunk_size do
      s[#s + 1] = string.sub(return_string, i, i + chunk_size - 1)
    end
    return table.concat(s, " ")
  elseif type == "hex" then
    local hex_string = string.format("%x", arg)
    if math.fmod(#hex_string, 2) == 1 then
      return "0" .. hex_string
    end
    return hex_string
  elseif type == "oct" then
    return string.format("%o", arg)
  end
end

local function hex_to(arg, type)
  if type == "oct" then
    return decimal_to(tostring(decimal_from(arg, "hex")), "oct")
  elseif type == "binary" then
    return decimal_to(tostring(decimal_from(arg, "hex")), "binary")
  end
end
local function oct_to(arg, type)
  if type == "hex" then
    return decimal_to(tostring(decimal_from(arg, "oct")), "hex")
  elseif type == "binary" then
    return decimal_to(tostring(decimal_from(arg, "oct")), "binary")
  end
end
local function bin_to(arg, type)
  if type == "oct" then
    return decimal_to(tostring(decimal_from(arg, "binary")), "oct")
  elseif type == "hex" then
    return decimal_to(tostring(decimal_from(arg, "binary")), "hex")
  end
end

local M = {
  stype.postfix(
    {
      name = "decimal to binary",
      trig = ".db",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "[0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_to(snip.snippet.env.POSTFIX_MATCH, "binary"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "decimal to oct",
      trig = ".do",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "[0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_to(snip.snippet.env.POSTFIX_MATCH, "oct"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "decimal to hex",
      trig = ".dh",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "[0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_to(snip.snippet.env.POSTFIX_MATCH, "hex"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "binary to decimal",
      trig = ".bd",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?b?[01][01%s?]+[01]$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_from(snip.snippet.env.POSTFIX_MATCH, "binary"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "oct to decimal",
      trig = ".od",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?o?[0-7]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_from(snip.snippet.env.POSTFIX_MATCH, "oct"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "hex to decimal",
      trig = ".hd",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?x?[a-fA-F0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_from(snip.snippet.env.POSTFIX_MATCH, "hex"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "binary to oct",
      trig = ".bo",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?b?[01][01%s?]+[01]$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(bin_to(snip.snippet.env.POSTFIX_MATCH, "oct"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "binary to hex",
      trig = ".bh",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?b?[01][01%s?]+[01]$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(bin_to(snip.snippet.env.POSTFIX_MATCH, "hex"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "oct to binary",
      trig = ".ob",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?o?[0-7]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(oct_to(snip.snippet.env.POSTFIX_MATCH, "binary"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "oct to hex",
      trig = ".oh",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?o?[0-7]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(oct_to(snip.snippet.env.POSTFIX_MATCH, "hex"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "hex to binary",
      trig = ".hb",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?x?[a-fA-F0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(hex_to(snip.snippet.env.POSTFIX_MATCH, "binary"), "") })
    end)
  ),
  stype.postfix(
    {
      name = "hex to oct",
      trig = ".ho",
      wordTrig = false,
      snippetType = "autosnippet",
      match_pattern = "0?x?[a-fA-F0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(hex_to(snip.snippet.env.POSTFIX_MATCH, "oct"), "") })
    end)
  ),
}

return M
