local stype = require("lua_snippet_repo.snippets.snippet_types")

-- function definition for later
local M = {}

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

local bin2hex = {
  ["0000"] = "0",
  ["0001"] = "1",
  ["0010"] = "2",
  ["0011"] = "3",
  ["0100"] = "4",
  ["0101"] = "5",
  ["0110"] = "6",
  ["0111"] = "7",
  ["1000"] = "8",
  ["1001"] = "9",
  ["1010"] = "a",
  ["1011"] = "b",
  ["1100"] = "c",
  ["1101"] = "d",
  ["1110"] = "e",
  ["1111"] = "f",
}

M.oct_to_bin = function(oct_string)
  local function get_oct2bin(a)
    return oct2bin[a]
  end
  if string.lower(string.sub(oct_string, 1, 2)) == "0o" then
    oct_string = string.sub(oct_string, 2)
  end
  return string.gsub(oct_string, ".", get_oct2bin)
end

M.bits_to_hex = function(bits)
  local function get_bits2hex(a)
    return bin2hex[a]
  end
  if string.lower(string.sub(bits, 1, 2)) == "0b" then
    bits = string.sub(bits, 2)
  end
  local bits_string = string.gsub(bits, " ", "")
  return string.gsub(bits_string, "....", get_bits2hex)
end

M.add = function(x, y, base)
  local z = {}
  local n = math.max(#x, #y)
  local c = 0
  local i = 0
  while i < n or c > 0 do
    local xi = x[i + 1] or 0
    local yi = y[i + 1] or 0
    local zi = c + xi + yi
    table.insert(z, zi % base)
    c = math.floor(zi / base)
    i = i + 1
  end
  return z
end

M.multiply_by_number = function(num, x, base)
  local result = {}
  local power = x
  if num == 0 then
    return result
  end

  while true do
    if num % 2 > 0 then
      result = M.add(result, power, base)
    end
    num = math.floor(num / 2)
    if num == 0 then
      break
    end
    power = M.add(power, power, base)
  end
  return result
end

M.parse_to_digits_array = function(str, base)
  local digits = {}
  for i = #str, 1, -1 do
    local n = tonumber(string.sub(str, i, i), base)
    table.insert(digits, n)
  end
  return digits
end

M.convert_base = function(str, from_base, to_base)
  local digits = M.parse_to_digits_array(str, from_base)
  local out_array = {}
  local power = { 1 }
  for i = 1, #digits do
    if digits[i] > 0 then
      out_array = M.add(out_array, M.multiply_by_number(digits[i], power, to_base), to_base)
    end
    power = M.multiply_by_number(from_base, power, to_base)
  end

  local formatter
  if to_base == 10 then
    formatter = "%d"
  elseif to_base == 16 then
    formatter = "%x"
  elseif to_base == 8 then
    formatter = "%o"
  end

  local out = {}
  for i = #out_array, 1, -1 do
    local s = string.format(formatter, out_array[i])
    table.insert(out, s)
  end
  return table.concat(out)
end

M.decimal_from = function(arg, type)
  local answer
  if type == "b" then
    local hex_string = M.bits_to_hex(arg)
    answer = M.convert_base(hex_string, 16, 10)
  elseif type == "h" then
    if string.sub(arg, 1, 2) == "0x" then
      arg = string.sub(arg, 2)
    end
    answer = M.convert_base(arg, 16, 10)
  elseif type == "c" then
    answer = M.convert_base(arg, 8, 10)
  end
  return answer
end

M.decimal_to = function(arg, type)
  if type == "b" then
    local bits = M.oct_to_bin(M.decimal_to(arg, "c"))
    bits = string.gsub(bits, "^0", "")
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
    local hex_string = M.convert_base(arg, 10, 16)
    if math.fmod(#hex_string, 2) == 1 then
      return "0" .. hex_string
    end
    return hex_string
  elseif type == "c" then
    return M.convert_base(arg, 10, 8)
  end
end

M.string_from = function(arg, type)
  if type == "h" then
    local hex_string
    local chunk_size = 2
    local s = {}

    -- make sure hex hase even number of digits
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
    return M.string_from(M.oct_to(arg, "h"), "h")
  elseif type == "b" then
    return M.string_from(M.bin_to(arg, "h"), "h")
  end
end

M.hex_to = function (arg, type)
  local decimal_form = M.decimal_from(arg, "h")
  if type == "c" then
    return M.decimal_to(decimal_form, "c")
  elseif type == "b" then
    return M.decimal_to(decimal_form, "b")
  elseif type == "w" then
    return M.string_from(arg, "h")
  end
  return decimal_form
end

M.oct_to = function(arg, type)
  local decimal_form = M.decimal_from(arg, "c")
  if type == "h" then
    return M.convert_base(arg, 8, 16)
  elseif type == "b" then
    return M.decimal_to(decimal_form, "b")
  elseif type == "w" then
    return M.string_from(arg, "c")
  end
  return decimal_form
end

M.bin_to = function(arg, type)
  if type == "c" then
    return M.decimal_to(M.decimal_from(arg, "b"), "c")
  elseif type == "h" then
    return M.bits_to_hex(arg)
  elseif type == "w" then
    return M.string_from(arg, "b")
  elseif type == "d" then
    local hex_string = M.bits_to_hex(arg)
    return M.convert_base(hex_string, 16, 10)
  end
end

M.string_to = function(arg, type)
  if type == "h" then
    local s = {}
    local char
    for i = 1, #arg do
      char = string.sub(arg, i, i)
      table.insert(s, string.format("%02x", string.byte(char)))
    end
    return table.concat(s, "")
  elseif type == "c" then
    return M.hex_to(M.string_to(arg, "h"), "c")
  elseif type == "b" then
    return M.hex_to(M.string_to(arg, "h"), "b")
  end
end


local M1 = {
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
      return stype.sn(nil, { stype.t(M.decimal_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
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
      return stype.sn(nil, { stype.t(M.bin_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
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
      return stype.sn(nil, { stype.t(M.oct_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
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
      return stype.sn(nil, { stype.t(M.hex_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
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
      return stype.sn(nil, { stype.t(M.string_to(snip.snippet.env.POSTFIX_MATCH, snip.snippet.captures[1]), "") })
    end)
  ),
}

return M1
