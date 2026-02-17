--[[
   _____  ______   ___   ______  __  __  _____    __     ____   _   __   ______
  / ___/ /_  __/ /   | /_  __/ / / / / / ___/   / /    /  _/  / | / /  / ____/
  \__ \   / /   / /| |  / /   / / / /  \__ \   / /     / /   /  |/ /  / __/
 ___/ /  / /   / ___ | / /   / /_/ /  ___/ /  / /___ _/ /   / /|  /  / /___
/____/  /_/   /_/  |_|/_/    \____/  /____/  /_____//___/  /_/ |_/  /_____/

Render method selection: `%{}` vs `%!`, which one is better?
`%{}`: neovim only redraws statusline when computed value of the expression changed (AKA static)
`%!`: neovim will always redraw statusline every time UI has changed
So absolutely, `%{}` costs less, but it can't operate some flexible works sometimes.
For example, `%{}` can't get g:statusline_winid
Then the principle is: choose `%{}` only when your statusline is simple as hell,
                       and most of time, just sticking to `%!` will be fine.
--]]

local config = require("modules.config")
local statusline = require("modules.statusline")
local tabline = require("modules.tabline")

local M = {}

---@type boolean
local use_tabline = true

---Setup highlights for statusline and tabline
local function setup_hl()
  statusline.set_highlights()
  if use_tabline then
    tabline.set_tabline_hl()
  end
end

---
---Setup for statusline
---
---@param user_config StatuslineConfig
function M.setup(user_config)
  config.setup(user_config)
  use_tabline = config.get().tabline

  -- Disable line numbers in bottom right for our custom indicator as above
  vim.o.ruler = false
  vim.o.showcmd = false

  -- Set highlights
  setup_hl()

  -- Set Events
  ---@type integer
  local stl_group = vim.api.nvim_create_augroup("StatuslineGroup", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = stl_group,
    callback = function()
      setup_hl()
    end,
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = stl_group,
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  })

  -- Render
  function _G.__statusline_render()
    return require("modules.statusline").render()
  end
  vim.o.statusline = "%!v:lua.__statusline_render()"

  -- Tabline render
  if use_tabline then
    function _G.__tabline_render()
      return require("modules.tabline").render()
    end
    vim.o.tabline = "%{%v:lua.__tabline_render()%}"
  end
end

return M
