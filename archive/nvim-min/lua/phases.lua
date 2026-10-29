-- Plugin load phases, required from init.lua after config/*.
-- before: foundation-adjacent aids plus the colorscheme, so UI below inherits it.
-- core: editing, search, LSP, format, lint, completion, syntax.
-- after: UI chrome and tools layering on top of core.
local phases = {
  before = {
    'plugins.guess_indent',
    'plugins.gitsigns',
    'plugins.which_key',
    'plugins.theme',
  },
  core = {
    'plugins.todo_comments',
    'plugins.mini',
    'plugins.telescope',
    'plugins.lsp',
    'plugins.peek',
    'plugins.format',
    'plugins.lint',
    'plugins.completion',
    'plugins.multicursor',
    'plugins.treesitter',
  },
  after = {
    'plugins.bufferline',
    'plugins.lualine',
    'plugins.neotree',
    'plugins.snacks',
    'plugins.lazygit',
    'plugins.diffview',
    'plugins.persistence',
    'plugins.flash',
    'plugins.overseer',
    'plugins.dap',
    'plugins.neotest',
    'plugins.grugfar',
  },
}

for _, phase in ipairs { 'before', 'core', 'after' } do
  for _, mod in ipairs(phases[phase]) do
    require(mod)
  end
end
