------------------------------------------------------------------------
--                              TabLine                               --
------------------------------------------------------------------------
local M = {}

local api = vim.api
local cmd = api.nvim_command
local icons = require("tables._icons")
local config = require("modules.config")

-- Separators
local left_separator = ""
local right_separator = ""
local space = " "

---Trim dir with '~' char and make sure it's less then 30
---@param dir string
---@return string
local TrimmedDirectory = function(dir)
  local home = vim.uv.os_homedir()
  if vim.startswith(dir, home) and #dir ~= #home then
    if #dir > 30 then
      dir = ".." .. dir:sub(30)
    end
    local new_dir = dir:gsub(home, "~")
    return new_dir
  end
  return dir
end

---@param n integer
---@return string
local getTabLabel = function(n)
  local win = vim.api.nvim_tabpage_get_win(n)
  local file_name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  if vim.startswith(file_name, "term://") then
    return " " .. vim.fs.basename(file_name)
  end
  file_name = vim.fs.basename(file_name)
  if file_name == "" then
    return "No Name"
  end
  local icon = icons.deviconTable[file_name]
  if icon then
    return icon .. space .. file_name
  end
  return file_name
end

local set_colours = function()
  ---@type ColorScheme
  local colors = require("modules.colors").get()
  cmd("hi TabLineSel gui=Bold guibg=" .. colors.green .. " guifg=" .. colors.black_fg)
  cmd("hi TabLineSelSeparator gui=bold guifg=" .. colors.green)
  cmd("hi TabLine guibg=" .. colors.inactive_bg .. " guifg=" .. colors.white_fg .. " gui=None")
  cmd("hi TabLineSeparator guifg=" .. colors.inactive_bg)
  cmd("hi TabLineFill guibg=None gui=None")
end

function M.init()
  if not config.get().tabline then
    return ""
  end

  set_colours()
  local tabline = ""
  local tab_list = api.nvim_list_tabpages()
  local current_tab = api.nvim_get_current_tabpage()

  for _, val in ipairs(tab_list) do
    local file_name = getTabLabel(val)
    if val == current_tab then
      tabline = tabline .. "%" .. val .. "T"
      tabline = tabline .. "%#TabLineSelSeparator# " .. left_separator
      tabline = tabline .. "%#TabLineSel# " .. file_name
      tabline = tabline .. " %#TabLineSelSeparator#" .. right_separator
      tabline = tabline .. "%T"
    else
      tabline = tabline .. "%" .. val .. "T"
      tabline = tabline .. "%#TabLineSeparator# " .. left_separator
      tabline = tabline .. "%#TabLine# " .. file_name
      tabline = tabline .. " %#TabLineSeparator#" .. right_separator
      tabline = tabline .. "%T"
    end
  end

  tabline = tabline .. "%="
  local dir = api.nvim_call_function("getcwd", {})
  tabline = tabline
  .. "%#TabLineSeparator#"
  .. left_separator
  .. "%#Tabline# "
  .. TrimmedDirectory(dir)
  .. "%#TabLineSeparator#"
  .. right_separator

  tabline = tabline .. space
  return tabline
end

return M
