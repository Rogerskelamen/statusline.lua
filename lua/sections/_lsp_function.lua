local M = {}

M.current_function = ""
M.symbols_cache = nil

---@param bufnr? integer
local function fetch_symbols(bufnr)
  bufnr = bufnr or 0

  -- Check current buffer has lsp capability
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if not client.server_capabilities.documentSymbolProvider then
      return
    end
  end

  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
    textDocument = vim.lsp.util.make_text_document_params(),
  }, function(err, result)
    if err or not result then
      return
    end

    M.symbols_cache = result
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

local function update_current_function()
  if not M.symbols_cache then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1] - 1
  local col = pos[2]

  local symbol = find_symbol(M.symbols_cache, row, col)

  if symbol and symbol.kind == 12 then -- 12 = Function
    M.current_function = "󰊕 " .. symbol.name .. " "
  else
    M.current_function = ""
  end

  vim.cmd("redrawstatus")
end

vim.api.nvim_create_autocmd({ "CursorHold", "BufEnter" }, {
  callback = function()
    fetch_symbols()
    update_current_function()
  end,
})

return M
