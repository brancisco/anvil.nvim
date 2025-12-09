describe('The marshall function', function()
  local marshall = require('anvil.opts').marshall

  it('marshalls a simple flat table', function()
    local format = { ['a'] = 'any', ['b'] = 'any' }
    local opts = { a = 1, b = 2, c = 3 }
    local marshalled = marshall(format, opts)
    assert.are.same(marshalled, { a = 1, b = 2 })
  end)

  it('creates nested tables from dot-separated paths', function()
    local format = { ['a.b.c'] = 'any', ['a.d'] = 'any' }
    local opts = {
      a = {
        b = {
          c = 123
        },
        d = 456
      }
    }
    local marshalled = marshall(format, opts)
    assert.are.same(marshalled, { a = { b = { c = 123 }, d = 456 } })
  end)

  it('handles missing values in opts gracefully', function()
    local format = { ['a.b'] = 'any', ['x.y'] = 'any' }
    local opts = { a = { b = 123 } }
    local marshalled = marshall(format, opts)
    assert.are.same(marshalled, { a = { b = 123 } })
  end)

  it('returns an empty table for empty format', function()
    local format = {}
    local opts = { a = 1, b = 2 }
    local marshalled = marshall(format, opts)
    assert.are.same(marshalled, {})
  end)

  it('returns an empty table for empty opts', function()
    local format = { ['a.b'] = 'any' }
    local opts = {}
    local marshalled = marshall(format, opts)
    assert.are.same(marshalled, {})
  end)
end)
