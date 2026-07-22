-- Sticky header that pins the enclosing function/class/block of the current
-- line at the top of the window, so you always know which method the cursor is
-- in. Powered by treesitter (already installed by kickstart).
--
-- `[x` jumps up to the context line shown at the top (handy for navigating out
-- of a deeply nested block).
return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('treesitter-context').setup {
      max_lines = 4, -- max number of context lines pinned at the top
      multiline_threshold = 1, -- collapse multi-line signatures to a single line
      trim_scope = 'outer', -- if over max_lines, drop the outermost contexts
      mode = 'cursor', -- track the context of the cursor, not the topmost line
      separator = '─', -- thin underline beneath the context
    }

    -- Brighten the line numbers shown in the pinned context header (the
    -- class/method lines at the top), matching the current-line accent.
    -- Re-applied on ColorScheme so a theme switch can't reset it.
    local function set_context_hl()
      vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', { fg = '#f9e2af', bold = true })
    end
    set_context_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = set_context_hl })
  end,
  keys = {
    {
      '[x',
      function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end,
      desc = 'Jump to conte[x]t (enclosing scope)',
    },
  },
}
