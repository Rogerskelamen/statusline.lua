--
-- neoclide/coc.nvim
--

local M = {}

function M.cocStatus()
  local ok, status = pcall(vim.fn["coc#status"])
  return ok and status or ""
end

return M
