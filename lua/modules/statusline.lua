local ale = require("sections._ale")
local buficon = require("sections._buficon")
local bufmod = require("sections._bufmodified")
local bufname = require("sections._bufname")
local editable = require("sections._bufeditable")
local filesize = require("sections._filesize")
local git_branch = require("sections._git_branch")
local lsp = require("sections._lsp")
local modes = require("tables._modes")
local signify = require("sections._signify")
local utils = require("modules.utils")

local M = {}

-- Separators
local left_separator = ""
local right_separator = ""

-- Blank Between Components
local space = " "

-- Render
function M.render()
  local ft = vim.bo.filetype

  if ft == "NvimTree" then
    return M.simpleLine()
  end

  return M.activeLine()
end

------------------------------------------------------------------------
--                             Highlight                              --
------------------------------------------------------------------------

---Select which highlight group
---@param mode string
---@return string
local function mode_group(mode)
  if mode:sub(1, 1) == "n" then
    return "normal"
  elseif mode:sub(1, 1) == "i" then
    return "insert"
  elseif mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode == "\22" then
    return "visual"
  elseif mode:sub(1, 1) == "c" then
    return "command"
  elseif mode:sub(1, 1) == "t" then
    return "terminal"
  else
    return "normal"
  end
end

---@param mode string
---@return string
---@return string
local function get_mode_hl(mode)
  local g = mode_group(mode)

  if g == "normal" then
    return "SLModeNormal", "SLModeSepNormal"
  elseif g == "insert" then
    return "SLModeInsert", "SLModeSepInsert"
  elseif g == "visual" then
    return "SLModeVisual", "SLModeSepVisual"
  elseif g == "command" then
    return "SLModeCommand", "SLModeSepCommand"
  elseif g == "terminal" then
    return "SLModeTerm", "SLModeSepTerm"
  else
    return "SLModeNormal", "SLModeSepNormal"
  end
end

function M.set_highlights()
  local c = require("modules.colors").get()
  local hi = utils.hi

  -- set StatusLine highlight
  hi("StatusLine", { fg = c.statusline_fg, bg = c.statusline_bg })
  hi("StatusLineNC", { fg = c.white_fg, bg = c.inactive_bg })
  hi("StatusLineTerm", { fg = c.statusline_fg, bg = c.statusline_bg })
  hi("StatusLineTermNC", { fg = c.white_fg, bg = c.inactive_bg })

  -- set Statusline_LSP_Func highlight
  hi("Statusline_LSP_Func", { fg = c.statusline_fg, bg = c.statusline_bg })

  hi("SLModeNormal", { fg = c.black_fg, bg = c.green, bold = true })
  hi("SLModeInsert", { fg = c.black_fg, bg = c.blue, bold = true })
  hi("SLModeVisual", { fg = c.black_fg, bg = c.purple, bold = true })
  hi("SLModeCommand", { fg = c.black_fg, bg = c.yellow, bold = true })
  hi("SLModeTerm", { fg = c.black_fg, bg = c.red, bold = true })

  hi("SLModeSepNormal", { fg = c.green })
  hi("SLModeSepInsert", { fg = c.blue })
  hi("SLModeSepVisual", { fg = c.purple })
  hi("SLModeSepCommand", { fg = c.yellow })
  hi("SLModeSepTerm", { fg = c.red })
end

------------------------------------------------------------------------
--                              Statusline                            --
------------------------------------------------------------------------
function M.activeLine()
  local config = require("modules.config").get()

  local statusline = ""

  -- Component: Mode
  local mode = vim.api.nvim_get_mode().mode
  local mode_hl, sep_hl = get_mode_hl(mode)
  statusline = statusline .. "%#" .. sep_hl .. "#" .. space -- one space indent
  statusline = statusline
    .. "%#"
    .. sep_hl
    .. "#"
    .. left_separator
    .. "%#"
    .. mode_hl
    .. "# "
    .. modes.current_mode(mode)
    .. " %#"
    .. sep_hl
    .. "#"
    .. right_separator
    .. space

  -- Component: Filetype and icons
  statusline = statusline .. "%#StatusLine#" .. bufname.get_buffer_name()
  statusline = statusline .. buficon.get_file_icon()

  -- Component: errors and warnings -> requires ALE
  if config.ale_diagnostics then
    statusline = statusline .. ale.diagnostics()
  end

  -- Component: Native Nvim LSP Diagnostic
  if config.lsp_diagnostics then
    statusline = statusline .. lsp.diagnostics()
  end

  -- TODO: SUPPORT COC LATER, NEEDS TESTING WITH COC USERS FIRST
  -- statusline = statusline..M.cocStatus()

  -- Component: git commit stats -> REQUIRES SIGNIFY
  statusline = statusline .. signify.signify()

  -- Component: git branch name -> requires FUGITIVE
  statusline = statusline .. git_branch.branch()

  --Component: Lsp Progress
  -- if lsp.lsp_progress()~= nil then
  statusline = statusline .. lsp.lsp_progress()
  statusline = statusline .. "%#Statusline_LSP_Func# " .. lsp.lightbulb()
  -- end

  -- RIGHT SIDE INFO
  -- Alignment to left
  statusline = statusline .. "%="

  -- Component: LSP CURRENT FUCTION --> Requires LSP
  statusline = statusline .. "%#Statusline_LSP_Func# " .. lsp.current_function()

  -- Scrollbar
  -- statusline = statusline.."%#StatusLine#"..vim.call('Scrollbar')..space

  -- Component: Modified, Read-Only, Filesize, Row/Col
  statusline = statusline .. "%#StatusLine#" .. bufmod.is_buffer_modified()
  statusline = statusline .. editable.editable() .. filesize.get_file_size() .. [[ʟ %l/%L c %c]] .. space
  return statusline
end

-- statusline for simple buffers such as NvimTree where you don't need mode indicators etc
function M.simpleLine()
  local statusline = ""
  return statusline .. "%#StatusLine#" .. bufname.get_buffer_name() .. ""
end

------------------------------------------------------------------------
--                              Inactive                              --
------------------------------------------------------------------------

-- INACTIVE FUNCTION DISPLAY
function M.inActiveLine()
  local statusline = ""
  return statusline .. bufname.get_buffer_name() .. buficon.get_file_icon()
end

return M
