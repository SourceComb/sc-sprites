local class = require 'middleclass'

local scspr = {}


local PATTERNS = {
  HEADER = 'source comb spritesheet;(%d+);(.*);(%d+);\r?\n(.*)',
  COORD_PAIR = '([%w.]+)%s*=%s*(.-)\r?\n(.*)',
  COORD_VALUE = '(%d+),(%d+) (%d+)x(%d+) (%d+)( ?)(%d*)(@?)(%d*)'
}

local ERRORS = {
  FORMAT = {
    PREFIX = 'File does not start with the correct prefix (starts at ${start})',
    CELLWIDTH = 'Cell width (${cw}) must be greater than 0',
    COORD_VALUE = 'Coordinate value "${value}" for "${key}" is not in valid format',
    CANVAS_WIDTH = 'Canvas width ${width} must be a multiple of cell width ${cw}',
    CANVAS_HEIGHT = 'Canvas height ${height} must be a multiple of cell width ${cw}'
  },
  WRONG_VERSION = 'This library can only read strict Version 1 files (version ${ver}; extn "${extn}")',
  PARSE_CANVAS = 'Loading canvas failed: "${msg}"'
}

local function __ (str, values)
  local s = str:gsub('%${(%w+)}', function (name)
    return tostring(values[name])
  end)
  return s
end


local Coords = class('Coords')
scspr.Coords = Coords

function Coords:initialize (cellWidth, y, x, w, h, s, f, r)
  -- Store info for coordinates to retrieve
  self._cw = cellWidth
  self.pos = { y = y * cellWidth, x = x * cellWidth }
  self.size = { width = w * cellWidth, height = h * cellWidth }
  self.scale = s
  self.ani = { frames = f, rate = r }
end

function Coords:frames ()
  -- Get an array of Coords objects each representing a single frame in the
  -- animation.
  local frames = {}
  -- x for last frame:
  -- - Get last frame index
  -- - Turn it into a pixel pos relative to first frame
  -- - Add first frame offset
  local lastFrameX = ((self.ani.frames - 1) * self.size.width) + self.pos.x
  -- frameY iterates over y values for each frame
  for frameX=self.pos.x, lastFrameX, self.size.width do
    table.insert(frames, Coords:new(1, self.pos.y, frameX, self.size.width, self.size.height, self.scale, 1, 0))
  end
  frames.rate = self.ani.rate
  return frames
end

function Coords:__tostring ()
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


local Spritesheet = class('Spritesheet')
scspr.Spritesheet = Spritesheet

function Spritesheet:initialize (parser, file)
  self.parser = parser

  if file == nil then
    self.file = nil
  else
    assert(self:setFile(file))
    self:readData()
  end
end

function Spritesheet:setFile (file)
  if type(file) == 'string' then
    local errmsg, errno
    file, errmsg, errno = io.open(file, 'r')
    if file == nil then
      return nil, errmsg, errno
    end
  end

  self.file = file
  return file
end

function Spritesheet:readData (data)
  if data == nil then
    data = self.file:read('*all')
  end

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
  self.formatVersion = ver
  self.formatExtn = extn
  -- Check that cellWidth is positive
  cellWidth = tonumber(cellWidth)
  if cellWidth <= 0 then
    error(__(ERRORS.FORMAT.CELLWIDTH, { cw = cellWidth }))
  else
    self.cellWidth = cellWidth
  end

  -- Parse coordinates
  self.coords = {}
  while true do   -- break when key == nil
    local _, _, key, value, rest_ = rest:find(PATTERNS.COORD_PAIR)
    if key == nil then
      _, _, rest = rest:find('=\r?\n(.*)')
      break
    end -- Rest of loop only if key ~= nil

    -- Extract value
    local _, _, y, x, w, h, s, ani_sp, ani_frames, ani_sep, ani_rate = value:find(PATTERNS.COORD_VALUE)
    y = tonumber(y)
    x = tonumber(x)
    w = tonumber(w)
    h = tonumber(h)
    s = tonumber(s)
    local ani_given = not (ani_sp .. ani_frames .. ani_sep .. ani_rate == '')
    if ani_given then
      ani_frames = tonumber(ani_frames)
      ani_rate = tonumber(ani_rate)
      if ani_frames == nil or ani_rate == nil or not (ani_sp == ' ' and ani_frames > 0 and ani_sep == '@' and ani_rate >= 0) then
        error(__(ERRORS.FORMAT.COORD_VALUE, { key = key, value = value }))
      end
    else
      ani_frames = 1
      ani_rate = 0
    end

    self.coords[key] = Coords:new(cellWidth, y, x, w, h, s, ani_frames, ani_rate)
    rest = rest_
  end

  -- Parse canvas
  local status, result = pcall(function () return self.parser.adapter(rest) end)
  if status then
    self.canvas = result
  else
    error(__(ERRORS.PARSE_CANVAS, { msg = result }))
  end
  if self.canvas:getWidth() % cellWidth ~= 0 then
    error(__(ERRORS.FORMAT.CANVAS_WIDTH, { width = self.canvas:getWidth(), cw = cellWidth }))
  end
  if self.canvas:getHeight() % cellWidth ~= 0 then
    error(__(ERRORS.FORMAT.CANVAS_HEIGHT, { height = self.canvas:getHeight(), cw = cellWidth }))
  end
end

function Spritesheet:getCanvas ()
  return self.canvas:getImage()
end


local Parser = class('Parser')
scspr.Parser = Parser

function Parser:initialize (adapter)
  self.adapter = adapter
end

function Parser:newSheet (file)
  return Spritesheet:new(self, file)
end

return scspr
