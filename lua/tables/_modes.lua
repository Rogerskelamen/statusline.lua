local M = {}

---@type table<string, string>
local mode_map = {
  n = "N",
  no = "N·Op",
  nt = "N·Term",

  v = "V",
  V = "V·Line",
  ["\22"] = "V·Block", -- <C-v>

  s = "Select",
  S = "S·Line",
  ["\19"] = "S·Block", -- <C-s>

  i = "I",
  ic = "I",
  ix = "I",

  R = "Replace",
  Rv = "V·Replace",

  c = "C",
  cv = "Vim·EX",
  ce = "Ex",

  r = "Prompt",
  rm = "More",
  ["r?"] = "Confirm",

  ["!"] = "Shell",
  t = "T",
}

-- key sort: longer key has high priority
local sorted = vim.tbl_keys(mode_map)
table.sort(sorted, function(a, b)
  return #a > #b
end)

---Map current mode to a certain prompt
---@param mode string
---@return string
function M.current_mode(mode)
  -- longest prefix pair
  for _, k in ipairs(sorted) do
    if mode:sub(1, #k) == k then
      return mode_map[k]
    end
  end

  return mode
end

return M
