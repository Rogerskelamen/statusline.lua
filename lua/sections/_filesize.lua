local space = " "
local uv = vim.uv or vim.loop

local M = {}

local units = { "B", "KB", "MB", "GB", "TB" }

---Return stardard file size with human units
---@param bytes integer
---@return string
local function human_size(bytes)
  if not bytes or bytes <= 0 then
    return ""
  end

  local i = 1
  while bytes >= 1024 and i < #units do
    bytes = bytes / 1024
    i = i + 1
  end

  if i == 1 then
    -- B: no decimal
    return string.format("%d%s", bytes, units[i])
  else
    -- >= KB: leave one decimal number
    return string.format("%d%s", bytes, units[i])
  end
end

---Get file size of current buffer
---@param bufnr? integer
---@return string
function M.get_file_size(bufnr)
  bufnr = bufnr or 0

  -- special buffer
  local bo = vim.bo[bufnr]
  if bo.buftype ~= "" then
    return ""
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return ""
  end

  local stat = uv.fs_stat(name)
  if not stat or not stat.size then
    return ""
  end

  return human_size(stat.size) .. space
end

return M
