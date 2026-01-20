#!/usr/bin/env lua
-- fzfs/preview/file.lua - File and directory preview
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local core = require('core')
local path_utils = require('path_utils')
local shell_utils = require('shell_utils')
local M = {}

function M.preview(path)
  path = path:match('^([^:]+)') or path
  if path_utils.is_dir(path) then
    if core.get_tools().ls == 'ls' then
      os.execute('ls -lah ' .. shell_utils.shell_quote(path))
    else
      os.execute(core.get_tools().ls .. ' -lah --color=always --icons --group-directories-first --git ' .. shell_utils.shell_quote(path))
    end
    return
  end
  if path_utils.is_file(path) then
    local ext = path:match('%.([^.]+)$') or ''
    if ext == 'gz' and path:match('%.tar%.gz$') then ext = 'tar.gz'
    elseif ext == 'bz2' and path:match('%.tar%.bz2$') then ext = 'tar.bz2'
    elseif ext == 'xz' and path:match('%.tar%.xz$') then ext = 'tar.xz' end

    local archive_handlers = {
      ['tar.gz'] = { cmd = 'tar -tf', tool = 'has_tar' },
      ['tgz'] = { cmd = 'tar -tf', tool = 'has_tar' },
      ['tar.bz2'] = { cmd = 'tar -tf', tool = 'has_tar' },
      ['tar.xz'] = { cmd = 'tar -tf', tool = 'has_tar' },
      ['tar'] = { cmd = 'tar -tf', tool = 'has_tar' },
      ['zip'] = { cmd = 'unzip -l', tool = 'has_unzip' },
      ['7z'] = { cmd = '7z l', tool = 'has_7z' },
      ['rar'] = { cmd = 'unrar l', tool = 'has_unrar' }
    }

    local handler = archive_handlers[ext]
    if handler and core.get_tools()[handler.tool] then
      os.execute(handler.cmd .. ' ' .. shell_utils.shell_quote(path) .. ' | head -n 100')
      return
    end
    if core.get_tools().has_file then
      local mime = shell_utils.exec_cmd('file --mime ' .. shell_utils.shell_quote(path))
      if mime and mime:match('binary') then
        print(core.colors.yellow .. 'Binary file detected (Preview disabled)' .. core.colors.reset)
        return
      end
    end
    if core.get_tools().cat == 'bat' then
      os.execute('bat --style=numbers --color=always --line-range :200 ' .. shell_utils.shell_quote(path))
    else
      os.execute('head -n 100 ' .. shell_utils.shell_quote(path))
    end
  end
end

return M
