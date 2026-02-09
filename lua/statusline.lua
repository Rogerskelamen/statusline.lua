--[[
   _____  ______   ___   ______  __  __  _____    __     ____   _   __   ______
  / ___/ /_  __/ /   | /_  __/ / / / / / ___/   / /    /  _/  / | / /  / ____/
  \__ \   / /   / /| |  / /   / / / /  \__ \   / /     / /   /  |/ /  / __/
 ___/ /  / /   / ___ | / /   / /_/ /  ___/ /  / /___ _/ /   / /|  /  / /___
/____/  /_/   /_/  |_|/_/    \____/  /____/  /_____//___/  /_/ |_/  /_____/
--]]

local config = require("modules.config")
local statusline = require("modules.statusline")
local tabline = require("modules.tabline")

local M = {}

---
---Setup for statusline
---
---@param user_config StatuslineConfig
function M.setup(user_config)
  config.setup(user_config)
  local has_tabline = config.get().tabline

  -- Disable line numbers in bottom right for our custom indicator as above
  vim.o.ruler = false

  -- Set highlights
  statusline.set_highlights()
  if has_tabline then
    tabline.set_tabline_hl()
  end

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("StatuslineGroup", { clear = true }),
    callback = function()
      statusline.set_highlights()
      if has_tabline then
        tabline.set_tabline_hl()
      end
    end,
  })

  -- Render
  function _G.__statusline_render()
    return require("modules.statusline").render()
  end
  vim.o.statusline = "%{%v:lua.__statusline_render()%}"

  -- Tabline setup
  if has_tabline then
    function _G.__tabline_render()
      return require("modules.tabline").render()
    end
    vim.o.tabline = "%{%v:lua.__tabline_render()%}"
  end
end

return M
