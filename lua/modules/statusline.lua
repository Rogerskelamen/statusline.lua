local ale = require("sections._ale")
local buficon = require("sections._buficon")
local bufmod = require("sections._bufmodified")
local bufname = require("sections._bufname")
local editable = require("sections._bufeditable")
local filesize = require("sections._filesize")
local git_branch = require("sections._git_branch")
local lsp = require("sections._lsp")
local lsp_function = require("sections._lsp_function")
local modes = require("tables._modes")
local signify = require("sections._signify")
local utils = require("modules.utils")

local M = {}

-- Separators
local left_separator = ""
local right_separator = ""

-- Blank Between Components
local space = " "

-- Main Render function
function M.render()
  local winid = vim.g.statusline_winid
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local bt = vim.bo[bufnr].buftype

  if bt ~= "" and bt ~= "terminal" then
    return M.simple_line(bufnr)
  end

  if winid ~= vim.api.nvim_get_current_win() then
    return M.inactive_line(bufnr)
  end

  return M.active_line()
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
  hi("StatusLineNC", { fg = c.gray_fg, bg = c.inactive_bg })
  hi("StatusLineTerm", { fg = c.statusline_fg, bg = c.statusline_bg })
  hi("StatusLineTermNC", { fg = c.gray_fg, bg = c.inactive_bg })
  hi("SLNCIndicator", { fg = c.gray_fg, bg = c.tabline_bg })

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
function M.active_line()
  local config = require("modules.config").get()

  ---@type string[]
  local stl = {} -- 'stl' for 'statusline'

  -- Component: Mode
  local mode = vim.api.nvim_get_mode().mode
  local mode_hl, sep_hl = get_mode_hl(mode)

  stl[#stl + 1] = "%#" .. sep_hl .. "#" .. space -- one space indent
  stl[#stl + 1] = "%#" .. sep_hl .. "#" .. left_separator
  stl[#stl + 1] = "%#" .. mode_hl .. "# " .. modes.current_mode(mode)
  stl[#stl + 1] = " %#" .. sep_hl .. "#" .. right_separator .. space

  -- Component: Filetype and icons
  stl[#stl + 1] = "%#StatusLine#" .. bufname.get_buffer_name()
  stl[#stl + 1] = buficon.get_file_icon()

  -- Component: errors and warnings -> requires ALE
  if config.ale_diagnostics then
    stl[#stl + 1] = ale.diagnostics()
  end

  -- Component: Native Nvim LSP Diagnostic
  if config.lsp_diagnostics then
    stl[#stl + 1] = lsp.diagnostics()
  end

  -- TODO: SUPPORT COC LATER, NEEDS TESTING WITH COC USERS FIRST
  -- stl[#stl + 1] = M.cocStatus()

  -- Component: git commit stats -> REQUIRES SIGNIFY
  stl[#stl + 1] = signify.signify()

  -- Component: git branch name
  stl[#stl + 1] = git_branch.branch()

  -- Component: Lsp Progress
  if not package.loaded["fidget"] then
    stl[#stl + 1] = lsp.lsp_progress()
  end
  stl[#stl + 1] = "%#Statusline_LSP_Func# " .. lsp.lightbulb()

  --
  -- RIGHT SIDE INFO
  --
  -- Alignment to left
  stl[#stl + 1] = "%="

  -- Component: LSP CURRENT FUCTION --> Requires LSP
  if config.function_tip then
    stl[#stl + 1] = "%#Statusline_LSP_Func# " .. lsp_function.get_current_function()
  end

  -- Scrollbar
  -- stl[#stl + 1] = "%#StatusLine#" .. vim.call('Scrollbar') .. space

  -- Component: Modified, Read-Only, Filesize, Row/Col
  stl[#stl + 1] = "%#StatusLine#" .. bufmod.is_buffer_modified()
  stl[#stl + 1] = editable.editable()
  stl[#stl + 1] = filesize.get_file_size()
  stl[#stl + 1] = [[ʟ %l/%L c %c]] .. space

  return table.concat(stl)
end

----------------------------------------------------------------------
--                              Simple                              --
----------------------------------------------------------------------

---Statusline for simple buffers such as NvimTree
---where you don't need mode indicators etc
---@param bufnr integer
---@return string
function M.simple_line(bufnr)
  local filename = bufname.get_buffer_name(bufnr)

  ---@type string[]
  local stl = {}
  stl[#stl + 1] = "%#SLModeSepNormal#" .. space -- one space indent
  stl[#stl + 1] = "%#SLModeSepNormal#" .. left_separator
  stl[#stl + 1] = "%#SLModeNormal# " .. "View"
  stl[#stl + 1] = " %#SLModeSepNormal#" .. right_separator .. space
  stl[#stl + 1] = "%#StatusLine#"

  if filename:find("NvimTree") then
    stl[#stl + 1] = "Explorer" .. space .. ""
  elseif filename:find("OUTLINE") then
    stl[#stl + 1] = "Outline" .. space .. ""
  else -- fallback
    return M.active_line()
  end

  return table.concat(stl)
end

------------------------------------------------------------------------
--                              Inactive                              --
------------------------------------------------------------------------

---INACTIVE FUNCTION DISPLAY
---@param bufnr integer
---@return string
function M.inactive_line(bufnr)
  return space
    .. bufname.get_buffer_name(bufnr)
    .. buficon.get_file_icon(bufnr)
    .. "%#SLNCIndicator#[INACTIVE]%#StatusLineNC#"
end

return M
