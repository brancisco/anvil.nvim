---@module 'anvil.opts.common'
local M = {}

--- Parses a type string to extract the base type and requirement.
---@param type_str string The type string to parse (e.g., 'string', 'string!', 'string?').
---@return string, boolean The clean type name and a boolean indicating if it's required.
function M.parse_type_string(type_str)
  local required = true
  local clean_type = type_str
  local last_char = string.sub(type_str, -1)

  if last_char == '?' then
    required = false
    clean_type = string.sub(type_str, 1, -2)
  elseif last_char == '!' then
    required = true
    clean_type = string.sub(type_str, 1, -2)
  end

  return clean_type, required
end

--- Tests the type of a value.
---@param path string The path of the value being tested.
---@param value any The value to test.
---@param _type string The expected type of the value.
---@return boolean, string[]|{} A boolean indicating if the test passed, and a table of errors.
function M.test_type(path, value, _type)
  local clean_type, required = M.parse_type_string(_type)

  if value == nil then
    if required then
      return false, { ('Value at "%s" is required.'):format(path) }
    else
      return true, {}
    end
  end

  if type(value) ~= clean_type then
    local msg = ('Value "%s" at "%s" is not of type "%s"'):format(tostring(value), path, clean_type)
    return false, { msg }
  end
  return true, {}
end

return M
