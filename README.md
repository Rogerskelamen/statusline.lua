# Statusline.lua

This is a fork and fully refactored version of [beauwilliams' statusline](https://github.com/beauwilliams/statusline.lua).

I made a lot of modifications while remaining the beautiful design:

🪟 Windows OS compatible

🖥️ Proper display in terminal mode

⚙️ A modern Lua rebuild

📃 A better format style for [stylua](https://github.com/JohnnyMorganz/StyLua)

🚀 Maybe a little speed-up?

Want more details of original project? Refer to [here](https://github.com/beauwilliams/statusline.lua).

## Installation

```lua
-- lazy.nvim
{
    "Rogerskelamen/statusline.lua",
    config = true, -- if you don't need any custom config
}
```

## Default Configuration

```lua
require("statusline").setup({
  global = false, -- enable global statusline (v0.7+)
  match_colorscheme = false, -- use the highlights of your colorscheme
  tabline = true, -- let this plugin control your tabline
  diagnostics = "lsp", -- how to display diagnostic info. "lsp" | "ale"
  function_tip = false, -- show the function name at current cursor
  scrollbar = false, -- enable scrollbar marker for current line location
})
```

## Buffer Support

- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

- [outline.nvim](https://github.com/hedyhli/outline.nvim)

- [Telescope](https://github.com/nvim-telescope/telescope.nvim)

# Credits

All credits goes to beauwilliams. This plugin fork from a free project which is under MIT License.
