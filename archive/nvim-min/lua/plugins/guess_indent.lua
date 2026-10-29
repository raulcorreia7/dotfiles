-- Indent detection.
local gh = require('config.pack').gh

vim.pack.add({ gh 'NMAC427/guess-indent.nvim' }, { confirm = false })
require('guess-indent').setup {}
