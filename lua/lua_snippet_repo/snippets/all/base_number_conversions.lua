local stype = require("lua_snippet_repo.snippets.snippet_types")

-- function definition for later
local string_from

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
  if type == "b" then
    answer = tonumber(string.gsub(arg, " ", ""), 2)
  elseif type == "h" then
    answer = tonumber(arg, 16)
  elseif type == "c" then
    answer = tonumber(arg, 8)
  end
  return tostring(answer)
end

local function decimal_to(arg, type)
  if type == "b" then
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
  elseif type == "h" then
    local hex_string = string.format("%x", arg)
    if math.fmod(#hex_string, 2) == 1 then
      return "0" .. hex_string
    end
    return hex_string
  elseif type == "c" then
    return string.format("%o", arg)
  end
end

local function hex_to(arg, type)
  if type == "c" then
    return decimal_to(decimal_from(arg, "h"), "c")
  elseif type == "b" then
    return decimal_to(decimal_from(arg, "h"), "b")
  elseif type == "w" then
    return string_from(arg, "h")
  elseif type == "d" then
    return decimal_from(arg, "h")
  end
end
local function oct_to(arg, type)
  if type == "h" then
    return decimal_to(decimal_from(arg, "c"), "h")
  elseif type == "b" then
    return decimal_to(decimal_from(arg, "c"), "b")
  elseif type == "w" then
    return string_from(arg, "c")
  elseif type == "d" then
    return decimal_from(arg, "c")
  end
end
local function bin_to(arg, type)
  if type == "c" then
    return decimal_to(decimal_from(arg, "b"), "c")
  elseif type == "h" then
    return decimal_to(decimal_from(arg, "b"), "h")
  elseif type == "w" then
    return string_from(arg, "b")
  elseif type == "d" then
    return decimal_from(arg, "b")
  end
end

local function string_to(arg, type)
  if type == "h" then
    local s = {}
    local char
    for i = 1, #arg do
      char = string.sub(arg, i, i)
      table.insert(s, string.format("%02x", string.byte(char)))
    end
    return table.concat(s, "")
  elseif type == "c" then
    return hex_to(string_to(arg, "h"), "c")
  elseif type == "b" then
    return hex_to(string_to(arg, "h"), "b")
  end
end

string_from = function(arg, type)
  if type == "h" then
    local hex_string
    local chunk_size = 2
    local s = {}

    -- make sure string hase even number of digits
    if math.fmod(#arg, 2) == 1 then
      hex_string = "0" .. arg
    else
      hex_string = arg
    end

    for i = 1, #hex_string, chunk_size do
      s[#s + 1] = string.char(tonumber(string.sub(hex_string, i, i + chunk_size - 1), 16))
    end

    return table.concat(s, "")
  elseif type == "c" then
    return string_from(oct_to(arg, "h"), "h")
  elseif type == "b" then
    return string_from(bin_to(arg, "h"), "h")
  end
end


local M = {
  stype.postfix(
    {
      name = "decimal to",
      trig = [[\.d\([bch]\)]],
      wordTrig = false,
      trigEngine = "vim",
      snippetType = "autosnippet",
      match_pattern = "[0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(decimal_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
    end)
  ),
  stype.postfix(
    {
      name = "binary to",
      trig = [[\.b\([dchw]\)]],
      wordTrig = false,
      trigEngine = "vim",
      snippetType = "autosnippet",
      match_pattern = "0?b?[01][01%s?]+[01]$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(bin_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
    end)
  ),
  stype.postfix(
    {
      name = "oct to",
      trig = [[\.c\([dbhw]\)]],
      wordTrig = false,
      trigEngine = "vim",
      snippetType = "autosnippet",
      match_pattern = "0?o?[0-7]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(oct_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
    end)
  ),
  stype.postfix(
    {
      name = "hex to",
      trig = [[\.h\([dbcw]\)]],
      wordTrig = false,
      trigEngine = "vim",
      snippetType = "autosnippet",
      match_pattern = "0?x?[a-fA-F0-9]+$",
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(hex_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
    end)
  ),
  stype.postfix(
    {
      name = "string(word) to binary",
      trig = [[\.w\([hbc]\)]],
      wordTrig = false,
      trigEngine = "vim",
      snippetType = "autosnippet",
      match_pattern = [[[%w%"%'`%-%.%_]+$]],
    },
    stype.d(1, function(_, snip)
      return stype.sn(nil, { stype.t(string_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
    end)
  ),
}

return M
