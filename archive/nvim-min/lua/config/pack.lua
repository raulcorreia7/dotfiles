-- Native vim.pack setup, build hooks, and the shared GitHub helper.
-- `:lua vim.pack.update(nil, { offline = true })` lists pending updates.
do
  --- Run a plugin build step, notifying on failure.
  ---@param name string plugin name for error messages
  ---@param cmd string[] command and arguments
  ---@param cwd string working directory
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- One build function per plugin that needs it; adding a tool is one entry.
  ---@type table<string, fun(ev: table)>
  local builders = {
    ['telescope-fzf-native.nvim'] = function(ev)
      if vim.fn.executable 'make' == 1 then run_build('telescope-fzf-native.nvim', { 'make' }, ev.data.path) end
    end,
    LuaSnip = function(ev)
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build('LuaSnip', { 'make', 'install_jsregexp' }, ev.data.path) end
    end,
    ['blink.cmp'] = function(ev)
      if vim.fn.executable 'cargo' == 1 then run_build('blink.cmp', { 'cargo', 'build', '--release' }, ev.data.path) end
    end,
    ['local-lua-debugger-vscode'] = function(ev)
      if vim.fn.executable 'npm' == 1 then
        run_build('local-lua-debugger-vscode', { 'npm', 'install' }, ev.data.path)
        run_build('local-lua-debugger-vscode', { 'npm', 'run', 'build' }, ev.data.path)
      end
    end,
    ['nvim-treesitter'] = function(ev)
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end,
  }

  -- Build steps after a plugin is installed or updated.
  vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('pack-build', { clear = true }),
    callback = function(ev)
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end
      local build = builders[ev.data.spec.name]
      if build then build(ev) end
    end,
  })
end

-- GitHub URL helper shared by plugin modules.
local function gh(repo) return 'https://github.com/' .. repo end

return { gh = gh }
