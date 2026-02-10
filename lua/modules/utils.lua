local uv = vim.uv or vim.loop
local api = vim.api

local M = {}

---@param path string
---@return boolean
function M.is_dir(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory" or false
end

---Simulate vim's `:hi` command, merge existing hl with given hl
---@param hl_name string
---@param hl_val vim.api.keyset.highlight
function M.hi(hl_name, hl_val)
  local hl_base = api.nvim_get_hl(0, { name = hl_name, link = false })
  hl_val = vim.tbl_extend("force", hl_base, hl_val)
  api.nvim_set_hl(0, hl_name, hl_val)
end

---For example: utils.has_version(9) -> >=0.9?
---@param minor integer
---@return boolean
function M.has_version(minor)
  return vim.version().minor >= minor
end

return M
