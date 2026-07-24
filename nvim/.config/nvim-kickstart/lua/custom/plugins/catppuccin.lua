-- Colorscheme.
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
---@module 'lazy'
---@type LazySpec
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha', -- latte, frappe, macchiato, mocha
      float = {
        transparent = true, -- enable transparent floating windows
      },
    }

    -- Load the colorscheme here.
    vim.cmd.colorscheme 'catppuccin-mocha'

    -- Make line numbers easier to read: brighter gutter numbers, and a bold
    -- accent for the current line. Re-applied on ColorScheme so a theme
    -- switch can't reset it.
    local function brighten_line_numbers()
      vim.api.nvim_set_hl(0, 'LineNr', { fg = '#9399b2' })
      vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#f9e2af', bold = true })
    end
    brighten_line_numbers()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = brighten_line_numbers })
  end,
}
