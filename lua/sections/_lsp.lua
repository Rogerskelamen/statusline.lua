local M = {}

local uv = vim.uv or vim.loop
-- singleton timer
local redraw_timer = nil
local space = " "

function M.has_fidget()
  return package.loaded["fidget"] ~= nil
end

function M.current_function()
  local lsp_function = vim.b.lsp_current_function
  if lsp_function == nil or lsp_function == "" then
    return ""
  end
  return "󰊕" .. space .. lsp_function .. space
end

---Get diagnostics info from the buffer
---@param bufnr? integer
---@return table<string, integer>?
local function get_diagnostic_counts(bufnr)
  bufnr = bufnr or 0

  -- vim.diagnostics (Neovim ≥ 0.6)
  if vim.diagnostic then
    local severity = vim.diagnostic.severity
    return {
      error = #vim.diagnostic.get(bufnr, { severity = severity.ERROR }),
      warn = #vim.diagnostic.get(bufnr, { severity = severity.WARN }),
      info = #vim.diagnostic.get(bufnr, { severity = severity.INFO }),
      hint = #vim.diagnostic.get(bufnr, { severity = severity.HINT }),
    }
  end

  -- vim.lsp.diagnostics (Neovim 0.5)
  if vim.lsp and vim.lsp.diagnostic then
    return {
      error = vim.lsp.diagnostic.get_count(bufnr, "Error"),
      warn = vim.lsp.diagnostic.get_count(bufnr, "Warning"),
      info = vim.lsp.diagnostic.get_count(bufnr, "Information"),
      hint = vim.lsp.diagnostic.get_count(bufnr, "Hint"),
    }
  end

  return nil
end

-- icons      
---@return string
function M.diagnostics()
  local counts = get_diagnostic_counts(0)
  if not counts then
    return ""
  end

  local parts = {}
  if counts.error > 0 then
    table.insert(parts, " " .. counts.error .. space)
  end

  if counts.warn > 0 then
    table.insert(parts, " " .. counts.warn .. space)
  end

  if counts.info > 0 then
    table.insert(parts, " " .. counts.info .. space)
  end

  if counts.hint > 0 then
    table.insert(parts, " " .. counts.hint .. space)
  end

  return table.concat(parts)
end

local function stop_statusline_timer()
  if redraw_timer then
    redraw_timer:stop()
    redraw_timer:close()
    redraw_timer = nil
  end
end

local function start_statusline_timer()
  if redraw_timer then
    return
  end

  redraw_timer = uv.new_timer()

  redraw_timer:start(
    0,
    120,
    vim.schedule_wrap(function()
      local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
      if get_clients and #get_clients({ bufnr = 0 }) > 0 then
        vim.cmd("redrawstatus")
      else
        stop_statusline_timer()
      end
    end))
end

local function format_messages(messages)
  local result = {}
  local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local ms = uv.hrtime() / 1000000
  local frame = math.floor(ms / 120) % #spinners
  local i = 1
  for _, msg in ipairs(messages) do
    -- Only display at most 2 progress messages at a time to avoid clutter
    if i < 3 then
      table.insert(result, (msg.percentage or 0) .. "%% " .. (msg.title or ""))
      i = i + 1
    end
  end
  return table.concat(result, space) .. space .. spinners[frame + 1]
end

-- REQUIRES LSP
function M.lsp_progress()
  local messages = {}

  if vim.lsp.status then
    local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    local clients = get_clients({ bufnr = 0 }) or {}

    for _, client in ipairs(clients) do
      local progress = client.progress
      if progress and type(progress) == "table" then
        local last
        for pmsg in progress do
          if pmsg and pmsg.value then
            last = pmsg.value
          end
        end

        if last then
          table.insert(messages, last)
        end
      end
    end
  else
    -- fallback for nvim < 0.10
    messages = vim.lsp.util.get_progress_messages()
  end

  if #messages == 0 then
    return ""
  end

  return space .. format_messages(messages)
end

-- REQUIRES NVIM LIGHTBULB
function M.lightbulb()
  local has_lightbulb, lightbulb = pcall(require, "nvim-lightbulb")
  if not has_lightbulb then
    return ""
  end

  if lightbulb.get_status_text() ~= "" then
    return "" .. space
  else
    return ""
  end
end

-- Start spinner/statusline auto refresh
local lsp_group = vim.api.nvim_create_augroup("StatuslineLspGroup", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function()
    if not M.has_fidget() then
      start_statusline_timer()
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = lsp_group,
  callback = function()
    local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    if not get_clients or #get_clients() == 0 then
      stop_statusline_timer()
    end
  end,
})

return M
