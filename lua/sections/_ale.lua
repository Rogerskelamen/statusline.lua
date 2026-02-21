--
-- dense-analysis/ale
--

local M = {}

-- Require ALE
-- Lua version of LinterStatus
function M.diagnostics()
  if vim.fn.exists("*ale#statusline#Count") == 0 then
    return ""
  end

  local ok, counts = pcall(vim.fn["ale#statusline#Count"], vim.api.nvim_get_current_buf())
  if not ok or not counts then
    return ""
  end

  local all_errors = (counts.error or 0) + (counts.style_error or 0)
  local total = counts.total or 0
  local all_non_errors = total - all_errors

  if all_errors == 0 then
    if all_non_errors ~= 0 then
      return string.format(" %d ", all_non_errors)
    end
  end

  if all_non_errors == 0 then
    if all_errors ~= 0 then
      return string.format(" %d ", all_errors)
    end
  end

  if total ~= 0 then
    return string.format(" %d  %d ", all_non_errors, all_errors)
  end

  return ""
end

return M
