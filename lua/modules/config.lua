local M = {}

---@class StatuslineConfig
---@field match_colorscheme boolean
---@field tabline boolean
---@field lsp_diagnostics boolean
---@field ale_diagnostics boolean
---@field function_tip boolean
---@field scrollbar boolean
local defaults = {
  match_colorscheme = false,
  tabline = true,
  lsp_diagnostics = true,
  ale_diagnostics = false,
  function_tip = false,
  scrollbar = false,
}

---@type StatuslineConfig
local _config = vim.deepcopy(defaults)

---@param user_config? StatuslineConfig
function M.setup(user_config)
  _config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config or {})
end

---@return StatuslineConfig
function M.get()
  return _config
end

return M
