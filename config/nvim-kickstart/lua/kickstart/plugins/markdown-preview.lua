return {

  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
  ft = { 'markdown' },
  build = 'cd app && npm install',
  init = function()
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_refresh_slow = 1
  end,
  keys = {
    { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Toggle Markdown Preview' },
  },
}
