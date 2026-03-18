local M = {}

---@class StatuslineConfig
---@field global boolean
---@field match_colorscheme boolean
---@field tabline boolean
---@field diagnostics "lsp" | "ale"
---@field function_tip boolean
---@field scrollbar boolean

---@type StatuslineConfig
local defaults = {
  global = false,
  match_colorscheme = false,
  tabline = true,
  diagnostics = "lsp",
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
