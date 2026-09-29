---@module 'lazy'
---@type LazySpec
return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = '<C-l>',
        dismiss = '<C-]>',
        next = '<M-]>',
        prev = '<M-[>',
      },
    },
    panel = { enabled = false },
  },
}
