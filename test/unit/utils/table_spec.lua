describe('The table utils', function()
  local table_utils = require('anvil.utils.table')

  describe('The map function', function()
    it('applies a function to each element of a table', function()
      local tbl = { 1, 2, 3 }
      local doubled = table_utils.map(tbl, function(val) return val * 2 end)
      assert.are.same(doubled, { 2, 4, 6 })
    end)

    it('handles empty tables gracefully', function()
      local tbl = {}
      local mapped = table_utils.map(tbl, function(val) return val * 2 end)
      assert.are.same(mapped, {})
    end)

    it('processes tables with mixed keys (pairs behavior)', function()
      local tbl = { 1, nil, 3, a = 10 }
      local processed = table_utils.map(tbl, function(val) return val end)

      -- Check the values
      assert.are.same(processed[1], 1)
      assert.is_nil(processed[2])
      assert.are.same(processed[3], 3)
      assert.are.same(processed.a, 10)

      -- Check the number of elements
      local count = 0
      for _ in pairs(processed) do
        count = count + 1
      end
      assert.are.same(count, 3) -- {1=1, 3=3, a=10}
    end)
  end)

  describe('The get_path function', function()
    it('gets a value from a nested table using a valid path', function()
      local tbl = { a = { b = { c = 123 } } }
      local value = table_utils.get_path(tbl, 'a.b.c')
      assert.are.same(value, 123)
    end)

    it('returns nil for an invalid path', function()
      local tbl = { a = { b = { c = 123 } } }
      local value = table_utils.get_path(tbl, 'a.x.c')
      assert.is_nil(value)
    end)

    it('returns nil for a path to a non-table intermediate step', function()
      local tbl = { a = { b = 123 } }
      local value = table_utils.get_path(tbl, 'a.b.c')
      assert.is_nil(value)
    end)
  end)

  describe('The reduce function', function()
    it('reduces a table to a single value', function()
      local tbl = { 1, 2, 3, 4, 5 }
      local sum = table_utils.reduce(tbl, function(acc, val) return acc + val end, 0)
      assert.are.same(sum, 15)
    end)

    it('handles empty tables gracefully', function()
      local tbl = {}
      local sum = table_utils.reduce(tbl, function(acc, val) return acc + val end, 0)
      assert.are.same(sum, 0)
    end)

    it('processes all numeric values, skipping nils (pairs behavior)', function()
      local tbl = { 1, 2, nil, 4, 5 }
      local sum = table_utils.reduce(tbl, function(acc, val) return acc + (val or 0) end, 0)
      assert.are.same(sum, 12) -- 1 + 2 + 4 + 5
    end)

    it('handles nil as an initial accumulator', function()
      local tbl = { 1, 2, 3 }
      local result = table_utils.reduce(tbl, function(acc, val) return (acc or 0) + val end, nil)
      assert.are.same(result, 6)
    end)

    it('works with associative tables', function()
      local tbl = { a = 1, b = 2, c = 3 }
      local sum = table_utils.reduce(tbl, function(acc, val) return acc + val end, 0)
      assert.are.same(sum, 6)
    end)
  end)

  describe('The filter function', function()
    it('filters a table based on a predicate', function()
      local tbl = { 1, 2, 3, 4, 5 }
      local even_numbers = table_utils.filter(tbl, function(val) return val % 2 == 0 end)
      assert.are.same(even_numbers, { 2, 4 })
    end)

    it('handles empty tables gracefully', function()
      local tbl = {}
      local filtered = table_utils.filter(tbl, function(val) return val % 2 == 0 end)
      assert.are.same(filtered, {})
    end)

    it('processes all numeric values, skipping nils (pairs behavior)', function()
      local tbl = { 1, 2, nil, 4, 5 }
      local filtered = table_utils.filter(tbl, function(val) return val and val % 2 == 0 end)
      assert.are.same(filtered, { 2, 4 })
    end)

    it('works with associative tables, returning an array of values', function()
      local tbl = { a = 1, b = 2, c = 3, d = 4 }
      local filtered = table_utils.filter(tbl, function(val) return val % 2 == 0 end)
      -- The order is not guaranteed, so we sort the result for a stable test
      table.sort(filtered)
      assert.are.same(filtered, { 2, 4 })
    end)

    it('includes elements when predicate returns 0 (truthy in Lua)', function()
      local tbl = { 1, 2, 3 }
      local filtered = table_utils.filter(tbl, function(val) return val == 2 and 0 or nil end)
      assert.are.same(filtered, { 2 })
    end)

    it('includes elements when predicate returns a non-empty string (truthy in Lua)', function()
      local tbl = { 1, 2, 3 }
      local filtered = table_utils.filter(tbl, function(val) return val == 2 and 'hello' or nil end)
      assert.are.same(filtered, { 2 })
    end)
  end)
end)
