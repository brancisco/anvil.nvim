---@module 'anvil.opts.validator'
local M = {}

local tbl_utils = require('anvil.utils.table')
local rules = require('anvil.opts.rules')
local common = require('anvil.opts.common')

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
  local clean_type, _ = common.parse_type_string(_type)
  if type(_type) ~= 'string' or M.ValidTypes[clean_type] == nil then
    error(('First value of config ("%s") must be a valid lua type.'):format(_type))
  end
  local pass, errors = common.test_type(path, value, _type)
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
    return common.test_type(path, value, config)
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

  -- 1. Handle array part for ordered validation
  for i, config in ipairs(format) do
    local value = opts[i]
    local path = ('[%d]'):format(i) -- Create a path for error messages
    local pass, test_errors = test(path, value, config)
    if not pass then
      for _, err_msg in ipairs(test_errors) do
        table.insert(all_errors, err_msg)
      end
    end
  end

  -- 2. Handle hash part for key-path validation
  for path, config in pairs(format) do
    if type(path) == 'string' then -- Process only string keys
      local value = tbl_utils.get_path(opts, path)
      local pass, test_errors = test(path, value, config)
      if not pass then
        for _, err_msg in ipairs(test_errors) do
          table.insert(all_errors, err_msg)
        end
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
