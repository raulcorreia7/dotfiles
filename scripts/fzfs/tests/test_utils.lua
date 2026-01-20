#!/usr/bin/env lua
-- tests/test_utils.lua - Utils module tests

package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'

local path_utils = require('path_utils')
local shell_utils = require('shell_utils')
local string_utils = require('string_utils')
local table_utils = require('table_utils')

print('FZFS Utils Module Test')
print('========================')

print('Path utilities:')
local expanded = path_utils.expand_path('~')
print('  expand_path(~): ' .. expanded)
assert(expanded == os.getenv('HOME'), 'expand_path failed for ~')

local joined = path_utils.join('/home/user', 'docs', 'file.txt')
print('  join: ' .. joined)
assert(joined == 'home/user/docs/file.txt', 'join failed')

local dirname = path_utils.dirname('/home/user/docs/file.txt')
print('  dirname: ' .. dirname)
assert(dirname == '/home/user/docs/', 'dirname failed')

local basename = path_utils.basename('/home/user/docs/file.txt')
print('  basename: ' .. basename)
assert(basename == 'file.txt', 'basename failed')

local abs = path_utils.is_absolute('/home/user/file.txt')
print('  is_absolute (/home): ' .. tostring(abs))
assert(abs == true, 'is_absolute failed')

print('')
print('Shell utilities:')
print('  shell_quote: ' .. shell_utils.shell_quote("file with spaces"))

print('')
print('String utilities:')
print('  split: ' .. table.concat(string_utils.split("a b c", ' '), ','))
print('  trim: [' .. string_utils.trim("  text  ") .. ']')

print('')
print('Table utilities:')
print('  merge: ' .. table_utils.length(table_utils.merge({a=1}, {b=2})) .. ' keys')
print('  map: ' .. table.concat(table_utils.map({1,2,3}, function(x) return x*2 end), ','))

print('')
print('✓ Utils module test passed')
