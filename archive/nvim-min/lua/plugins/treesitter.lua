-- Treesitter parsers, highlighting, folding, and indentation.
local gh = require('config.pack').gh
do
  vim.pack.add({
    { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
    gh 'nvim-treesitter/nvim-treesitter-textobjects',
    gh 'windwp/nvim-ts-autotag',
  }, { confirm = false })
  local treesitter = require 'nvim-treesitter'
  local treesitter_move = require 'nvim-treesitter-textobjects.move'

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  treesitter.install(parsers)

  ---@param language string
  ---@param name string
  ---@return boolean
  local function has_query(language, name)
    -- pcall: query.get asserts when no parser exists (e.g. dockerfile on fresh install)
    local ok, q = pcall(vim.treesitter.query.get, language, name)
    return ok and q ~= nil
  end

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting and other treesitter features
    pcall(vim.treesitter.start, buf, language)

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    -- Enable treesitter based indentation
    if has_query(language, 'indents') then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = treesitter.get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = treesitter.get_installed 'parsers'

      if not vim.tbl_contains(installed_parsers, language) and vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        treesitter.install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Enable an installed parser, or try one supplied outside nvim-treesitter.
        treesitter_try_attach(buf, language)
      end
    end,
  })

  require('nvim-treesitter-textobjects').setup { move = { set_jumps = true } }
  require('nvim-ts-autotag').setup {}

  local function set_textobject_jumps(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language or not has_query(language, 'textobjects') then return end
    ---@param method string move module function
    ---@param query string treesitter capture
    ---@param desc string lowercase label
    local function jump(lhs, method, query, desc)
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function() treesitter_move[method](query, 'textobjects') end, { buffer = args.buf, desc = desc })
    end

    jump(']f', 'goto_next_start', '@function.outer', 'next function')
    jump(']F', 'goto_next_end', '@function.outer', 'next function end')
    jump('[f', 'goto_previous_start', '@function.outer', 'prev function')
    jump('[F', 'goto_previous_end', '@function.outer', 'prev function end')
    jump(']c', 'goto_next_start', '@class.outer', 'next class')
    jump(']C', 'goto_next_end', '@class.outer', 'next class end')
    jump('[c', 'goto_previous_start', '@class.outer', 'prev class')
    jump('[C', 'goto_previous_end', '@class.outer', 'prev class end')
    jump(']a', 'goto_next_start', '@parameter.inner', 'next parameter')
    jump(']A', 'goto_next_end', '@parameter.inner', 'next parameter end')
    jump('[a', 'goto_previous_start', '@parameter.inner', 'prev parameter')
    jump('[A', 'goto_previous_end', '@parameter.inner', 'prev parameter end')
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('treesitter-textobjects', { clear = true }),
    callback = set_textobject_jumps,
  })
end
