#!/usr/bin/env lua
-- fzfs/string_utils.lua - String utilities
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local M = {}

function M.split(str, sep)
  if not str then return {} end
  sep = sep or '%s+'
  local parts = {}
  for part in string.gmatch(str, '([^' .. sep .. ']+)') do
    table.insert(parts, part)
  end
  return parts
end


function M.trim(str)
  if not str then return '' end
  return str:match('^%s*(.-)%s*$') or ''
end


function M.colorize(str, color)
  if not color then return str end
  return color .. str .. '\27[0m'
end


function M.contains(str, pattern)
  if not str then return false end
  return str:find(pattern, 1, true) ~= nil
end


function M.starts_with(str, prefix)
  if not str or not prefix then return false end
  return str:sub(1, #prefix) == prefix
end


function M.ends_with(str, suffix)
  if not str or not suffix then return false end
  return str:sub(-#suffix) == suffix
end


function M.self_test()
  print('FZFS String Utils Module Test')
  print('===============================')
  print('  split: ' .. table.concat(M.split("a b c", ' '), ','))
  assert(#M.split("a b c", ' ') == 3, 'split failed')
  print('  trim: [' .. M.trim("  text  ") .. ']')
  assert(M.trim("  text  ") == "text", 'trim failed')
  assert(M.contains("hello world", "world") == true, 'contains failed')
  assert(M.starts_with("hello", "he") == true, 'starts_with failed')
  assert(M.ends_with("hello", "lo") == true, 'ends_with failed')
  print('')
  print('✓ String utils module test passed')
end

if arg and arg[1] == '--self-test' then
  M.self_test()
  os.exit(0)
end
return M
