-- Git integration: blame, history, and opening changes on GitHub.
--  - vim-fugitive: :Git, :Git blame, :Gdiffsplit, :Gclog, etc.
--  - vim-rhubarb:  teaches :GBrowse to open/copy GitHub URLs for the
--                  current line, selection, or commit object.
return {
  'tpope/vim-fugitive',
  dependencies = { 'tpope/vim-rhubarb' },
  -- Lazy-load on the commands and keymaps below.
  cmd = { 'Git', 'GBrowse', 'Gdiffsplit', 'Gvdiffsplit', 'Gclog', 'Gread', 'Gwrite' },
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git Status' },
    { '<leader>ga', '<cmd>Git add %<cr>', desc = 'Git Add Current File' },
    { '<leader>gr', '<cmd>Git restore %<cr>', desc = 'Git Restore File' },
    { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git Blame' },
    { '<leader>gl', '<cmd>Git log<cr>', desc = 'Git Log' },
    { '<leader>gP', '<cmd>!git pull<cr>', desc = 'Git Pull' },
    { '<leader>go', '<cmd>GBrowse<cr>', mode = { 'n', 'x' }, desc = 'Git open on GitHub' },
    { '<leader>gy', '<cmd>GBrowse!<cr>', mode = { 'n', 'x' }, desc = 'Git copy GitHub link' },
    -- Merge-conflict resolution inside a 3-way diff (`:Gvdiffsplit!`).
    -- NOTE: these shadow the built-in `dh`/`dl` delete motions everywhere.
    { 'dh', '<cmd>diffget //2<cr>', desc = 'Diff Get Left (//2)' },
    { 'dl', '<cmd>diffget //3<cr>', desc = 'Diff Get Right (//3)' },
  },
}
