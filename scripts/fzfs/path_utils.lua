#!/usr/bin/env lua
-- fzfs/path_utils.lua - Path utilities
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local lfs = require('lfs')
local M = {}

function M.expand_path(path)
  if not path then return nil end
  path = path:gsub('^~/?', os.getenv('HOME') .. '/')
  if path:sub(1,1) ~= '/' then
    local cwd = lfs.currentdir()
    if path:sub(1,2) == './' then path = path:sub(3) end
    path = cwd .. '/' .. path
  end
  local parts = {}
  for part in path:gmatch('([^/]+)') do
    if part == '..' and #parts > 0 and parts[#parts] ~= '..' then
      table.remove(parts)
    elseif part ~= '.' and part ~= '' then
      table.insert(parts, part)
    end
  end
  return '/' .. table.concat(parts, '/')
end


function M.join(...)
  local parts = {...}
  local result = {}
  for _, part in ipairs(parts) do
    for p in part:gmatch('([^/]+)') do
      if p ~= '' and p ~= '.' then table.insert(result, p) end
    end
  end
  return table.concat(result, '/')
end


function M.dirname(path)
  local dir = path:match('^(.*/)[^/]*$')
  return dir or '.'
end


function M.basename(path)
  return path:match('[^/]+$') or path
end


function M.is_absolute(path)
  return path:sub(1,1) == '/'
end


function M.exists(path)
  local attr = lfs.attributes(path)
  return attr ~= nil
end


function M.is_dir(path)
  local attr = lfs.attributes(path)
  return attr and attr.mode == 'directory' or false
end


function M.is_file(path)
  local attr = lfs.attributes(path)
  return attr and attr.mode == 'file' or false
end


function M.self_test()
  print('FZFS Path Utils Module Test')
  print('============================')
  local expanded = M.expand_path('~')
  print('  expand_path(~): ' .. expanded)
  assert(expanded == os.getenv('HOME'), 'expand_path failed for ~')
  local joined = M.join('/home/user', 'docs', 'file.txt')
  print('  join: ' .. joined)
  assert(joined == 'home/user/docs/file.txt', 'join failed')
  local dirname = M.dirname('/home/user/docs/file.txt')
  print('  dirname: ' .. dirname)
  assert(dirname == '/home/user/docs/', 'dirname failed')
  local basename = M.basename('/home/user/docs/file.txt')
  print('  basename: ' .. basename)
  assert(basename == 'file.txt', 'basename failed')
  local abs = M.is_absolute('/home/user/file.txt')
  print('  is_absolute (/home): ' .. tostring(abs))
  assert(abs == true, 'is_absolute failed')
  print('')
  print('✓ Path utils module test passed')
end

if arg and arg[1] == '--self-test' then
  M.self_test()
  os.exit(0)
end
return M
