---@module 'lazy'
---@type LazySpec
return {
  'folke/sidekick.nvim',
  opts = {
    -- add any options here
    cli = {
      win = {
        layout = 'float',
      },
      mux = {
        backend = 'tmux',
        enabled = true,
      },
    },
  },
  keys = {
    {
      '<tab>',
      function()
        if not require('sidekick').nes_jump_or_apply() then return '<Tab>' end
      end,
      expr = true,
      desc = 'Goto/Apply Next Edit Suggestion',
    },
    { '<leader>ac', function() require('sidekick.cli').focus() end, desc = 'Sidekick Focus CLI', mode = 'n' },
    { '<leader>ac', function() require('sidekick.cli').focus() end, desc = 'Sidekick Focus CLI', mode = 't' },
    {
      '<leader>aa',
      function() require('sidekick.cli').toggle() end,
      desc = 'Sidekick Toggle CLI',
    },
    {
      '<leader>as',
      function() require('sidekick.cli').select() end,
      desc = 'Sidekick Select CLI',
    },
    {
      '<leader>at',
      function() require('sidekick.cli').send { msg = '{this}' } end,
      mode = { 'x', 'n' },
      desc = 'Sidekick Send This',
    },
    {
      '<leader>af',
      function() require('sidekick.cli').send { msg = '{file}' } end,
      desc = 'Sidekick Send File',
    },
    {
      '<leader>av',
      function() require('sidekick.cli').send { msg = '{selection}' } end,
      mode = { 'x' },
      desc = 'Sidekick Send Selection',
    },
  },
}
