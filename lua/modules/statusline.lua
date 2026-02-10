local cmd = vim.api.nvim_command
local buficon = require("sections._buficon")
local bufmod = require("sections._bufmodified")
local bufname = require("sections._bufname")
local editable = require("sections._bufeditable")
local filesize = require("sections._filesize")
local git_branch = require("sections._git_branch")
local lsp = require("sections._lsp")
local ale = require("sections._ale")
local modes = require("tables._modes")
local signify = require("sections._signify")

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
--                             Colours                                --
------------------------------------------------------------------------

-- TODO: check why need this `last_mode`
local last_mode = nil

-- Redraw different colors for different mode
-- TODO: refactor this set_mode_colour in lua version
local function set_mode_colours(mode)
  if mode == last_mode then
    return
  end
  last_mode = mode

  local colors = require("modules.colors").get()
  if mode == "n" then
    cmd("hi Mode guibg=" .. colors.green .. " guifg=" .. colors.black_fg .. " gui=bold")
    cmd("hi ModeSeparator guifg=" .. colors.green)
  elseif mode == "i" then
    cmd("hi Mode guibg=" .. colors.blue .. " guifg=" .. colors.black_fg .. " gui=bold")
    cmd("hi ModeSeparator guifg=" .. colors.blue)
  elseif mode == "v" or mode == "V" or mode == "^V" then
    cmd("hi Mode guibg=" .. colors.purple .. " guifg=" .. colors.black_fg .. " gui=bold")
    cmd("hi ModeSeparator guifg=" .. colors.purple)
  elseif mode == "c" then
    cmd("hi Mode guibg=" .. colors.yellow .. " guifg=" .. colors.black_fg .. " gui=bold")
    cmd("hi ModeSeparator guifg=" .. colors.yellow)
  elseif mode == "t" then
    cmd("hi Mode guibg=" .. colors.red .. " guifg=" .. colors.black_fg .. " gui=bold")
    cmd("hi ModeSeparator guifg=" .. colors.red)
  end
end

function M.set_highlights()
  local colors = require("modules.colors").get()
  -- set Status_Line highlight
  cmd("hi StatusLine guibg=" .. colors.statusline_bg .. " guifg=" .. colors.statusline_fg)
  -- set Statusline_LSP_Func highlight
  cmd("hi Statusline_LSP_Func guibg=" .. colors.statusline_bg .. " guifg=" .. colors.statusline_fg)
  -- set InActive highlight
  cmd("hi InActive guibg=" .. colors.inactive_bg .. " guifg=" .. colors.white_fg)
end

------------------------------------------------------------------------
--                              Statusline                            --
------------------------------------------------------------------------
function M.activeLine()
  local config = require("modules.config").get()

  local statusline = ""
  -- Component: Mode
  local mode = vim.api.nvim_get_mode().mode
  set_mode_colours(mode)
  statusline = statusline .. "%#ModeSeparator#" .. space
  statusline = statusline
    .. "%#ModeSeparator#"
    .. left_separator
    .. "%#Mode# "
    .. modes.current_mode(mode)
    .. " %#ModeSeparator#"
    .. right_separator
    .. space
  -- Component: Filetype and icons
  statusline = statusline .. "%#Status_Line#" .. bufname.get_buffer_name()
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
  -- statusline = statusline.."%#Status_Line#"..vim.call('Scrollbar')..space

  -- Component: Modified, Read-Only, Filesize, Row/Col
  statusline = statusline .. "%#Status_Line#" .. bufmod.is_buffer_modified()
  statusline = statusline .. editable.editable() .. filesize.get_file_size() .. [[ʟ %l/%L c %c]] .. space
  return statusline
end

-- statusline for simple buffers such as NvimTree where you don't need mode indicators etc
function M.simpleLine()
  local statusline = ""
  return statusline .. "%#Status_Line#" .. bufname.get_buffer_name() .. ""
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

-- local function mode_group(mode)
--   if mode:sub(1,1) == "n" then
--     return "normal"
--   elseif mode:sub(1,1) == "i" then
--     return "insert"
--   elseif mode:sub(1,1) == "v" or mode:sub(1, 1) == "V" or mode == "\22" then
--     return "visual"
--   elseif mode:sub(1,1) == "c" then
--     return "command"
--   elseif mode:sub(1,1) == "t" then
--     return "terminal"
--   else
--     return "other"
--   end
-- end
--
-- ---@param mode string
-- ---@return string
-- ---@return string
-- local function get_mode_hl(mode)
--   local g = mode_group(mode)
--
--   if g == "normal" then
--     return "SLModeNormal", "SLModeSepNormal"
--   elseif g == "insert" then
--     return "SLModeInsert", "SLModeSepInsert"
--   elseif g == "visual" then
--     return "SLModeVisual", "SLModeSepVisual"
--   elseif g == "command" then
--     return "SLModeCommand", "SLModeSepCommand"
--   elseif g == "terminal" then
--     return "SLModeTerm", "SLModeSepTerm"
--   else
--     return "SLModeNormal", "SLModeSepNormal"
--   end
-- end
--
-- function M.set_highlights()
--   local c = require("modules.colors").get()
--   local hi = vim.api.nvim_set_hl
--
--   cmd("hi StatusLine guibg=" .. c.statusline_bg .. " guifg=" .. c.statusline_fg)
--   -- set Statusline_LSP_Func highlight
--   cmd("hi Statusline_LSP_Func guibg=" .. c.statusline_bg .. " guifg=" .. c.statusline_fg)
--   -- set InActive highlight
--   cmd("hi InActive guibg=" .. c.inactive_bg .. " guifg=" .. c.white_fg)
--
--   hi(0, "SLNormal", { fg = c.statusline_fg, bg = c.statusline_bg })
--   hi(0, "SLInactive", { fg = c.white_fg, bg = c.inactive_bg })
--
--   hi(0, "SLModeNormal",  { fg = c.black_fg, bg = c.green,  bold = true })
--   hi(0, "SLModeInsert",  { fg = c.black_fg, bg = c.blue,   bold = true })
--   hi(0, "SLModeVisual",  { fg = c.black_fg, bg = c.purple, bold = true })
--   hi(0, "SLModeCommand", { fg = c.black_fg, bg = c.yellow, bold = true })
--   hi(0, "SLModeTerm",    { fg = c.black_fg, bg = c.red,    bold = true })
--
--   hi(0, "SLModeSepNormal",  { fg = c.green })
--   hi(0, "SLModeSepInsert",  { fg = c.blue })
--   hi(0, "SLModeSepVisual",  { fg = c.purple })
--   hi(0, "SLModeSepCommand", { fg = c.yellow })
--   hi(0, "SLModeSepTerm",    { fg = c.red })
-- end
--
-- ------------------------------------------------------------------------
-- --                              Statusline                            --
-- ------------------------------------------------------------------------
-- function M.activeLine()
--   local statusline = ""
--   -- Component: Mode
--   local mode = vim.api.nvim_get_mode().mode
--   local mode_hl, sep_hl = get_mode_hl(mode)
