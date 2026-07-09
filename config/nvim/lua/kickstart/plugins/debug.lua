-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

-- Toggle ALL breakpoints on/off at once. nvim-dap has no native "disable all",
-- so we snapshot every breakpoint and clear them on the first press, then
-- restore the snapshot on the next press.
local saved_breakpoints = nil
local function toggle_all_breakpoints()
  local bp = require 'dap.breakpoints'
  local current = bp.get()
  local count = 0
  for _, list in pairs(current) do
    count = count + #list
  end

  if count > 0 then
    saved_breakpoints = current
    require('dap').clear_breakpoints()
    vim.notify(('DAP: disabled %d breakpoint(s)'):format(count))
  elseif saved_breakpoints then
    local restored = 0
    for bufnr, list in pairs(saved_breakpoints) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        for _, b in ipairs(list) do
          bp.set({ condition = b.condition, hit_condition = b.hitCondition, log_message = b.logMessage }, bufnr, b.line)
          restored = restored + 1
        end
      end
    end
    saved_breakpoints = nil
    vim.notify(('DAP: re-enabled %d breakpoint(s)'):format(restored))
  else
    vim.notify 'DAP: no breakpoints to toggle'
  end
end

---@module 'lazy'
---@type LazySpec
return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
    { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Breakpoint' },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    { '<F7>', function() require('dapui').toggle() end, desc = 'Debug: See last session result.' },
    -- End the session and close all debugger windows in one go.
    {
      '<leader>dq',
      function()
        require('dap').terminate()
        require('dapui').close()
      end,
      desc = 'Debug: Quit (end session + close UI)',
    },
    {
      '<leader>?',
      function() require('dapui').eval(nil, { enter = true }) end,
      mode = { 'n', 'v' },
      desc = 'Debug: Eval expr / selection (float)',
    },
    {
      '<leader>dw',
      function()
        vim.cmd 'noautocmd normal! "vy'
        require('dapui').elements.watches.add(vim.fn.getreg 'v')
      end,
      mode = 'v',
      desc = 'Debug: Watch selection',
    },
    -- List all breakpoints in the quickfix list.
    {
      '<leader>dl',
      function() require('dap').list_breakpoints(true) end,
      desc = 'Debug: List breakpoints (quickfix)',
    },
    -- Disable every breakpoint at once; press again to re-enable them.
    {
      '<leader>dx',
      toggle_all_breakpoints,
      desc = 'Debug: Toggle ALL breakpoints on/off',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      -- Wider left sidebar (60 cols) so long scope values / stack paths aren't clipped.
      layouts = {
        {
          position = 'left',
          size = 60,
          elements = {
            { id = 'scopes', size = 0.4 },
            { id = 'breakpoints', size = 0.2 },
            { id = 'stacks', size = 0.2 },
            { id = 'watches', size = 0.2 },
          },
        },
        {
          position = 'bottom',
          size = 10,
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
        },
      },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    -- Make the line where the debugger is currently stopped clearly visible.
    -- (nvim-dap's default DapStopped sign has no linehl, so the stopped line
    -- otherwise blends in.) Re-applied on ColorScheme so a theme switch can't
    -- clear it.
    local function set_dap_stopped_hl()
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#553d1a', ctermbg = 'darkyellow' })
    end
    set_dap_stopped_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = set_dap_stopped_hl })
    vim.fn.sign_define('DapStopped', {
      text = '→',
      texthl = 'DiagnosticWarn',
      linehl = 'DapStoppedLine',
      numhl = 'DapStoppedLine',
    })

    -- Make breakpoints stand out with a bold red icon (icon only, no line tint).
    -- Re-applied on ColorScheme so a theme switch can't clear the colors.
    local function set_dap_break_hl()
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400', bold = true, ctermfg = 'red' })
    end
    set_dap_break_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = set_dap_break_hl })

    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆' }
    for type, icon in pairs(breakpoint_icons) do
      vim.fn.sign_define('Dap' .. type, {
        text = icon,
        texthl = 'DapBreak',
        numhl = 'DapBreak',
      })
    end

    -- Wrap long lines in the DAP panels so values/paths aren't truncated.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'dapui_scopes', 'dapui_stacks', 'dapui_watches', 'dapui_breakpoints', 'dap-repl' },
      callback = function() vim.opt_local.wrap = true end,
    })

    -- On quitting Neovim, tear down any live session + close the UI so no
    -- orphaned debug adapter/inspector connection is left running.
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        pcall(function() dap.terminate() end)
        pcall(function() dapui.close() end)
      end,
    })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- JavaScript / TypeScript (Node.js) via Microsoft's js-debug adapter.
    -- The `js-debug-adapter` binary is installed by Mason and lives on PATH.
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'js-debug-adapter',
        args = { '${port}' },
      },
    }

    -- Launch/attach configurations shared by JS and TS (incl. React variants).
    for _, language in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
      dap.configurations[language] = {
        {
          -- Run the file you're editing directly with tsx (handles TS + source maps).
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch current file (tsx)',
          runtimeExecutable = 'tsx',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
        },
        {
          -- Attach to a Node process already running with --inspect=<port>.
          -- lims-clws server uses `npm run start:debug` -> --inspect=32701.
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to port',
          port = function() return tonumber(vim.fn.input 'Inspector port: ' or 9229) end,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
        },
        {
          -- Attach by picking a running Node process from a list.
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process (pick)',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' },
        },
      }
    end
  end,
}
