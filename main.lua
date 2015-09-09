--[[
sc-sprites Lua/LÖVE visual tests

_THIS IS NOT THE LIBRARY_. For that, see `sc-sprites.lua`
]]

require 'class'
scspr = require 'sc-sprites'

parser = common.instance(scspr.Parser)

local tests = {
  {
    name = 'Draw single image',

    setup = function (self)
      self.sheet = parser:newSheet('test-files/test-visual/test-single-image.scspr')
      self.image = love.graphics.newImage(self.sheet:getCanvas())
      self.batch = love.graphics.newSpriteBatch(self.image)
      local sprite = self.sheet.sprites.placeholder
      self.quad = love.graphics.newQuad(
        sprite.pos.x, sprite.pos.y, sprite.size.width, sprite.size.height,
        self.image:getWidth(), self.image:getHeight()
      )
      self.x = 0
      self.y = 100
      self.quadId = self.batch:add(self.quad, self.x, self.y)
    end,

    update = function (self, dt)
      self.x = self.x + (100 * dt)
      self.batch:set(self.quadId, self.quad, self.x, self.y)
    end,

    draw = function (self)
      love.graphics.draw(self.batch)
    end
  }
}

local currentTest = 1
tests[currentTest]:setup()

local function nextTest (passed, quit)
  if quit then
    love.event.quit()
    return
  end

  tests[currentTest].passed = passed
  currentTest = currentTest + 1
  if currentTest > #tests then
    love.event.quit()
  else
    tests[currentTest]:setup()
  end
end

function love.quit ()
  for i,test in pairs(tests) do
    local status = 'not run'
    if test.passed == true then
      status = 'passed'
    elseif test.passed == false then
      status = 'failed'
    end

    print(i, test.name, status)
  end
end

function love.keypressed (key)
  if key == 'pageup' then
    nextTest(true)
  elseif key == 'pagedown' then
    nextTest(false)
  elseif key == 'end' then
    nextTest(false, true)
  end
end

function love.update (dt)
  tests[currentTest]:update(dt)
end

function love.draw ()
  tests[currentTest]:draw()
end
