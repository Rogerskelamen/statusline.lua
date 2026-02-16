local M = {}
local space = " "

---Get file name according to bufnr
---@param bufnr? integer
---@return string
function M.get_buffer_name(bufnr) --> IF We are in a buffer such as terminal or startify with no filename just display the buffer 'type' i.e "startify"
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  local filename = vim.fn.fnamemodify(name, ":t")
  local filetype = vim.bo[bufnr or 0].filetype

  if filename ~= "" then --> IF filetype empty i.e in a terminal buffer etc, return name of buffer (filetype)
    return filename .. space
  else
    if filetype ~= "" then
      return filetype .. space
    else
      return "" --> AFAIK buffers tested have types but just incase.
    end
  end
end
return M
