#!/usr/bin/env lua
-- fzfs/shell_utils.lua - Shell utilities
package.cpath = package.cpath .. ";" .. os.getenv("HOME") .. "/.luarocks/lib/lua/5.4/?.so"
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.dotfiles/scripts/fzfs/?.lua"
local M = {}

function M.shell_quote(str)
	if not str then
		return "''"
	end
	local quoted = str:gsub("'", "'\\''")
	return "'" .. quoted .. "'"
end

function M.shell_escape(str)
	if not str then
		return ""
	end
	local escaped = str:gsub("[$]", "\\$"):gsub("[`]", "\\`"):gsub('["]', '\\"'):gsub([[\\]], "\\\\")
	return escaped
end

function M.exec_cmd(cmd)
	local pipe = io.popen(cmd .. " 2>&1")
	if not pipe then
		return nil, "Failed to execute: " .. cmd
	end
	local result = pipe:read("*a")
	local success, exit_code = pipe:close()
	return result, exit_code or 0
end

function M.exec_cmd_lines(cmd)
	local result = M.exec_cmd(cmd)
	if not result then
		return {}
	end
	local lines = {}
	for line in result:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

function M.self_test()
	print("FZFS Shell Utils Module Test")
	print("==============================")
	print("  shell_quote: " .. M.shell_quote("file with spaces"))
	assert(M.shell_quote("file with spaces") == "'file with spaces'", "shell_quote failed")
	local result = M.exec_cmd('echo "test"')
	print("  exec_cmd: " .. tostring(result):match("[^\r\n]+"))
	assert(result and result:match("test"), "exec_cmd failed")
	local lines = M.exec_cmd_lines('echo -e "line1\nline2\nline3"')
	print("  exec_cmd_lines: " .. #lines .. " lines")
	assert(#lines == 3, "exec_cmd_lines failed")
	print("")
	print("✓ Shell utils module test passed")
end

if arg and arg[1] == "--self-test" then
	M.self_test()
	os.exit(0)
end
return M
