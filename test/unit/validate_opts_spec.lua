local opts = require('anvil.opts')

describe('The validate function', function()
  local validate = opts.validate

  it('passes validation for a correct string type', function()
    local validator = { ['foo.bar'] = 'string' }
    local test = { foo = { bar = 'hello' } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for an incorrect string type', function()
    local validator = { ['foo.bar'] = 'string' }
    local test = { foo = { bar = 123 } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "123" at "foo.bar" is not of type "string"')
  end)

  it('fails validation for a missing field', function()
    local validator = { ['foo.bar'] = 'string' }
    local test = { foo = {} }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value at "foo.bar" is required.')
  end)

  it('passes validation for string length less than "lt" constraint', function()
    local validator = { ['foo.bar'] = { 'string', lt = 5 } }
    local test = { foo = { bar = 'hi' } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for string length equal to "lt" constraint', function()
    local validator = { ['foo.bar'] = { 'string', lt = 5 } }
    local test = { foo = { bar = 'hello' } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'String must be less than 5 characters.')
  end)

  it('passes validation for string length greater than "gt" constraint', function()
    local validator = { ['foo.bar'] = { 'string', gt = 5 } }
    local test = { foo = { bar = 'hello world' } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for string length equal to "gt" constraint', function()
    local validator = { ['foo.bar'] = { 'string', gt = 5 } }
    local test = { foo = { bar = 'hello' } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'String must be greater than 5 characters.')
  end)

  it('passes validation for number less than "lt" constraint', function()
    local validator = { ['foo.bar'] = { 'number', lt = 5 } }
    local test = { foo = { bar = 4 } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for number equal to "lt" constraint', function()
    local validator = { ['foo.bar'] = { 'number', lt = 5 } }
    local test = { foo = { bar = 5 } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Number must be less than 5.')
  end)

  it('passes validation for number greater than "gt" constraint', function()
    local validator = { ['foo.bar'] = { 'number', gt = 5 } }
    local test = { foo = { bar = 6 } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for number equal to "gt" constraint', function()
    local validator = { ['foo.bar'] = { 'number', gt = 5 } }
    local test = { foo = { bar = 5 } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Number must be greater than 5.')
  end)

  it('passes validation for function with correct "nargs"', function()
    local validator = { ['foo.bar'] = { 'function', nargs = '1' } }
    local test = { foo = { bar = function(a) print(a) end } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for function with incorrect "nargs"', function()
    local validator = { ['foo.bar'] = { 'function', nargs = '1' } }
    local test = { foo = { bar = function() end } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Function must have exactly 1 args.')
  end)

  it('passes validation for a valid nested table field', function()
    local validator = { ['foo.bar.baz'] = 'number' }
    local test = { foo = { bar = { baz = 123 } } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for an invalid nested table field', function()
    local validator = { ['foo.bar.baz'] = 'number' }
    local test = { foo = { bar = { baz = 'abc' } } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "abc" at "foo.bar.baz" is not of type "number"')
  end)

  it('passes validation for a string that is in the "one_of" list', function()
    local validator = { ['foo.bar'] = { 'string', one_of = { 'a', 'b', 'c' } } }
    local test = { foo = { bar = 'b' } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for a string that is not in the "one_of" list', function()
    local validator = { ['foo.bar'] = { 'string', one_of = { 'a', 'b', 'c' } } }
    local test = { foo = { bar = 'd' } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'String "d" must be one of: a, b, c.')
  end)

  it('fails validation for a missing required field with "!"', function()
    local validator = { ['foo.bar'] = 'string!' }
    local test = { foo = {} }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value at "foo.bar" is required.')
  end)

  it('passes validation for a present required field with "!"', function()
    local validator = { ['foo.bar'] = 'string!' }
    local test = { foo = { bar = 'hello' } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('passes validation for a missing optional field with "?"', function()
    local validator = { ['foo.bar'] = 'string?' }
    local test = { foo = {} }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('passes validation for a present optional field with "?"', function()
    local validator = { ['foo.bar'] = 'string?' }
    local test = { foo = { bar = 'hello' } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for a present optional field with "?" and wrong type', function()
    local validator = { ['foo.bar'] = 'string?' }
    local test = { foo = { bar = 123 } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "123" at "foo.bar" is not of type "string"')
  end)

  it('passes validation for a table with "repeated" and correct "type"', function()
    local validator = { ['foo.bar'] = { 'table', repeated = true, type = 'string' } }
    local test = { foo = { bar = { 'a', 'b', 'c' } } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for a table with "repeated" and incorrect "type"', function()
    local validator = { ['foo.bar'] = { 'table', repeated = true, type = 'string' } }
    local test = { foo = { bar = { 'a', 123, 'c' } } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "123" at "[2]" is not of type "string"')
  end)

  it('fails validation for a table with "repeated" and a required nil member', function()
    local validator = { ['foo.bar'] = { 'table', repeated = true, type = 'string!' } }
    local test = { foo = { bar = { 'a', nil, 'c' } } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value at "[2]" is required.')
  end)

  it('passes validation for a table with "repeated" and an optional nil member', function()
    local validator = { ['foo.bar'] = { 'table', repeated = true, type = 'string?' } }
    local test = { foo = { bar = { 'a', nil, 'c' } } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('passes validation for a table with "repeated" and correct "shape"', function()
    local validator = { ['foo.bar'] = { 'table', repeated = true, shape = { name = 'string' } } }
    local test = { foo = { bar = { { name = 'one' }, { name = 'two' } } } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for a table with "repeated" and incorrect "shape"', function()
    local validator = { ['foo.bar'] = { 'table', repeated = true, shape = { name = 'string' } } }
    local test = { foo = { bar = { { name = 'one' }, { name = 123 } } } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'at index 2: Value "123" at "name" is not of type "string"')
  end)

  it('passes validation for a table with correct "shape"', function()
    local validator = { ['foo.bar'] = { 'table', shape = { name = 'string', value = 'number' } } }
    local test = { foo = { bar = { name = 'one', value = 1 } } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for a table with incorrect "shape"', function()
    local validator = { ['foo.bar'] = { 'table', shape = { name = 'string', value = 'number' } } }
    local test = { foo = { bar = { name = 'one', value = 'two' } } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "two" at "value" is not of type "number"')
  end)

  it('passes validation for a mixed format table with correct opts', function()
    local validator = { 'string', 'number', ['foo.bar'] = 'boolean' }
    local test = { 'hello', 25, foo = { bar = true } }
    local _, errors = validate(validator, test)
    assert.is._nil(errors)
  end)

  it('fails validation for a mixed format table with incorrect ordered opt', function()
    local validator = { 'string', 'number' }
    local test = { 'hello', 'world' }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "world" at "[2]" is not of type "number"')
  end)

  it('fails validation for a mixed format table with incorrect keyed opt', function()
    local validator = { 'string', ['foo.bar'] = 'boolean' }
    local test = { 'hello', foo = { bar = 123 } }
    local _, errors = validate(validator, test)
    assert.is_not._nil(errors)
    assert.are.same(errors[1], 'Value "123" at "foo.bar" is not of type "boolean"')
  end)
end)
