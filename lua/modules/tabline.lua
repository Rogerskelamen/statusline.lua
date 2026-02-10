------------------------------------------------------------------------
--                              TabLine                               --
------------------------------------------------------------------------
local M = {}

local api = vim.api
local uv = vim.uv or vim.loop
local colors = require("modules.colors")
local config = require("modules.config")
local icons = require("tables._icons")
local utils = require("modules.utils")

-- Separators
local left_separator = ""
local right_separator = ""
local space = " "

local DIR_MAX_LEN = 25

---Trim dir with '~' char and make sure it's less then 30
---@param dir string
---@return string
local TrimmedDirectory = function(dir)
  local home = uv.os_homedir()
  if vim.startswith(dir, home) and #dir ~= #home then
    if #dir > DIR_MAX_LEN then
      dir = ".." .. dir:sub(DIR_MAX_LEN)
    end
    local new_dir = dir:gsub(home, "~")
    return new_dir
  end
  return dir
end

---@param tab integer
---@return string
local get_tab_label = function(tab)
  local wins = vim.api.nvim_tabpage_list_wins(tab)
  local first_win = wins[1]
  local buf = vim.api.nvim_win_get_buf(first_win)

  if vim.bo[buf].buftype == "terminal" then
    return " Term" -- vim.fs.basename could get wrong, so hard coding here
  end

  local name = vim.api.nvim_buf_get_name(buf)
  local fname = vim.fs.basename(name)
  if fname == "" then
    local bt = vim.bo[buf].buftype
    if bt ~= "" then
      return bt
    end
    return "No Name"
  end

  local ext = vim.fn.fnamemodify(fname, ":e")
  local icon = icons.devicon_table[ext]
  if icon then
    return icon .. space .. fname
  end
  return fname
end

function M.set_tabline_hl()
  ---@type ColorScheme
  local c = colors.get()

  -- stylua: ignore start
  ---@type table<string, vim.api.keyset.highlight>
  local tabline_hls = {
    TabLineSel          = { fg = c.black_fg,   bg = c.green,      bold = true },
    TabLineSelSeparator = { fg = c.green,                         bold = true },
    TabLine             = { fg = c.white_fg,   bg = c.inactive_bg             },
    TabLineSeparator    = { fg = c.inactive_bg                                },
    TabLineFill         = {                    bg = "none"                    },
  }
  -- stylua: ignore end

  for hl_name, opts in pairs(tabline_hls) do
    utils.hi(hl_name, opts)
  end
end

---Build correct tabline format string
---@param tab integer
---@param label string
---@param selected boolean
---@return string
local function tab_segment(tab, label, selected)
  local sep_hl = selected and "TabLineSelSeparator" or "TabLineSeparator"
  local text_hl = selected and "TabLineSel" or "TabLine"

  -- stylua: ignore start
  return table.concat({
    "%",   tab,     "T",
    "%#",  sep_hl,  "# ", left_separator,
    "%#",  text_hl, "# ", label,
    " %#", sep_hl,  "#",  right_separator,
    "%T",
  })
  -- stylua: ignore end
end

---@return string
function M.render()
  if not config.get().tabline then
    return ""
  end

  ---@type table<string>
  local parts = {}
  local tab_list = api.nvim_list_tabpages()
  local current_tab = api.nvim_get_current_tabpage()

  -- stylua: ignore start
  for _, tab in ipairs(tab_list) do
    parts[#parts + 1] = tab_segment(
      tab,
      get_tab_label(tab),
      tab == current_tab
    )
  end
  -- stylua: ignore end

  -- right aligned cwd
  parts[#parts + 1] = "%="
  parts[#parts + 1] = table.concat({
    "%#TabLineSeparator#",
    left_separator,
    "%#TabLine# ",
    TrimmedDirectory(uv.cwd()),
    "%#TabLineSeparator#",
    right_separator,
    space,
  })

  return table.concat(parts)
end

return M
