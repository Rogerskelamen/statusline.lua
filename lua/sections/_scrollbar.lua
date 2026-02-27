local M = {}

-- Unicode blocks（low to high）
local blocks = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

-- Default width
M.width = 8

function M.get()
  local current = vim.fn.line(".")
  local total = vim.fn.line("$")

  if total <= 1 then
    return string.rep("█", M.width)
  end

  local ratio = (current - 1) / (total - 1)
  ratio = math.min(math.max(ratio, 0), 1)

  -- For first line
  if ratio == 0 then
    return blocks[1] .. string.rep(" ", M.width - 1)
  end

  -- Compute filling number
  local fill = ratio * M.width
  local full = math.floor(fill)
  local frac = fill - full

  local bar = string.rep("█", full)

  -- a imperfect block to present a percentage view（if not full）
  if full < M.width then
    if frac > 0 then
      local idx = math.floor(frac * (#blocks - 1)) + 1
      bar = bar .. blocks[idx]
      -- Add end space
      bar = bar .. string.rep(" ", M.width - full - 1)
    else
      bar = bar .. string.rep(" ", M.width - full)
    end
  end

  return bar
end

return M
