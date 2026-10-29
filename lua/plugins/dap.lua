-- Debugging with nvim-dap (Go via delve, Lua via local-lua-debugger).
local gh = require('config.pack').gh

local lua_runtime = 'lua5.1' -- plain-Lua interpreter; e.g. 'lua', 'luajit'

do
  vim.pack.add({
    gh 'mfussenegger/nvim-dap',
    gh 'rcarriga/nvim-dap-ui',
    gh 'nvim-neotest/nvim-nio',
    gh 'leoluz/nvim-dap-go',
    gh 'tomblind/local-lua-debugger-vscode',
  }, { confirm = false })

  local dap = require 'dap'
  local dapui = require 'dapui'
  require('dap-go').setup {}

  -- Lua adapter: built copy inside the plugin dir (see config/pack.lua build hook).
  local debugger_dir = vim.fn.stdpath 'data' .. '/site/pack/core/opt/local-lua-debugger-vscode'
  dap.adapters['local-lua'] = {
    type = 'executable',
    command = 'node',
    args = { debugger_dir .. '/extension/debugAdapter.js' },
    enrich_config = function(config, on_config)
      if not config.extensionPath then
        local cfg = vim.deepcopy(config)
        cfg.extensionPath = debugger_dir
        on_config(cfg)
      else
        on_config(config)
      end
    end,
  }
  dap.configurations.lua = {
    {
      name = 'current file',
      type = 'local-lua',
      request = 'launch',
      cwd = '${workspaceFolder}',
      program = { lua = lua_runtime, file = '${file}' },
      args = {},
    },
  }

  dapui.setup {}
  dap.listeners.after.event_initialized['dapui'] = function() dapui.open {} end
  dap.listeners.before.event_terminated['dapui'] = function() dapui.close {} end
  dap.listeners.before.event_exited['dapui'] = function() dapui.close {} end

  local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { desc = desc }) end
  map('<leader>db', dap.toggle_breakpoint, 'toggle breakpoint')
  map('<leader>dc', dap.continue, 'continue')
  map('<leader>di', dap.step_into, 'step into')
  map('<leader>do', dap.step_over, 'step over')
  map('<leader>dO', dap.step_out, 'step out')
  map('<leader>dr', dap.repl.toggle, 'toggle repl')
  map('<leader>dt', dap.terminate, 'terminate')
  map('<leader>du', dapui.toggle, 'toggle ui')
end
