---@module 'anvil.opts.rules'
local M = {}
local common = require('anvil.opts.common')

--- A table containing functions for validating specific types with additional arguments.
---@field number fun(value: number, args: {lt?: number, gt?: number}):(boolean, string[]|nil) Validates a number against `lt` and `gt` constraints.
---@field string fun(value: string, args: {lt?: number, gt?: number, one_of?: string[]}):(boolean, string[]|nil) Validates a string against `lt`, `gt`, and `one_of` constraints.
---@field function fun(fn: function, args: {nargs?: string}):(boolean, string[]|nil) Validates a function against `nargs` constraints.
---@field table fun(value: table, args: table):(boolean, nil) A placeholder for table validation.
M.test_with_args = {
  number = function(value, args)
    local pass = true
    local errors = {}
    if args.lt then
      if type(args.lt) ~= 'number' then
        error('Argument "lt" must be a number.')
      end
      local is_lt = value < args.lt
      if not is_lt then
        table.insert(errors, ('Number must be less than %s.'):format(args.lt))
      end
      pass = pass and is_lt
    end
    if args.gt then
      if type(args.gt) ~= 'number' then
        error('Argument "gt" must be a number.')
      end
      local is_gt = value > args.gt
      if not is_gt then
        table.insert(errors, ('Number must be greater than %s.'):format(args.gt))
      end
      pass = pass and is_gt
    end
    if #errors < 1 then
      return pass, nil
    end
    return pass, errors
  end,
  string = function(value, args)
    local pass = true
    local errors = {}
    if args.lt then
      if type(args.lt) ~= 'number' then
        error('Argument "lt" must be a number.')
      end
      local is_lt = #value < args.lt
      if not is_lt then
        table.insert(errors, ('String must be less than %s characters.'):format(args.lt))
      end
      pass = pass and is_lt
    end
    if args.gt then
      if type(args.gt) ~= 'number' then
        error('Argument "gt" must be a number.')
      end
      local is_gt = #value > args.gt
      if not is_gt then
        table.insert(errors, ('String must be greater than %s characters.'):format(args.gt))
      end
      pass = pass and is_gt
    end
    if args.one_of then
      if type(args.one_of) ~= 'table' then
        error('Argument "one_of" must be a table of strings.')
      end
      local is_one_of = false
      for _, allowed_value in ipairs(args.one_of) do
        if value == allowed_value then
          is_one_of = true
          break
        end
      end
      if not is_one_of then
        table.insert(errors, ('String "%s" must be one of: %s.'):format(value, table.concat(args.one_of, ', ')))
      end
      pass = pass and is_one_of
    end
    if #errors < 1 then
      return pass, nil
    end
    return pass, errors
  end,
  ['function'] = function(fn, args)
    if args.nargs ~= nil then
      if type(args.nargs) ~= 'string' then
        error('Argument nargs must be a string (e.g. `+1`, `*2`).')
      end
      local special, digets = args.nargs:match('([*+]*)(%d*)')
      local info = debug.getinfo(fn)
      -- info.nparams
      if special == '*' then
        if digets ~= nil then
          digets = tonumber(digets)
          local is_lt = info.nparams < digets
          if not is_lt then
            return false, { ('Function must have between 0 and %s args.'):format(digets) }
          end
        end
      elseif special == '+' then
        if info.nparams <= 0 then
          return false, { 'Function must have at least 1 arg.' }
        end
        if digets ~= nil then
          digets = tonumber(digets)
          local is_lt = info.nparams < digets
          if not is_lt then
            return false, { ('Function must have between 1 and %s args.'):format(digets) }
          end
        end
      else
        if digets == nil then
          error('patern must be in the form of one of `%*%d*`, `%+%d*`, or `%d*`.')
        end
        digets = tonumber(digets)
        if info.nparams ~= digets then
          return false, { ('Function must have exactly %s args.'):format(digets) }
        end
      end
    end
    return true, nil
  end,
  table = function(value, args)
    local all_errors = {}
    if args.repeated then
      if type(args.repeated) ~= 'boolean' then
        error('Argument "repeated" must be a boolean.')
      end
      if type(value) ~= 'table' then
        return false, { 'Value is not a table.' }
      end
      for i = 1, table.maxn(value) do
        local item = value[i]
        local path = ('[%d]'):format(i)
        if args.type then
          if type(args.type) ~= 'string' then
            error('Argument "type" must be a string.')
          end
          local pass, errors = common.test_type(path, item, args.type)
          if not pass then
            for _, err in ipairs(errors) do
              table.insert(all_errors, err)
            end
          end
        end

        if args.shape then
          if type(args.shape) ~= 'table' then
            error('Argument "shape" must be a table.')
          end
          local validator = require('anvil.opts.validator')
          local _, errors = validator.validate(args.shape, item)
          if errors then
            for _, err in ipairs(errors) do
              table.insert(all_errors, ('at index %d: %s'):format(i, err))
            end
          end
        end
      end
    elseif args.shape then
      if type(args.shape) ~= 'table' then
        error('Argument "shape" must be a table.')
      end
      local validator = require('anvil.opts.validator')
      local _, errors = validator.validate(args.shape, value)
      if errors then
        return false, errors
      end
    end

    if #all_errors > 0 then
      return false, all_errors
    end

    return true, nil
  end,
}

return M
