-- Global editor keymaps and diagnostics.

-- Clear search highlight on <Esc>.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'clear search highlight' })

-- Diagnostics.
local icons = require 'config.icons'
local d = icons.diagnostics
local helpers = require 'config.helpers'
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = d.error,
      [vim.diagnostic.severity.WARN] = d.warn,
      [vim.diagnostic.severity.INFO] = d.info,
      [vim.diagnostic.severity.HINT] = d.hint,
    },
  },

  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Inline text or virtual lines (pick one).
  virtual_text = true,
  virtual_lines = false,

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'open diagnostic quickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'exit terminal mode' })
-- Move between windows with <C-hjkl>.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'go to left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'go to right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'go to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'go to upper window' })

-- Wrapped-line motion
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'up', expr = true, silent = true })

-- Window resize
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'increase window height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'decrease window height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'decrease window width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'increase window width' })

-- Move lines
vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<CR>==", { desc = 'move down' })
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = 'move up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<CR>==gi', { desc = 'move down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<CR>==gi', { desc = 'move up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = 'move down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = 'move up' })

-- Buffers
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'prev buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'next buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { desc = 'prev buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'next buffer' })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<CR>', { desc = 'switch to other buffer' })
vim.keymap.set('n', '<leader>`', '<cmd>e #<CR>', { desc = 'switch to other buffer' })
vim.keymap.set('n', '<leader>bD', '<cmd>:bd<CR>', { desc = 'delete buffer and window' })
vim.keymap.set('n', '<leader>bi', function()
  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible[vim.api.nvim_win_get_buf(win)] = true
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.buflisted(buf) == 1 and not visible[buf] then vim.cmd('bdelete ' .. buf) end
  end
end, { desc = 'delete invisible buffers' })

-- Editing helpers
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<CR><esc>', { desc = 'save file' })
vim.keymap.set('i', ',', ',<c-g>u', { desc = 'undo breakpoint' })
vim.keymap.set('i', '.', '.<c-g>u', { desc = 'undo breakpoint' })
vim.keymap.set('i', ';', ';<c-g>u', { desc = 'undo breakpoint' })
vim.keymap.set('x', '<', '<gv', { desc = 'indent left' })
vim.keymap.set('x', '>', '>gv', { desc = 'indent right' })
vim.keymap.set('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>', { desc = 'add comment below' })
vim.keymap.set('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<CR>fxa<bs>', { desc = 'add comment above' })
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'next search result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'next search result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'next search result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'prev search result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'prev search result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'prev search result' })

-- Files and lists
vim.keymap.set('n', '<leader>fn', '<cmd>enew<CR>', { desc = 'new file' })
vim.keymap.set('n', '<leader>xl', function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'location list' })
vim.keymap.set('n', '<leader>xq', function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'quickfix list' })
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'previous quickfix' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'next quickfix' })
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'line diagnostics' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end, { desc = 'next diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end, { desc = 'prev diagnostic' })
vim.keymap.set('n', ']e', function() vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR, float = true } end, { desc = 'next error' })
vim.keymap.set('n', '[e', function() vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR, float = true } end, { desc = 'prev error' })
vim.keymap.set('n', ']w', function() vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.WARN, float = true } end, { desc = 'next warning' })
vim.keymap.set('n', '[w', function() vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.WARN, float = true } end, { desc = 'prev warning' })

-- Tabs.
vim.keymap.set('n', '<leader><tab><tab>', '<cmd>tabnew<CR>', { desc = 'new tab' })
vim.keymap.set('n', '<leader><tab>d', '<cmd>tabclose<CR>', { desc = 'close tab' })
vim.keymap.set('n', '<leader><tab>]', '<cmd>tabnext<CR>', { desc = 'next tab' })
vim.keymap.set('n', '<leader><tab>[', '<cmd>tabprevious<CR>', { desc = 'prev tab' })
vim.keymap.set('n', '<leader><tab>f', '<cmd>tabfirst<CR>', { desc = 'first tab' })
vim.keymap.set('n', '<leader><tab>l', '<cmd>tablast<CR>', { desc = 'last tab' })
vim.keymap.set('n', '<leader><tab>o', '<cmd>tabonly<CR>', { desc = 'close other tabs' })
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'quit all' })

-- Windows.
vim.keymap.set('n', '<leader>-', '<C-w>s', { desc = 'split window below' })
vim.keymap.set('n', '<leader>|', '<C-w>v', { desc = 'split window right' })
vim.keymap.set('n', '<leader>wd', '<C-w>c', { desc = 'delete window' })
vim.keymap.set('n', '<leader>K', '<cmd>norm! K<CR>', { desc = 'keywordprg' })
vim.keymap.set('n', '<leader>ui', vim.show_pos, { desc = 'inspect pos' })
vim.keymap.set('n', '<leader>ur', '<cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'redraw / clear hlsearch / diff update' })

-- Full config reload (single-file edits also auto-reload on save).
-- Command form bypasses the leader menu entirely.
vim.api.nvim_create_user_command('ReloadConfig', function() helpers.reload() end, { desc = 'reload config' })
vim.keymap.set('n', '<leader>R', '<cmd>ReloadConfig<CR>', { desc = 'reload config' })
