-- Fuzzy Finder (files, lsp, etc)
---@module 'lazy'
---@type LazySpec
return {
  'nvim-telescope/telescope.nvim',
  -- By default, Telescope is included and acts as your picker for everything.

  -- If you would like to switch to a different picker (like snacks, or fzf-lua)
  -- you can disable the Telescope plugin by setting enabled to false and enable
  -- your replacement picker by requiring it explicitly (e.g. 'custom.plugins.snacks')
  enabled = true,
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      defaults = {
        -- Collapse intermediate directories to their first letter, keeping the
        -- root directory and filename readable:
        --   ui/s/p/n/w/Queue/Queue.tsx  instead of
        --   ui/src/processes/ngs/wgs-extraction/Queue/Queue.tsx
        -- {1, -1} excludes the first and last path segments from shortening.
        path_display = { shorten = { len = 1, exclude = { 1, -1 } } },
        mappings = {
          i = (function()
            -- Refine current results AND show the search chain as a
            -- `term1 > term2 >` breadcrumb in the prompt prefix.
            -- <C-s> and <C-g> both do this; <C-s> is the macOS-friendly key
            -- since <C-Space> (the built-in refine) gets swallowed as the
            -- "previous input source" shortcut.
            local refine_with_breadcrumb = function(bufnr)
              require('telescope.actions.generate').refine(bufnr, {
                prompt_to_prefix = true,
                sorter = require('telescope.config').values.generic_sorter {},
              })
            end
            return {
              ['<C-g>'] = refine_with_breadcrumb,
              ['<C-s>'] = refine_with_breadcrumb,
            }
          end)(),
        },
      },
      -- pickers = {}
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', function() builtin.find_files { hidden = true, file_ignore_patterns = { 'node_modules' } } end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function() builtin.live_grep { additional_args = { '--hidden' } } end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sG', function()
      builtin.grep_string { search = vim.fn.input 'Grep For > ', use_regex = true }
    end, { desc = '[S]earch by [G]rep (regex prompt, then filter)' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- greatest remap ever
    vim.keymap.set('x', '<leader>p', '"_dP', { desc = '[P]aste without overwriting register' })

    -- - Scratch files (WebStorm style)
    -- Files live in ~/Documents/projects/scratch, and are named by the current date and time.
    local function new_scratch(ext)
      ext = (ext == nil or ext == '') and 'txt' or ext
      local dir = vim.fn.expand('~/Documents/projects/scratch/' .. ext)
      vim.fn.mkdir(dir, 'p')
      vim.cmd.edit(dir .. '/scratch-' .. os.date '%Y-%m-%d-%H-%M-%S' .. '.' .. ext)
    end

    -- Generic, Tab-completes: :Scratch ts | json | txt | md | ...
    vim.api.nvim_create_user_command('Scratch', function(o) new_scratch(o.args) end, {
      nargs = '?',
      complete = function() return { 'ts', 'js', 'json', 'txt', 'md', 'lua', 'py', 'sh' } end,
      desc = 'New scratch file (default: txt)',
    })

    -- Per-type convenience commands
    -- Usage:
    --  :Scratch json, :Scratch txt, :Scratch ts (or just :Scratch -> .txt) - Tab completes the type
    --  :ScratchTs / :ScratchJson / :ScratchTxt - direct
    vim.api.nvim_create_user_command('ScratchTs', function() new_scratch 'ts' end, { desc = 'New scratch TypeScript file' })
    vim.api.nvim_create_user_command('ScratchJson', function() new_scratch 'json' end, { desc = 'New scratch JSON file' })
    vim.api.nvim_create_user_command('ScratchTxt', function() new_scratch 'txt' end, { desc = 'New scratch text file' })

    -- Run the current file (TS/JS) with tsx, output in a split terminal
    -- :ScratchRun - runs the current TS/JS scratch
    vim.api.nvim_create_user_command('ScratchRun', function()
      vim.cmd 'write'
      vim.cmd('split | terminal npx tsx ' .. vim.fn.shellescape(vim.fn.expand '%'))
    end, { desc = 'Run current file with tsx in a split terminal' })

    -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
    -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
      callback = function(event)
        local buf = event.buf

        -- Find references for the word under your cursor.
        vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

        -- Jump to the implementation of the word under your cursor.
        -- Useful when your language has ways of declaring types without an actual implementation.
        vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

        -- Jump to the definition of the word under your cursor.
        -- This is where a variable was first declared, or where a function is defined, etc.
        -- To jump back, press <C-t>.
        vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

        -- Fuzzy find all the symbols in your current document.
        -- Symbols are things like variables, functions, types, etc.
        vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

        -- Fuzzy find all the symbols in your current workspace.
        -- Similar to document symbols, except searches over your entire project.
        vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

        -- Jump to the type of the word under your cursor.
        -- Useful when you're not sure what type a variable is and you want to see
        -- the definition of its *type*, not where it was *defined*.
        vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
      end,
    })

    -- Override default behavior and theme when searching
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set(
      'n',
      '<leader>s/',
      function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      { desc = '[S]earch [/] in Open Files' }
    )

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
  end,
}
