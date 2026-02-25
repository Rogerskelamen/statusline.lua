local config = require("modules.config")

local M = {}

M.symbols_cache = {}
M.current_function = {}

function M.get_current_function()
  local bufnr = vim.api.nvim_get_current_buf()
  return M.current_function[bufnr] or ""
end

---Check current buffer has lsp documentSymbol capability
---@param bufnr integer
---@return boolean
local function supports_document_symbol(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.server_capabilities.documentSymbolProvider then
      return true
    end
  end
  return false
end

---@param bufnr integer
local function fetch_symbols(bufnr)
  if not supports_document_symbol(bufnr) then
    return
  end

  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
    textDocument = vim.lsp.util.make_text_document_params(),
  }, function(err, result)
    if err or not result then
      return
    end

    M.symbols_cache[bufnr] = result
  end)
end

---@param range any
---@param row integer
---@param col integer
---@return boolean
local function in_range(range, row, col)
  local start_line = range.start.line
  local start_col = range.start.character
  local end_line = range["end"].line
  local end_col = range["end"].character

  if row < start_line or row > end_line then
    return false
  end

  if row == start_line and col < start_col then
    return false
  end

  if row == end_line and col > end_col then
    return false
  end

  return true
end

local function find_symbol(symbols, row, col)
  for _, symbol in ipairs(symbols or {}) do
    local range = symbol.range or (symbol.location and symbol.location.range)

    if range and in_range(range, row, col) then
      if symbol.children then
        local child = find_symbol(symbol.children, row, col)
        if child then
          return child
        end
      end
      return symbol
    end
  end
end

local function update_current_function(bufnr)
  local symbols = M.symbols_cache[bufnr]
  if not symbols then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1] - 1
  local col = pos[2]

  local symbol = find_symbol(symbols, row, col)

  local new_value = ""

  if symbol and (symbol.kind == 6 or symbol.kind == 12 or symbol.kind == 9) then
    new_value = "󰊕 " .. symbol.name .. " "
  end

  if new_value ~= M.current_function[bufnr] then
    M.current_function[bufnr] = new_value
    vim.cmd("redrawstatus")
  end
end

-- Setup
if config.get().function_tip then
  local group = vim.api.nvim_create_augroup("StatuslineLspFunction", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      fetch_symbols(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype ~= "" then
        return
      end
      update_current_function(bufnr)
    end,
  })
end

return M
