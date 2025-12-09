---@module 'anvil.utils.function'
local M = {}

--- Partially evaluates a function.
---@param fn function The function to partially evaluate.
---@param ... any The arguments to partially apply to the function.
---@return function A new function that, when called, will execute the original function with the pre-filled arguments.
function M.partial(fn, ...)
  local args = { unpack(...) }
  return function(...)
    local inner_args = { unpack({ ... }) }
    for _, value in pairs(inner_args) do
      table.insert(args, value)
    end
    return fn(unpack(args))
  end
end

return M
