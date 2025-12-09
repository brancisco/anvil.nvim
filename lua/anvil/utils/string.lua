---@module 'anvil.utils.string'
local M = {}

--- Splits a string by a given delimiter.
---@param str string The string to split.
---@param delimiter string The delimiter to split the string by.
---@return string[] A table of strings split by the delimiter.
function M.split(str, delimiter)
  local result = {}
  for match in string.gmatch(str, "([^" .. delimiter .. "]+)") do
    table.insert(result, match)
  end
  return result
end

return M
