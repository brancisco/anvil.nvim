---@module 'anvil.opts.common'
local M = {}

--- Parses a type string to extract the base type and requirement.
---@param type_str string The type string to parse (e.g., 'string|number', 'string!', 'string|number?').
---@return string[], boolean The clean type names and a boolean indicating if it's required.
function M.parse_type_string(type_str)
  local required = true
  local clean_type_str = type_str
  local last_char = string.sub(type_str, -1)

  if last_char == '?' then
    required = false
    clean_type_str = string.sub(type_str, 1, -2)
  elseif last_char == '!' then
    required = true
    clean_type_str = string.sub(type_str, 1, -2)
  end

  local types = {}
  for t in string.gmatch(clean_type_str, '([^|]+)') do
    table.insert(types, t)
  end

  return types, required
end

--- Tests the type of a value against one or more possible types.
---@param path string The path of the value being tested.
---@param value any The value to test.
---@param _type string The expected type string (e.g., 'string', 'string|number').
---@return boolean, string[]|{}, string|nil A boolean for pass/fail, a table of errors, and the matched type on success.
function M.test_type(path, value, _type)
  local types, required = M.parse_type_string(_type)

  if value == nil then
    if required then
      return false, { ('Value at "%s" is required.'):format(path) }
    else
      return true, {}
    end
  end

  local value_type = type(value)
  for _, expected_type in ipairs(types) do
    if value_type == expected_type then
      return true, {}, value_type -- Success, return matched type
    end
  end

  -- No match found if we reach here
  local msg
  if #types == 1 then
    msg = ('Value "%s" at "%s" is not of type "%s"'):format(tostring(value), path, types[1])
  else
    local types_str = table.concat(types, ' or ')
    msg = ('Value "%s" at "%s" is not one of type [%s]'):format(tostring(value), path, types_str)
  end
  return false, { msg }
end

return M
