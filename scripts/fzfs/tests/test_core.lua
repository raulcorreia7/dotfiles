#!/usr/bin/env lua
-- tests/test_core.lua - Core module tests

package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'

local core = require('core')

print('FZFS Core Module Test')
print('=======================')

core.init()
local t = core.detect_tools()

print('Configuration:')
print('  FZF binary: ' .. core.get('bin'))
print('  Project roots: ' .. core.get('project_roots'))
print('  Cache dir: ' .. core.get('cache_dir'))
print('  Show hidden: ' .. tostring(core.get('show_hidden')))

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
for name, code in pairs(core.colors) do
  io.write('  ' .. name .. ': ')
  io.write(code .. 'test' .. core.colors.reset .. '\n')
end

print('')
print('✓ Core module test passed')
