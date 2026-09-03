-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = false, -- Text shows up at the end of the line (gets clipped when long)
  virtual_lines = { current_line = true }, -- Full message underneath the cursor's line

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Auto-indent (reindent) the whole file, keeping the cursor in place
vim.keymap.set('n', '<leader>i', function()
  local view = vim.fn.winsaveview()
  vim.cmd 'normal! gg=G'
  vim.fn.winrestview(view)
end, { desc = '[I]ndent whole file' })

-- Reindent the current visual selection
vim.keymap.set('v', '<leader>i', '=', { desc = '[I]ndent selection' })

-- Move selected block up/down in Visual Mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Open netrw file explorer
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open file e[x]plorer (netrw)' })

-- Reindent the current paragraph, keeping the cursor in place
vim.keymap.set('n', '<leader>ip', function()
  local view = vim.fn.winsaveview()
  vim.cmd 'normal! =ip'
  vim.fn.winrestview(view)
end, { desc = '[I]ndent [P]aragraph' })

-- [[ Autosave ]]
-- Write modified, named, normal buffers on focus loss, buffer switch,
-- and after a pause in insert/normal mode. Toggle with <leader>ta.
vim.g.autosave_enabled = true

local function autosave(buf)
  if not vim.g.autosave_enabled then return end
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= '' then return end
  if not vim.bo[buf].modifiable or vim.bo[buf].readonly then return end
  if not vim.bo[buf].modified then return end
  if vim.api.nvim_buf_get_name(buf) == '' then return end
  vim.api.nvim_buf_call(buf, function()
    vim.cmd 'silent! write'
  end)
end

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertLeave', 'TextChanged' }, {
  desc = 'Autosave the current buffer',
  group = vim.api.nvim_create_augroup('user-autosave', { clear = true }),
  callback = function(ev)
    autosave(ev.buf)
  end,
})

vim.keymap.set('n', '<leader>ta', function()
  vim.g.autosave_enabled = not vim.g.autosave_enabled
  vim.notify('Autosave ' .. (vim.g.autosave_enabled and 'enabled' or 'disabled'))
end, { desc = '[T]oggle [A]utosave' })

-- [[ Quickfix list ]]
-- Populate: Telescope <C-q> sends results to qf; :vimgrep, :make, LSP diagnostics
-- (<leader>q above) also write to it. These keymaps navigate and manage the list.

-- Navigate items
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix item' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']Q', '<cmd>clast<CR>zz', { desc = 'Last quickfix item' })
vim.keymap.set('n', '[Q', '<cmd>cfirst<CR>zz', { desc = 'First quickfix item' })

-- Open / close the quickfix window
vim.keymap.set('n', '<leader>xq', '<cmd>copen<CR>', { desc = 'Open quickfi[x] list' })
vim.keymap.set('n', '<leader>xQ', '<cmd>cclose<CR>', { desc = 'Close quickfi[x] list' })

-- Quickfix history (cycle through previous :vimgrep / :make results)
vim.keymap.set('n', '<leader>xn', '<cmd>cnewer<CR>', { desc = 'Newer quickfix list' })
vim.keymap.set('n', '<leader>xp', '<cmd>colder<CR>', { desc = 'Older quickfix list' })

-- Save the current search (/) as a quickfix list via :vimgrep
vim.keymap.set('n', '<leader>xs', function()
  local pattern = vim.fn.getreg '/'
  if pattern == '' then
    vim.notify('No search pattern to save', vim.log.levels.WARN)
    return
  end
  -- vimgrep the current search across every line of the current buffer
  local ok, err = pcall(vim.cmd, 'vimgrep /' .. vim.fn.escape(pattern, '/') .. '/gj %')
  if ok then
    vim.cmd 'copen'
    vim.notify('Search saved to quickfix: ' .. pattern)
  else
    vim.notify('No matches: ' .. tostring(err), vim.log.levels.WARN)
  end
end, { desc = 'Save [s]earch to quickfix' })

-- Location list (per-window, used by LSP diagnostics via <leader>q above)
vim.keymap.set('n', ']l', '<cmd>lnext<CR>zz', { desc = 'Next location list item' })
vim.keymap.set('n', '[l', '<cmd>lprev<CR>zz', { desc = 'Previous location list item' })
vim.keymap.set('n', '<leader>xl', '<cmd>lopen<CR>', { desc = 'Open location list' })
vim.keymap.set('n', '<leader>xL', '<cmd>lclose<CR>', { desc = 'Close location list' })
