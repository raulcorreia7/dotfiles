-- Shared UI symbols: Nerd Font glyphs, or portable ASCII fallback.
-- Picked once via NVIM_ICON_MODE (nerd|ascii, default nerd).
local M = {}

-- Precedence: NVIM_ICON_MODE wins, else NVIM_NERD_FONT via helpers, else nerd.
local mode = (vim.env.NVIM_ICON_MODE or ''):lower()
if mode ~= 'nerd' and mode ~= 'ascii' then mode = require('config.helpers').has_nerd_font() and 'nerd' or 'ascii' end

M.mode = mode
M.nerd = mode == 'nerd'

local nerd = {
  tree = {
    collapsed = '',
    expanded = '',

    folder = '',
    folder_open = '',
    folder_empty = '󰉖',
    folder_empty_open = '󰷏',
    selected = '',

    modified = '',
  },

  git = {
    added = '✚',
    modified = '',
    deleted = '✖',
    renamed = '',

    untracked = '',
    ignored = '',
    unstaged = '󰄱',
    staged = '󰱒',
    conflict = '',
  },

  gitsigns = {
    add = '▎',
    change = '▎',
    delete = '',
  },

  diagnostics = {
    error = '',
    warn = '',
    info = '',
    hint = '󰌵',
  },

  ui = {
    check = '✓',
    close = '',
    search = '',
    settings = '',
    branch = '',
    lock = '',
    unlock = '',
    modified = '',
    ellipsis = '…',
  },

  kinds = {
    Array = '',
    Boolean = '󰨙',
    Class = '',
    Color = '',
    Constant = '󰏿',
    Constructor = '',
    Enum = '',
    EnumMember = '',
    Event = '',
    Field = '',
    File = '',
    Folder = '',
    Function = '󰊕',
    Interface = '',
    Key = '',
    Keyword = '',
    Method = '󰊕',
    Module = '',
    Namespace = '󰦮',
    Null = '󰟢',
    Number = '󰎠',
    Object = '',
    Operator = '',
    Package = '',
    Property = '',
    Reference = '',
    Snippet = '',
    String = '',
    Struct = '󰆼',
    Text = '󰉿',
    TypeParameter = '',
    Unit = '',
    Value = '',
    Variable = '󰀫',
  },
}

local ascii = {
  tree = {
    collapsed = '>',
    expanded = 'v',

    folder = '',
    folder_open = '',
    folder_empty = '',
    folder_empty_open = '',
    selected = '>',

    modified = '*',
  },

  git = {
    added = '+',
    modified = '~',
    deleted = '-',
    renamed = 'R',

    untracked = '?',
    ignored = '.',
    unstaged = '!',
    staged = 'S',
    conflict = 'X',
  },
  gitsigns = {
    add = '+',
    change = '~',
    delete = '-',
  },

  diagnostics = {

    error = 'E',
    warn = 'W',
    info = 'I',
    hint = 'H',
  },

  ui = {
    check = 'v',
    close = 'x',
    search = '/',
    settings = '*',
    branch = '*',
    lock = '#',
    unlock = '#',
    modified = '*',
    ellipsis = '...',
  },

  kinds = {
    Array = 'A',
    Boolean = 'B',
    Class = 'C',
    Color = 'C',
    Constant = 'K',
    Constructor = 'C',
    Enum = 'E',
    EnumMember = 'E',
    Event = 'E',
    Field = 'F',
    File = 'F',
    Folder = 'D',
    Function = 'F',
    Interface = 'I',
    Key = 'K',
    Keyword = 'K',
    Method = 'M',
    Module = 'M',
    Namespace = 'N',
    Null = 'N',
    Number = '#',
    Object = 'O',
    Operator = 'O',
    Package = 'P',
    Property = 'P',
    Reference = 'R',
    Snippet = 'S',
    String = 'S',
    Struct = 'S',
    Text = 'T',
    TypeParameter = 'T',
    Unit = 'U',
    Value = 'V',
    Variable = 'V',
  },
}

local active = M.nerd and nerd or ascii

M.tree = active.tree
M.gitsigns = active.gitsigns
M.git = active.git
M.diagnostics = active.diagnostics
M.ui = active.ui
M.kinds = active.kinds

--- One-off pick without a table entry: `M.get('', '>')`.
---@param nerd_icon string nerd-font glyph
---@param fallback string ascii fallback
---@return string
function M.get(nerd_icon, fallback) return M.nerd and nerd_icon or fallback end

return M
