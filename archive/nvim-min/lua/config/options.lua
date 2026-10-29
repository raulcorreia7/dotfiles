-- Editor options and leaders. `vim.o.<name>` mirrors `:set <name>`; see `:help option-list`.
do
  vim.loader.enable()
  local icons = require 'config.icons'

  -- Leaders. Must precede plugin maps.
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Behavior and files.
  vim.o.confirm = true -- ask to save instead of failing on unsaved changes
  vim.o.undofile = true -- persistent undo across sessions
  vim.o.undolevels = 10000 -- undo history depth
  vim.o.sessionoptions = 'buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds' -- session contents for persistence
  vim.opt.shortmess:append { W = true, I = true, c = true, C = true } -- fewer interruptions
  vim.g.markdown_recommended_style = 0 -- don't let ftplugin override markdown settings
  vim.o.autowrite = false -- write on :next, :make, and buffer switch
  vim.o.autoread = true -- reload files changed outside neovim
  vim.opt.formatoptions = 'jcroqlnt' -- no autowrap, no comment continuation
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- gq formats via conform
  vim.o.grepprg = 'rg --vimgrep' -- :grep through ripgrep
  -- vim.o.backup = false -- no backup files
  -- vim.o.writebackup = false -- no backup while writing
  -- vim.o.swapfile = false -- no swap files

  -- Indentation (guess-indent.nvim adjusts per file; formatters own the rest).
  vim.o.breakindent = true -- wrapped lines keep their indent
  vim.o.expandtab = true -- spaces instead of tabs
  vim.o.shiftwidth = 2 -- indent size
  vim.o.tabstop = 2 -- spaces a tab counts for
  vim.o.shiftround = true -- round indent to shiftwidth
  vim.o.smartindent = true -- auto-indent fallback where treesitter indent is missing

  -- Search.
  vim.o.ignorecase = true -- case-insensitive unless \C or capitals below
  vim.o.smartcase = true
  vim.o.hlsearch = true -- highlight matches (cleared with <Esc>)
  vim.o.incsearch = true -- jump to matches while typing

  -- Appearance.
  vim.o.number = true -- line numbers
  vim.o.relativenumber = true -- relative jumps (<leader>uL toggles)
  vim.o.cursorline = true -- highlight the current line
  -- vim.o.cursorcolumn = true -- highlight the current column
  -- vim.o.colorcolumn = '80' -- ruler at 80 columns
  vim.o.signcolumn = 'yes' -- always shown, text never shifts
  vim.opt.fillchars = { foldopen = icons.tree.expanded, foldclose = icons.tree.collapsed, fold = ' ', foldsep = ' ', diff = '╱', eob = ' ' } -- fold chevrons match tree expanders
  vim.o.termguicolors = true -- 24-bit color for themes and statusline
  vim.o.showmode = false -- mode lives in the statusline
  vim.o.ruler = false -- no ruler (statusline covers it)
  vim.o.cmdheight = 0 -- no reserved row; messages overlay while shown
  vim.o.list = false -- visible whitespace markers
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.o.wrap = false -- no line wrap (<leader>uw toggles)
  vim.o.linebreak = true -- wrap at word boundaries when wrap is on
  vim.o.scrolloff = 10 -- lines kept above/below the cursor
  vim.o.sidescrolloff = 8 -- columns kept left/right of the cursor
  vim.o.smoothscroll = true -- smooth scroll redisplay
  vim.o.mouse = 'a' -- mouse for resize and selection
  vim.o.inccommand = 'split' -- live substitution preview
  vim.o.virtualedit = 'block' -- cursor where there is no text in visual block
  vim.o.jumpoptions = 'view' -- keep context on jumplist jumps

  -- Splits and windows.
  vim.o.splitright = true -- new splits go right
  vim.o.splitbelow = true -- new splits go below
  vim.o.splitkeep = 'screen' -- keep text stable when splitting
  vim.o.winminwidth = 5 -- minimum window width

  -- Timing.
  vim.o.updatetime = 250 -- cursorhold delay (ms)
  vim.o.timeoutlen = 300 -- mapped-sequence wait (ms)

  -- Clipboard (skip over SSH so OSC 52 stays independent).
  vim.schedule(function() vim.o.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus' end)

  -- Completion popups and command line.
  vim.o.pumheight = 10 -- max popup entries
  vim.o.pumblend = 10 -- slight popup transparency
  vim.o.completeopt = 'menu,menuone,noselect' -- completion behavior
  vim.o.wildmode = 'longest:full,full' -- command-line completion

  -- Folds from treesitter grammars; everything starts open.
  vim.o.foldmethod = 'expr' -- fold by syntax tree
  vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- global default for all windows
  vim.o.foldlevel = 99 -- open all folds on file open
end
