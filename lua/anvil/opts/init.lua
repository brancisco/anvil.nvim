---@module 'anvil.opts'
local M = {}

--- Validates a table of options against a format table.
---@see anvil.opts.validator.validate
M.validate = require('anvil.opts.validator').validate
M.marshall = require('anvil.opts.marshaller').marshall

return M
