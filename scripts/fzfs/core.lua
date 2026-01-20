#!/usr/bin/env lua
-- fzfs/core.lua - Configuration, constants, and tool detection
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local lfs = require('lfs')

local penlight_available = pcall(require, 'pl')
local luash_available = pcall(require, 'luash')

if penlight_available then
  local pl = require('pl')
  package.path = package.path .. ';' .. pl.path.package_path('?.lua')
  package.cpath = package.cpath .. ';' .. pl.path.package_path('?.so')
end

if luash_available then
  package.path = package.path .. ';' .. os.getenv('HOME') .. '/.luarocks/share/lua/5.4/?.lua'
  package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
end

local M = {}
M.colors = {
  reset = '\27[0m', bold = '\27[1m', red = '\27[31m',
  green = '\27[32m', yellow = '\27[33m', cyan = '\27[36m',
  magenta = '\27[35m', bold_cyan = '\27[1;36m', bold_yellow = '\27[1;33m',
}
M.key_bindings = {
  edit = 'ctrl-e', cd = 'ctrl-o', preview = 'ctrl-p',
  yank = 'ctrl-y', hidden = 'ctrl-h',
}
M.defaults = {
  opts_ui = '--height=80% --layout=reverse --info=inline-right --border=rounded --margin=1 --padding=1 --pointer=▶ --marker=✓',
  opts_preview = 'right:60%:wrap:nohidden',
  project_roots = os.getenv('HOME') .. '/personal',
  cache_dir = (os.getenv('XDG_CACHE_HOME') or (os.getenv('HOME') .. '/.cache')) .. '/fzfs',
  excludes = '.git node_modules .venv venv .cache .npm .yarn .pnpm-store dist build target .ssh .gnupg .direnv .terraform .idea .vscode .DS_Store coverage *.pem *.key *.crt *.pub *.asc *.p12 *.pfx',
  friendly = 1,
  relative = 1,
}
local config = {
  bin = os.getenv('FZF_BIN') or os.getenv('FZF_CMD') or 'fzf',
  opts_ui = os.getenv('FZFS_OPTS_UI'),
  opts_preview = os.getenv('FZFS_OPTS_PREVIEW'),
  project_roots = os.getenv('FZFS_PROJECT_ROOTS'),
  cache_dir = os.getenv('FZFS_CACHE_DIR'),
  excludes = os.getenv('FZFS_EXCLUDES'),
  show_hidden = tonumber(os.getenv('FZFS_SHOW_HIDDEN') or 1),
  friendly = tonumber(os.getenv('FZFS_FRIENDLY')),
  relative = tonumber(os.getenv('FZFS_RELATIVE')),
}

function M.init()
  M.detect_tools()
  if not config.opts_ui or config.opts_ui:match('margin=0') or
     config.opts_ui:match('padding=0') or config.opts_ui:match('^%-%-') then
    config.opts_ui = M.defaults.opts_ui
  end
  if not config.opts_preview then config.opts_preview = M.defaults.opts_preview end
  if not config.project_roots then config.project_roots = M.defaults.project_roots end
  if not config.cache_dir then config.cache_dir = M.defaults.cache_dir end
  if not config.excludes then config.excludes = M.defaults.excludes end
  if config.friendly == nil then config.friendly = M.defaults.friendly end
  if config.relative == nil then config.relative = M.defaults.relative end
end


function M.get(key)
  return config[key]
end


function M.set(key, value)
  config[key] = value
end


function M.get_excludes()
  local excludes = {}
  for ex in config.excludes:gmatch('%S+') do table.insert(excludes, ex) end
  return excludes
end


local tools = {}
local function check_cmd(cmd)
  local pipe = io.popen(string.format('command -v %s 2>/dev/null', cmd))
  local result = pipe:read('*a')
  pipe:close()
  return result and result:match('%S') ~= nil
end


function M.detect_tools()
  tools.ls = check_cmd('eza') and 'eza' or check_cmd('exa') and 'exa' or 'ls'
  tools.grep = check_cmd('rg') and 'rg' or 'grep'
  tools.cat = check_cmd('bat') and 'bat' or 'cat'
  tools.has_fd = check_cmd('fd')
  tools.has_delta = check_cmd('delta')
  tools.has_file = check_cmd('file')
  tools.has_pbcopy = check_cmd('pbcopy')
  tools.has_xclip = check_cmd('xclip')
  tools.has_xsel = check_cmd('xsel')
  tools.has_tar = check_cmd('tar')
  tools.has_unzip = check_cmd('unzip')
  tools.has_7z = check_cmd('7z')
  tools.has_unrar = check_cmd('unrar')
  tools.has_penlight = penlight_available
  tools.has_luash = luash_available
  return tools
end


function M.get_tools()
  return tools
end


function M.self_test()
  print('FZFS Core Module Test')
  print('=======================')
  M.init()
  local t = M.detect_tools()
  print('Configuration:')
  print('  FZF binary: ' .. M.get('bin'))
  print('  Project roots: ' .. M.get('project_roots'))
  print('  Cache dir: ' .. M.get('cache_dir'))
  print('  Show hidden: ' .. tostring(M.get('show_hidden')))
  print('  Friendly mode: ' .. tostring(M.get('friendly')))
  print('  Relative paths: ' .. tostring(M.get('relative')))
  print('')
  print('Tools:')
  print('  LS: ' .. t.ls)
  print('  GREP: ' .. t.grep)
  print('  CAT: ' .. t.cat)
  print('  Has fd: ' .. tostring(t.has_fd))
  print('  Has delta: ' .. tostring(t.has_delta))
  print('  Has penlight: ' .. tostring(t.has_penlight))
  print('  Has luash: ' .. tostring(t.has_luash))
  print('')
  print('Colors:')
  for name, code in pairs(M.colors) do io.write('  ' .. name .. ': ') io.write(code .. 'test' .. M.colors.reset .. '\n') end
  print('')
  print('✓ Core module test passed')
end

if arg and arg[1] == '--self-test' then
  M.self_test()
  os.exit(0)
end
return M
