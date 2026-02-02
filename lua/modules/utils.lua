local uv = vim.uv or vim.loop

local M = {}

---@param path string
---@return boolean
function M.is_dir(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory" or false
end

---For example: utils.has_version(9) -> >=0.9?
---@param minor integer
---@return boolean
function M.has_version(minor)
  return vim.version().minor >= minor
end

return M
