---@module 'anvil.opts.validator'
local M = {}

local tbl_utils = require('anvil.utils.table')
local rules = require('anvil.opts.rules')

---@private
--- Parses a type string to extract the base type and requirement.
---@param type_str string The type string to parse (e.g., 'string', 'string!', 'string?').
---@return string, boolean The clean type name and a boolean indicating if it's required.
local function parse_type_string(type_str)
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

---@private
--- Tests the type of a value.
---@param path string The path of the value being tested.
---@param value any The value to test.
---@param _type string The expected type of the value.
---@return boolean, string[]|{} A boolean indicating if the test passed, and a table of errors.
local function test_type(path, value, _type)
  local clean_type, required = parse_type_string(_type)

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

--- A table of valid types.
---@type table<string, number>
M.ValidTypes = {
  ['nil'] = 1,
  number = 2,
  string = 3,
  boolean = 4,
  table = 5,
  ['function'] = 6,
}

---@private
--- Tests a table value.
---@param path string The path of the value being tested.
---@param value any The value to test.
---@param tbl table The configuration table.
---@return boolean, string[]|nil A boolean indicating if the test passed, and a table of errors.
local function test_table(path, value, tbl)
  if #tbl < 1 then
    error(('Config at "%s" must contain at least a type.'):format(path))
  end
  local _type = tbl[1]
  local clean_type, _ = parse_type_string(_type)
  if type(_type) ~= 'string' or M.ValidTypes[clean_type] == nil then
    error(('First value of config ("%s") must be a valid lua type.'):format(_type))
  end
  local pass, errors = test_type(path, value, _type)
  if not pass then
    return false, errors
  end
  if rules.test_with_args[clean_type] ~= nil then
    local pass, errors = rules.test_with_args[clean_type](value, tbl)
    if not pass then
      return false, errors
    end
  end
  return true, nil
end

---@private
--- Tests a value against a configuration.
---@param path string The path of the value being tested.
---@param value any The value to test.
---@param config string|table The configuration to test against.
---@return boolean, string[]|{}|nil A boolean indicating if the test passed, and a table of errors.
local function test(path, value, config)
  if type(config) == 'string' then
    return test_type(path, value, config)
  elseif type(config) == 'table' then
    return test_table(path, value, config)
  else
    error('Config must be either a string or table: "' .. path .. '".')
  end
end

--- Validates a table of options against a format table.
---@param format table The format table to validate against.
---@param opts table The table of options to validate.
---@return table, string[]|nil A table of results, and a table of errors or nil if no errors.
function M.validate(format, opts)
  local result = {}
  local all_errors = {}
  for path, config in pairs(format) do
    local value = tbl_utils.get_path(opts, path)
    local pass, test_errors = test(path, value, config)
    if not pass then
      for _, err_msg in ipairs(test_errors) do
        table.insert(all_errors, err_msg)
      end
    end
  end
  if #all_errors > 0 then
    return result, all_errors
  else
    return result, nil
  end
end

return M
