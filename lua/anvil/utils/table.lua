---@module 'anvil.utils.table'
local string_utils = require('anvil.utils.string')
local M = {}

--- Applies a function to each element of a table and returns a new table with the results.
---@param tbl table The table to map over.
---@param fn function The function to apply to each element.
---@return table A new table with the results of applying the function to each element.
function M.map(tbl, fn)
  local result = {}
  for k, v in pairs(tbl) do
    result[k] = fn(v, k)
  end
  return result
end

--- Reduces a table to a single value by applying a function to each element.
---@param tbl table The table to reduce.
---@param fn function The function to apply to each element.
---@param acc any The initial value of the accumulator.
---@return any The final value of the accumulator.
function M.reduce(tbl, fn, acc)
  local accumulator = acc
  for k, v in pairs(tbl) do
    accumulator = fn(accumulator, v, k)
  end
  return accumulator
end

--- Filters a table by applying a function to each element.
---@param tbl table The table to filter.
---@param fn function The function to apply to each element.
---@return table A new table with the elements that passed the filter.
function M.filter(tbl, fn)
  local result = {}
  for k, v in pairs(tbl) do
    if fn(v, k) then
      table.insert(result, v)
    end
  end
  return result
end

--- Gets a value from a nested table using a dot-separated path.
---@param tbl table The table to get the value from.
---@param path string The dot-separated path to the value.
---@return any|nil The value at the given path, or nil if not found.
function M.get_path(tbl, path)
  local parts = string_utils.split(path, '.')
  local current_value = tbl
  for _, part in ipairs(parts) do
    if type(current_value) == 'table' and current_value[part] ~= nil then
      current_value = current_value[part]
    else
      return nil -- Path not found or not a table at an intermediate step
    end
  end
  return current_value
end

return M
