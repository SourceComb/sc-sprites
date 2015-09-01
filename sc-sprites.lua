local class = require 'middleclass'

local scspr = {}


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
end

function Spritesheet:readData ()
  local data = self.file:read('*all')
  self.file:close()
  return data
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
