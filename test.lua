-- Get the value at a dot-separated key.
-- Number-looking items in the key are translated to numbers (for arrays).
function deepget (o, fullkey)
  for key in fullkey:gmatch('[^.]+') do
    -- If the key is numeric, transform to number (for arrays and such)
    if key:match('^%d+$') ~= nil then
      key = tonumber(key)
    end
    -- If the item returns nil, terminate here
    if o[key] == nil then
      return nil
    end
    -- If it's a table, keep iterating down, otherwise terminate here
    if type(o[key]) == 'table' then
      o = o[key]
    else
      return o[key]
    end
  end
  -- Reached the end and o is still a table; this appears to be what we wanted
  return o
end

-- Set the value at a dot-separated key.
-- Number-looking items in the key are translated to numbers (for arrays).
-- Cannot add arbitrary length to arrays; can only increase length by one.
-- The '+' key is considered an 'array append'.
function deepset (o, fullkey, value)
  -- Some logic to set values extracted into a function.
  -- Appending to an array is done with table.insert.
  local function setv (o, k, v)
    if type(k) == 'number' then
      -- Existing array values can simply be overwritten
      if k <= #o then o[k] = v
      -- An append operation should probably use table.insert,
      -- for future-proofing reasons.
      elseif k == (#o + 1) then table.insert(o, v)
      -- We'll simply fail for adding length beyond append
      else error('Cannot add arbitrary length to arrays (index '..k..' len '..#o..')')
      end
    else
      -- Not a number key; just set the value.
      o[k] = v
    end
    -- The logic below will want this value to help it go deeper
    return o[k]
  end

  -- Variables needed at the end
  local lasto = o       -- The parent of o
  local lastkey = nil   -- The previous key

  -- Start going into the table
  for key in fullkey:gmatch('[^.]+') do
    -- Translate numeric keys into numbers
    if key:match('^%d+$') ~= nil then key = tonumber(key) end
    -- Set the actual key value for the 'append' operator
    if key == '+' then key = #o + 1 end

    if type(o[key]) == 'table' then
      -- If the current o is a table, just go deeper
      lasto = o
      o = setv(o, key, o[key])
    else
      -- Current o is not a table, so make it one and go deeper
      local v = o[key]
      lasto = o
      o = setv(o, key, { value = v })
    end

    lastkey = key
  end
  -- Finally, set the actual value.
  lasto[lastkey] = value
end


local o = {
  a = { 2, 3, 4 },
  b = { x = 'x', y = 'y', z = { foo = 'bar', arr = { 'hello', 'world', { a = 'asdf' } } }},
  c = 'c'
}

local words = { 'foo', 'bar', 'baz', 'qux' }
for i=1,#words do
  deepset(o, 'x.+', words[i])
  print(o.x[i], #o.x)
end

deepset(o, 'x.3', 'Hello, World!')
print(o.x[3], #o.x)

deepset(o, 'x.+.name', 'Nelson')
setmetatable(deepget(o, 'x.5'), { __tostring = function (self) return '{ name = "' .. self.name .. '" }' end })
print(o.x[5].name, #o.x)

for i,v in ipairs(o.x) do
  print(i, v)
end
