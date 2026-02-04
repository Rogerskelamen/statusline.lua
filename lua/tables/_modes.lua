local M = {}

---@type table<string, string>
local mode_map = {
  n  = "N",
  no = "N·Op",
  nt = "N·Term",

  v  = "V",
  V  = "V·Line",
  ["\22"] = "V·Block",  -- <C-v>

  s  = "Select",
  S  = "S·Line",
  ["\19"] = "S·Block",  -- <C-s>

  i  = "I",
  ic = "I",
  ix = "I",

  R  = "Replace",
  Rv = "V·Replace",

  c  = "C",
  cv = "Vim·EX",
  ce = "Ex",

  r  = "Prompt",
  rm = "More",
  ["r?"] = "Confirm",

  ["!"] = "Shell",
  t  = "T",
}

function M.current_mode(mode)
  if mode_map[mode] then
    return mode_map[mode]
  end

  -- prefix pair
  for k, v in pairs(mode_map) do
    if mode:sub(1, #k) == k then
      return v
    end
  end

  return mode
end

return M
