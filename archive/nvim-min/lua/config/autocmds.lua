-- Editor autocommands.

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Auto-reload: source saved config modules in place; prompt restart when not possible.
do
  local config_root = vim.fn.stdpath 'config'

  --- Source a saved config module; prompt for restart when not possible.
  ---@param args table autocmd callback args with the saved file name
  local function reload_module(args)
    local full = vim.fn.fnamemodify(args.file, ':p')
    if full:sub(1, #config_root) ~= config_root or full:sub(-4) ~= '.lua' then return end
    -- init.lua defines load order; everything else hot-reloads in place.
    if full:match '[/\\]init%.lua$' then
      vim.notify(vim.fn.fnamemodify(full, ':t') .. ' saved: restart nvim-min to apply', vim.log.levels.INFO)
      return
    end
    local ok, err = pcall(dofile, full)
    if ok then
      vim.notify('Reloaded ' .. vim.fn.fnamemodify(full, ':t'), vim.log.levels.INFO)
    else
      vim.notify('Needs restart (' .. err .. ')', vim.log.levels.WARN)
    end
  end

  vim.api.nvim_create_autocmd('BufWritePost', {
    desc = 'reload nvim-min module on save',
    group = vim.api.nvim_create_augroup('nvim-min-reload', { clear = true }),
    callback = reload_module,
  })
end

-- Reload the file when changed outside (e.g. git checkout on another branch).
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'reload file on external change',
  group = vim.api.nvim_create_augroup('nvim-min-checktime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd 'checktime' end
  end,
})

-- Keep splits balanced when the terminal is resized.
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'resize splits to equal size',
  group = vim.api.nvim_create_augroup('nvim-min-resize-splits', { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- Restore cursor to the last edit position when reopening a file.
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'restore last cursor position',
  group = vim.api.nvim_create_augroup('nvim-min-last-loc', { clear = true }),
  callback = function(event)
    if vim.b[event.buf].nvim_min_last_loc then return end
    vim.b[event.buf].nvim_min_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Close helper buffers with q.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'quit helper buffer with q',
  group = vim.api.nvim_create_augroup('nvim-min-close-with-q', { clear = true }),
  pattern = { 'help', 'qf', 'checkhealth', 'lspinfo', 'gitsigns-blame', 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, { buffer = event.buf, silent = true, desc = 'quit buffer' })
    end)
  end,
})

-- Unlist man pages opened inline.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'unlist man pages',
  group = vim.api.nvim_create_augroup('nvim-min-man-unlisted', { clear = true }),
  pattern = 'man',
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})

-- Wrap and spell-check prose filetypes.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'wrap and spell prose',
  group = vim.api.nvim_create_augroup('nvim-min-wrap-spell', { clear = true }),
  pattern = { 'text', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Create missing parent directories on save.
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'create missing parent directories',
  group = vim.api.nvim_create_augroup('nvim-min-auto-mkdir', { clear = true }),
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})
