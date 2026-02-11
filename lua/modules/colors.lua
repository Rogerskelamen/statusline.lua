------------------------------------------------------------------------
--                             Colours                                --
------------------------------------------------------------------------

local config = require("modules.config")

local M = {}

-- Default colours
---@class ColorScheme
---@field purple string
---@field blue string
---@field yellow string
---@field green string
---@field red string
---@field gray_fg string
---@field white_fg string
---@field black_fg string
---@field tabline_bg string
---@field inactive_bg string
---@field statusline_bg string
---@field statusline_fg string
local defaults = {
  -- Different colors for mode
  purple = "#BF616A", --#B48EAD
  blue = "#83a598", --#81A1C1
  yellow = "#fabd2f", --#EBCB8B
  green = "#8ec07c", --#A3BE8C
  red = "#fb4934", --#BF616A

  -- fg and bg
  gray_fg = "#859289",
  white_fg = "#b8b894",
  black_fg = "#282c34",

  -- Inactive bg
  tabline_bg = "#1c1c1c",
  inactive_bg = "none",

  -- Statusline colour
  statusline_bg = "none", -- Set to none, use native bg
  statusline_fg = "none",
}

---@type ColorScheme|nil
local colors

---@param group string
---@param key string
---@param fallback string
---@return string
local function get_color(group, key, fallback)
  local ok, hl = pcall(vim.nvim_get_hl, group, true)
  if not ok or not config.get().match_colorscheme then
    -- if not ok then
    return fallback
  end
  local color = hl[key]
  if not color then
    return fallback
  end
  return string.format("#%06x", color)
end

---@return ColorScheme
local function compute_colors()
  return {
    purple = get_color("Statement", "foreground", defaults.purple),
    blue = get_color("Function", "foreground", defaults.blue),
    yellow = get_color("Constant", "foreground", defaults.yellow),
    green = get_color("String", "foreground", defaults.green),
    red = get_color("Error", "foreground", defaults.red),
    gray_fg = get_color("Grey", "foreground", defaults.gray_fg),
    white_fg = get_color("Normal", "foreground", defaults.white_fg),
    black_fg = get_color("Normal", "background", defaults.black_fg),
    tabline_bg = get_color("NormalNC", "background", defaults.tabline_bg),
    inactive_bg = defaults.inactive_bg,
    statusline_bg = defaults.statusline_bg,
    statusline_fg = defaults.statusline_fg,
  }
end

---@return ColorScheme
function M.get()
  if not colors then
    colors = compute_colors()
  end
  return colors
end

function M.reset()
  colors = nil
end

return M
