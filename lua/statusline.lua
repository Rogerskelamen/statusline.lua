--[[
   _____  ______    ___   ______   __  __   _____    __     ____    _   __    ______
  / ___/ /_  __/   /   | /_  __/  / / / /  / ___/   / /    /  _/   / | / /   / ____/
  \__ \   / /     / /| |  / /    / / / /   \__ \   / /     / /    /  |/ /   / __/
 ___/ /  / /     / ___ | / /    / /_/ /   ___/ /  / /___ _/ /    / /|  /   / /___
/____/  /_/     /_/  |_|/_/     \____/   /____/  /_____//___/   /_/ |_/   /_____/
--]]
------------------------------------------------------------------------
--                             Variables                              --
------------------------------------------------------------------------

local config = require("modules.config")
local statusline = require("modules.statusline")
local tabline = require("modules.tabline")
local M = {}

---@type integer
local statusline_group = vim.api.nvim_create_augroup("StatuslineGroup", { clear = true })

------------------------------------------------------------------------
--                              Init                                  --
------------------------------------------------------------------------
---Setup for statusline
---@param user_config StatuslineConfig
function M.setup(user_config)
  config.setup(user_config)
  statusline.set_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = statusline_group,
    callback = function()
      statusline.set_highlights()
    end,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = statusline_group,
    callback = function()
      M.activeLine()
    end,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = statusline_group,
    callback = function()
      M.inActiveLine()
    end,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinLeave", "BufLeave" }, {
    group = statusline_group,
    pattern = "NvimTree",
    callback = function()
      M.simpleLine()
    end,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = statusline_group,
    callback = function()
      M.tabline_init()
    end,
  })
end

------------------------------------------------------------------------
--                              Statusline                            --
------------------------------------------------------------------------
function M.activeLine()
  if config.get().lsp_diagnostics == true then
    vim.wo.statusline = "%!v:lua.require'modules.statusline'.wants_lsp()"
  elseif config.get().ale_diagnostics == true then
    vim.wo.statusline = "%!v:lua.require'modules.statusline'.wants_ale()"
  else
    vim.wo.statusline = "%!v:lua.require'modules.statusline'.activeLine()"
  end
end

function M.simpleLine()
  vim.wo.statusline = statusline.simpleLine()
end

------------------------------------------------------------------------
--                              Inactive                              --
------------------------------------------------------------------------

function M.inActiveLine()
  vim.wo.statusline = statusline.inActiveLine()
end

------------------------------------------------------------------------
--                        Tabline Config                              --
------------------------------------------------------------------------
M.tabline_init = function()
  if config.get().tabline == true then
    vim.o.tabline = tabline.init()
  end
end

return M
