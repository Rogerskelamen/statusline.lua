--[[
   _____  ______   ___   ______  __  __  _____    __     ____   _   __   ______
  / ___/ /_  __/ /   | /_  __/ / / / / / ___/   / /    /  _/  / | / /  / ____/
  \__ \   / /   / /| |  / /   / / / /  \__ \   / /     / /   /  |/ /  / __/
 ___/ /  / /   / ___ | / /   / /_/ /  ___/ /  / /___ _/ /   / /|  /  / /___
/____/  /_/   /_/  |_|/_/    \____/  /____/  /_____//___/  /_/ |_/  /_____/
--]]

local config = require("modules.config")
local status_mod = require("modules.statusline")
local tabline = require("modules.tabline")

local M = {}

-- 局部状态，替代全局变量
local state = {
  diag_lsp = false,
  diag_ale = false,
}

-- ====== 现代 render 入口 ======
function M.render()
  local ft = vim.bo.filetype

  if ft == "NvimTree" then
    return status_mod.simpleLine()
  end

  if state.diag_lsp then
    return status_mod.activeLine(true, false)
  elseif state.diag_ale then
    return status_mod.activeLine(false, true)
  else
    return status_mod.activeLine(false, false)
  end
end

---
---Setup
---
---@param user_config StatuslineConfig
function M.setup(user_config)
  config.setup(user_config)
  local has_tabline = config.get().tabline

  -- Disable line numbers in bottom right for our custom indicator as above
  vim.o.ruler = false

  -- Set highlights
  status_mod.set_highlights()
  if has_tabline then
    tabline.set_tabline_hl()
  end

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      status_mod.set_highlights()
      if has_tabline then
        tabline.set_tabline_hl()
      end
    end,
  })

  -- Render
  _G.Statusline = M
  vim.o.statusline = "%{%v:lua.Statusline.render()%}"

  -- Tabline setup
  if has_tabline then
    _G.Tabline = tabline
    vim.o.tabline = "%{%v:lua.Tabline.render()%}"
  end
end

-- 给外部调用的接口（代替 wants_lsp/ale）
function M.use_lsp()
  state.diag_lsp = true
  state.diag_ale = false
end

function M.use_ale()
  state.diag_lsp = false
  state.diag_ale = true
end

return M
