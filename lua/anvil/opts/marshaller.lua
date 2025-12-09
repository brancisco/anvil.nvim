---@module 'anvil.opts.marshaller'
local M = {}

local tbl_utils = require('anvil.utils.table')
local string_utils = require('anvil.utils.string')

---@private
--- Sets a value in a nested table using a dot-separated path, creating tables as needed.
---@param tbl table The table to set the value in.
---@param path string The dot-separated path.
---@param value any The value to set.
local function set_path(tbl, path, value)
  local parts = string_utils.split(path, '.')
  local current = tbl
  for i = 1, #parts - 1 do
    local part = parts[i]
    if current[part] == nil then
      current[part] = {}
    end
    current = current[part]
  end
  current[parts[#parts]] = value
end

--- Marshalls data from an input table into a new table structured according to a format table.
---@param format table A table where keys are dot-separated paths.
---@param opts table The input table containing the data to marshall.
---@return table The new, structured table.
function M.marshall(format, opts)
  local result = {}
  for path, _ in pairs(format) do
    local value = tbl_utils.get_path(opts, path)
    if value ~= nil then
      set_path(result, path, value)
    end
  end
  return result
end

return M
