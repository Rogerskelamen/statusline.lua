local M = {}

-- ALE style diagnostics from vim.diagnostic (Lua version of LinterStatus)
function M.diagnostics()
  local diagnostics = vim.diagnostic.get(0)

  if not diagnostics or #diagnostics == 0 then
    return ""
  end

  local e, w = 0, 0

  for _, d in ipairs(diagnostics) do
    if d.severity == vim.diagnostic.severity.ERROR then
      e = e + 1
    elseif d.severity == vim.diagnostic.severity.WARN then
      w = w + 1
    end
  end

  local s = ""
  local space = " "

  if e > 0 then
    s = s .. " " .. e .. space
  end
  if w > 0 then
    s = s .. " " .. w .. space
  end

  return s
end

return M
