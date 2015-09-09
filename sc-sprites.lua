--[[
sc-sprites for Lua and LÖVE 2D.
Homepage for this library: https://github.com/SourceComb/sc-sprites/tree/lua-love2d
Homepage for sc-sprites: http://www.sourcecomb.com/sc-sprites

Copyright (c) 2015, Nelson Crosby <ncrosby@sourcecomb.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]


local function adapter (pngdat)
  pngdat = love.filesystem.newFileData(pngdat, 'sprites.png')
  local image = love.image.newImageData(pngdat)

  local a = { _image = image }
  function a:getImage ()
    return self._image
  end
  function a:getWidth ()
    return self._image:getWidth()
  end
  function a:getHeight ()
    return self._image:getHeight()
  end

  return a
end


-- We use Class Commons
assert(common and common.class and common.instance,
       "Please provide a Class Commons implementation")
local class = common.class
local new = common.instance

--[[ Constant strings ]]
local PATTERNS = {
  HEADER = 'source comb spritesheet;(%d+);(.*);(%d+);\r?\n(.*)',
  COORD_PAIR = '([%w.]+)%s*=%s*(.-)\r?\n(.*)',
  COORD_VALUE = '(%d+),(%d+) (%d+)x(%d+) (%d+)( ?)(%d*)(@?)(%d*)'
}
-- Errors are in format to be used by __
local ERRORS = {
  FORMAT = {
    PREFIX = 'File does not start with the correct prefix (starts at ${start})',
    CELLWIDTH = 'Cell width (${cw}) must be greater than 0',
    COORD_VALUE = 'Coordinate value "${value}" for "${key}" is not in valid format',
    CANVAS_WIDTH = 'Canvas width ${width} must be a multiple of cell width ${cw}',
    CANVAS_HEIGHT = 'Canvas height ${height} must be a multiple of cell width ${cw}'
  },
  WRONG_VERSION = 'This library can only read strict Version 1 files (version ${ver}; extn "${extn}")',
  PARSE_CANVAS = 'Loading canvas failed: "${msg}"',
  DEEPSET_ONLY_APPEND = 'Cannot add arbitrary length to arrays (index ${index}, len ${len})'
}

-- Basic string templating function
local function __ (str, values)
  local s = str:gsub('%${(%w+)}', function (name)
    return tostring(values[name])
  end)
  return s
end


-- Get the value at a dot-separated key.
-- Number-looking items in the key are translated to numbers (for arrays).
local function deepget (o, fullkey)
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
local function deepset (o, fullkey, value)
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
      else error(__(ERRORS.DEEPSET_ONLY_APPEND, { index = k, len = #o }))
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


local Sprite = {}

function Sprite:init (cellWidth, y, x, w, h, s, f, r)
  -- Store sprite info
  self._cw = cellWidth
  self.pos = { y = y * cellWidth, x = x * cellWidth }
  self.size = { width = w * cellWidth, height = h * cellWidth }
  self.scale = s
  self.ani = { frames = f, rate = r }
end

-- Generator to iterate over frame sprites
function Sprite:frames ()
  -- x for final frame:
  -- - Get final frame index
  -- - Turn it into a pixel pos relative to first frame
  -- - Add first frame offset
  local finalFrameX = ((self.ani.frames - 1) * self.size.width) + self.pos.x
  -- Current X coord
  local frameX = self.pos.x

  -- Actual iterator
  return function ()
    if frameX > finalFrameX then
      -- No more frames; terminate
      return nil
    else
      -- Create the next sprite
      local next = new(Sprite, 1, self.pos.y, frameX, self.size.width, self.size.height, self.scale, 1, self.ani.rate)
      -- Next frameX by adding width
      frameX = frameX + self.size.width
      return next
    end
  end -- iterator
end -- generator

-- Get an array of Sprite objects each representing a single frame in the
-- animation.
-- Just turns the :frames() generator into an array
function Sprite:getFrames ()
  local frames = {}
  for frame in self:frames() do
    table.insert(frames, frame)
  end
  frames.rate = self.ani.rate
  return frames
end

function Sprite:__tostring ()
  -- Concat all values in familiar format
  local y = self.pos.y
  local x = self.pos.x
  local width = self.size.width
  local height = self.size.height
  local scale = self.scale
  local frames = self.ani.frames
  local rate = self.ani.rate
  return y .. ',' .. x .. ' ' .. width .. 'x' .. height .. ' ' .. scale .. ' ' .. frames .. '@' .. rate
end


local Spritesheet = {}

function Spritesheet:init (parser, file)
  self.parser = parser

  if file == nil then
    self.file = nil
  else
    self:setFile(file)
    self:readData()
    self:setupBatch()
  end
end

-- Sets the file to read from.
-- Can take a string path or a file object.
function Spritesheet:setFile (file)
  if type(file) == 'string' then
    file = assert(io.open(file, 'r'))
  end
  self.file = file
end

-- Read the spritesheet in from data.
-- If data is unspecified, reads the
-- entire file from self.file.
function Spritesheet:readData (data)
  if data == nil then
    data = self.file:read('*all')
  end
  self.sheetData = data

  -- Get all the information from the parser.
  self.formatVersion, self.formatExtn, self.cellWidth, data = self.parser:parseHeader(data)
  self._spriteKeys, self.sprites, data = self.parser:parseCoords(data, self.cellWidth)
  self.canvasAdapter = self.parser:parseCanvas(data, self.cellWidth)
end

-- Sets up the SpriteBatch.
function Spritesheet:setupBatch ()
  self._image = love.graphics.newImage(self:getCanvas())
  self.batch = love.graphics.newSpriteBatch(self._image)

  for _,key in pairs(self._spriteKeys) do
    local sprite = deepget(self.sprites, key)
    sprite._quads = {}
    for frame in sprite:frames() do
      local quad = love.graphics.newQuad(
        frame.pos.x, frame.pos.y, frame.size.width, frame.size.height,
        self.canvasAdapter:getWidth(), self.canvasAdapter:getHeight()
      )
      table.insert(sprite._quads, quad)
    end
  end

  self._uses = {}
end

-- Create a new usage for a sprite
function Spritesheet:useSprite (sprite, initX, initY, initR)
  if initR == nil then initR = 0 end
  local id = self.batch:add(sprite._quads[1], initX, initY, initR, sprite.scale)
  self._uses[id] = { frame = 1, frameCounter = 0, frameLength = 1 / sprite.ani.rate, x = initX, y = initY, r = initR, sprite = sprite }
  return id
end

-- Go to the next frame for the usage of a sprite
function Spritesheet:usageAnimate (id, dx)
  local usage = self._uses[id]
  local sprite = usage.sprite
  usage.frameCounter = usage.frameCounter + dx
  if usage.frameCounter >= usage.frameLength then
    local frame = usage.frame + 1

    usage.frameCounter = usage.frameCounter - usage.frameLength
    if frame > #sprite._quads then frame = 1 end
    usage.frame = frame
    self.batch:set(id, sprite._quads[frame], usage.x, usage.y, usage.r, sprite.scale)
  end
end

-- Change x/y/rotation for the usage of a sprite
function Spritesheet:usageSetValues (id, newX, newY, newR)
  local usage = self._uses[id]
  local quad = usage.sprite._quads[usage.frame]
  if newR == nil then newR = usage.r end

  usage.x = newX
  usage.y = newY
  usage.r = newR
  self.batch:set(id, quad, usage.x, usage.y, usage.r, usage.sprite.scale)
end

-- Gets the actual canvas image
function Spritesheet:getCanvas ()
  return self.canvasAdapter:getImage()
end


local Parser = {}

function Parser:init (filterMode)
  self.adapter = adapter
  if filterMode ~= nil then
    love.graphics.setDefaultFilter(filterMode, filterMode)
  end
end

-- Shortcut to create a new spritesheet.
function Parser:newSheet (file)
  return new(Spritesheet, self, file)
end

function Parser:parseHeader (data)
  -- Parse header
  local start, _, ver, extn, cellWidth, rest = data:find(PATTERNS.HEADER)
  -- Ensure file has the correct prefix
  if start ~= 1 then
    error(__(ERRORS.FORMAT.PREFIX, { start = start }))
  end
  -- We can only read non-extended version 1 files
  ver = tonumber(ver)
  if ver ~= 1 or extn ~= '' then
    error(__(ERRORS.WRONG_VERSION, { ver = ver, extn = extn }))
  end

  -- Check that cellWidth is positive
  cellWidth = tonumber(cellWidth)
  if cellWidth <= 0 then
    error(__(ERRORS.FORMAT.CELLWIDTH, { cw = cellWidth }))
  end

  return ver, extn, cellWidth, rest
end

function Parser:parseCoords (data, cellWidth)
  -- Parse coordinates
  local keys = {}
  local coords = {}
  while true do   -- break when line is "="
    local _, _, key, value, rest = data:find(PATTERNS.COORD_PAIR)
    if key == nil and value == nil then
      -- Terminate sequence ("=\n") found; stop
      _, _, data = data:find('=\r?\n(.*)')
      break
    end -- Rest of loop only if terminator not found

    table.insert(keys, key)

    -- Extract value
    local start, _, y, x, w, h, s, ani_sp, ani_frames, ani_sep, ani_rate = value:find(PATTERNS.COORD_VALUE)
    -- Everything should be a number
    if start == nil then
      error(__(ERRORS.FORMAT.COORD_VALUE, { key = key, value = value }))
    end
    y = tonumber(y)
    x = tonumber(x)
    w = tonumber(w)
    h = tonumber(h)
    s = tonumber(s)
    local ani_given = not (ani_sp .. ani_frames .. ani_sep .. ani_rate == '')
    if ani_given then
      ani_frames = tonumber(ani_frames)
      ani_rate = tonumber(ani_rate)
      -- If the animation info is not in valid format, error.
      if ani_frames == nil
          or ani_rate == nil
          or not (ani_sp == ' '
                  and ani_frames > 0
                  and ani_sep == '@'
                  and ani_rate >= 0) then
        error(__(ERRORS.FORMAT.COORD_VALUE, { key = key, value = value }))
      end
    else
      -- Default animation info
      ani_frames = 1
      ani_rate = 0
    end

    -- Create coords object and use deepset to make
    -- accessing it similar to how the key is written
    deepset(coords, key, new(Sprite, cellWidth, y, x, w, h, s, ani_frames, ani_rate))
    data = rest
  end

  return keys, coords, data
end

function Parser:parseCanvas (data, cellWidth)
  -- Parse canvas
  local status, result = pcall(function () return self.adapter(data) end)
  if not status then
    error(__(ERRORS.PARSE_CANVAS, { msg = result }))
  end
  if result:getWidth() % cellWidth ~= 0 then
    error(__(ERRORS.FORMAT.CANVAS_WIDTH, { width = result:getWidth(), cw = cellWidth }))
  end
  if result:getHeight() % cellWidth ~= 0 then
    error(__(ERRORS.FORMAT.CANVAS_HEIGHT, { height = result:getHeight(), cw = cellWidth }))
  end

  return result
end


-- Finalize classes
Sprite = class('Sprite', Sprite)
Spritesheet = class('Spritesheet', Spritesheet)
Parser = class('Parser', Parser)

-- Export module
return {
  Sprite = Sprite,
  Spritesheet = Spritesheet,
  Parser = Parser,
  _utils = {
    strtempl = __,
    deepget = deepget,
    deepset = deepset
  }
}
