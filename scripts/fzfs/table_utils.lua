#!/usr/bin/env lua
-- fzfs/table_utils.lua - Table utilities
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local M = {}

function M.merge(t1, t2)
  local result = {}
  for k, v in pairs(t1 or {}) do result[k] = v end
  for k, v in pairs(t2 or {}) do result[k] = v end
  return result
end


function M.map(t, fn)
  local result = {}
  for i, v in ipairs(t or {}) do table.insert(result, fn(v, i)) end
  return result
end


function M.filter(t, predicate)
  local result = {}
  for i, v in ipairs(t or {}) do
    if predicate(v, i) then table.insert(result, v) end
  end
  return result
end


function M.find(t, value)
  for i, v in ipairs(t or {}) do if v == value then return i end end
  return nil
end


function M.keys(t)
  local result = {}
  for k, _ in pairs(t or {}) do table.insert(result, k) end
  return result
end


function M.values(t)
  local result = {}
  for _, v in pairs(t or {}) do table.insert(result, v) end
  return result
end


function M.length(t)
  local count = 0
  for _ in pairs(t or {}) do count = count + 1 end
  return count
end


function M.self_test()
  print('FZFS Table Utils Module Test')
  print('===============================')
  print('  merge: ' .. M.length(M.merge({a=1}, {b=2})) .. ' keys')
  assert(M.length(M.merge({a=1}, {b=2})) == 2, 'merge failed')
  print('  map: ' .. table.concat(M.map({1,2,3}, function(x) return x*2 end), ','))
  assert(#M.map({1,2,3}, function(x) return x*2 end) == 3, 'map failed')
  local filtered = M.filter({1,2,3,4,5}, function(x) return x % 2 == 0 end)
  print('  filter: ' .. table.concat(filtered, ','))
  assert(#filtered == 2, 'filter failed')
  assert(M.find({'a','b','c'}, 'b') == 2, 'find failed')
  print('')
  print('✓ Table utils module test passed')
end

if arg and arg[1] == '--self-test' then
  M.self_test()
  os.exit(0)
end
return M
