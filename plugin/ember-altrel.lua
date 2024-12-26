if vim.fn.has("nvim-0.7.0") == 0 then
	vim.api.nvim_err_writeln("ember-altrel requires at least nvim-0.7.0.1")
	return
end

-- make sure this file is loaded only once
if vim.g.ember_altrel == 1 then
	return
end
vim.g.ember_altrel = 1

local ember_altrel = require("ember-altrel")

vim.api.nvim_create_user_command("EmberRelNext", ember_altrel.rotate_next, {})
vim.api.nvim_create_user_command("EmberRelPrev", ember_altrel.rotate_prev, {})
