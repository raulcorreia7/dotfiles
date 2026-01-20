#!/usr/bin/env lua
-- fzfs/preview.lua - Preview entry point for fzf
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local core = require('core')
core.init()
core.detect_tools()
local handler = require('preview.handler')
local preview_type = arg[1] or 'file'
local path = arg[2] or ''
handler.preview(preview_type, path)
