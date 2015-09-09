require 'class'
scspr = require 'sc-sprites'

luaunit = require 'luaunit'


TestUtils = {}

function TestUtils:testDeepGet ()
  local deepget = scspr._utils.deepget

  local o = {
    a = { x = 1, y = 2, z = 3 },
    b = { 'a', 'b', { c = 'foo', d = 'bar' } }
  }
  luaunit.assertEquals(deepget(o, 'a'), o.a)
  luaunit.assertEquals(deepget(o, 'a.x'), o.a.x)
  luaunit.assertEquals(deepget(o, 'b.1'), o.b[1])
  luaunit.assertEquals(deepget(o, 'b.3.c'), o.b[3].c)
end

function TestUtils:testDeepSet ()
  local deepset = scspr._utils.deepset

  local o = {}
  deepset(o, 'a', { x = 1 })
  deepset(o, 'a.y', 2)
  deepset(o, 'a.z.hello', 'world')
  deepset(o, 'b', { 'x' })
  deepset(o, 'b.2', 'y')
  deepset(o, 'b.+', 'z')
  deepset(o, 'c.1.foo', 'bar')
  deepset(o, 'c.+.x', 42)

  luaunit.assertEquals(o, {
    a = { x = 1, y = 2, z = { hello = 'world' } },
    b = { 'x', 'y', 'z' },
    c = { { foo = 'bar' }, { x = 42 } }
  })
end

function TestUtils:testStrTempl ()
  local __ = scspr._utils.strtempl

  luaunit.assertEquals(__('${foo}', { foo = 'bar' }), 'bar')
  luaunit.assertEquals(__('Hello, ${name}!', { name = 'World' }), 'Hello, World!')
end


--[[
function adapter (pngdat)
  local start, _, w, h = pngdat:find('(%d+)x(%d+)')
  if start == nil then
    error('No width/height given')
  end
  local a = { _pngdat = {
    data = pngdat,
    width = tonumber(w),
    height = tonumber(h)
  } }
  function a:getWidth ()
    return self._pngdat.width
  end
  function a:getHeight ()
    return self._pngdat.height
  end
  function a:getImage ()
    return self._pngdat
  end
  return a
end
]]


parser = common.instance(scspr.Parser)


TestParseHeader = {}

function TestParseHeader:testInvalidFormatName()
  luaunit.assertErrorMsgContains(
    'File does not start with the correct prefix (starts at nil)',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-format-name-nonmatch.scspr'
  )
  luaunit.assertErrorMsgContains(
    'File does not start with the correct prefix (starts at 3)',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-format-name-offset.scspr'
  )
end

function TestParseHeader:testInvalidFormatVersion()
  luaunit.assertErrorMsgContains(
    'This library can only read strict Version 1 files (version 0; extn "")',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-format-version-0.scspr'
  )
  luaunit.assertErrorMsgContains(
    'This library can only read strict Version 1 files (version 2; extn "")',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-format-version-2.scspr'
  )
end

function TestParseHeader:testInvalidExtension()
  luaunit.assertErrorMsgContains(
    'This library can only read strict Version 1 files (version 1; extn "x-json")',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-extension-json.scspr'
  )
  luaunit.assertErrorMsgContains(
    'This library can only read strict Version 1 files (version 1; extn "x-shaders")',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-extension-shaders.scspr'
  )
end

function TestParseHeader:testInvalidCellWidth()
  luaunit.assertErrorMsgContains(
    'Cell width (0) must be greater than 0',
    parser.newSheet, parser, 'test-files/test-parse-header/test-invalid-cell-width.scspr'
  )
end

function TestParseHeader:testValidHeaderFormat()
  parser:newSheet('test-files/test-parse-header/test-valid-header-format.scspr')
end

function TestParseHeader:testValidStoresFormatVersion()
  local sheet = parser:newSheet('test-files/test-parse-header/test-valid-header-format.scspr')
  luaunit.assertEquals(sheet.formatVersion, 1)
end

function TestParseHeader:testValidStoresExtension()
  local sheet = parser:newSheet('test-files/test-parse-header/test-valid-header-format.scspr')
  luaunit.assertEquals(sheet.formatExtn, '')
end

function TestParseHeader:testValidStoresCellWidth()
  local sheet = parser:newSheet('test-files/test-parse-header/test-valid-header-format.scspr')
  luaunit.assertEquals(sheet.cellWidth, 16)
end


TestParseCoords = {}

function TestParseCoords:testInvalidSectionTerminator()
  -- TODO: Write test (TODO: slightly more intelligent pattern error finding)
end

function TestParseCoords:testInvalidKeyFormat()
  -- TODO: Write test (TODO: slightly more intelligent pattern error finding)
end

function TestParseCoords:testInvalidValueFormat()
  luaunit.assertErrorMsgContains(
    'Coordinate value "a b c d" for "invalid" is not in valid format',
    parser.newSheet, parser, 'test-files/test-parse-coords/test-invalid-value-format-1.scspr'
  )
  luaunit.assertErrorMsgContains(
    'Coordinate value "1,1 1x1 1 @3" for "invalid" is not in valid format',
    parser.newSheet, parser, 'test-files/test-parse-coords/test-invalid-value-format-2.scspr'
  )
end

function TestParseCoords:testValidStoresKeys()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-keys.scspr')

  luaunit.assertNotNil(sheet.sprites.standing)
  luaunit.assertNotNil(sheet.sprites.running)
end

function TestParseCoords:testValidStoresNestedKeys()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-nested-keys.scspr')

  luaunit.assertEquals(sheet.sprites.player.idle.left.pos.x, 0)
  luaunit.assertEquals(sheet.sprites.player.idle.right.pos.x, 16)
end

function TestParseCoords:testValidStoresArrayKeys()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-array-keys.scspr')

  luaunit.assertEquals(#sheet.sprites.player.idle, 2)
  luaunit.assertEquals(sheet.sprites.player.idle[1].pos.y, 0)
  luaunit.assertEquals(sheet.sprites.player.idle[2].pos.y, 16)
end

function TestParseCoords:testValidStoresValues()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-values.scspr')

  luaunit.assertEquals(sheet.sprites.standing.pos, { y = 0, x = 0 })
  luaunit.assertEquals(sheet.sprites.standing.size, { width = 16, height = 16 })
  luaunit.assertEquals(sheet.sprites.standing.scale, 1)
  luaunit.assertEquals(sheet.sprites.standing.ani, { frames = 8, rate = 4 })

  luaunit.assertEquals(sheet.sprites.running.pos, { y = 16, x = 0 })
  luaunit.assertEquals(sheet.sprites.running.size, { width = 16, height = 16 })
  luaunit.assertEquals(sheet.sprites.running.scale, 1)
  luaunit.assertEquals(sheet.sprites.running.ani, { frames = 8, rate = 8 })
end

function TestParseCoords:testValidStoresDefaultValues()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-default-values.scspr')

  luaunit.assertEquals(sheet.sprites.player.ani, { frames = 1, rate = 0 })
end


TestParseCanvas = {}

function TestParseCanvas:testInvalidCanvas()
  luaunit.assertErrorMsgMatches(
    '.- Loading canvas failed: ".- No width/height given"',
    parser.newSheet, parser, 'test-files/test-parse-canvas/test-invalid-canvas.scspr'
  )
end

function TestParseCanvas:testInvalidCanvasSize()
  luaunit.assertErrorMsgContains(
    'Canvas width 100 must be a multiple of cell width 16',
    parser.newSheet, parser, 'test-files/test-parse-canvas/test-invalid-canvas-size-width.scspr'
  )
  luaunit.assertErrorMsgContains(
    'Canvas height 10 must be a multiple of cell width 16',
    parser.newSheet, parser, 'test-files/test-parse-canvas/test-invalid-canvas-size-height.scspr'
  )
end

function TestParseCanvas:testValidCanvas()
  local sheet = parser:newSheet('test-files/test-parse-canvas/test-valid-canvas.scspr')

  luaunit.assertEquals(sheet:getCanvas(), { data = '32x16\n', width = 32, height = 16 })
end


TestCoords = {}

function TestCoords:testGeneratesCorrectFrameset ()
  local coords = common.instance(scspr.Sprite, 16, 0, 0, 1, 1, 1, 4, 4)
  local frames = coords:getFrames()

  -- Check that consecutive frames line up correctly
  luaunit.assertEquals(frames[1].pos.x, 16*0)
  luaunit.assertEquals(frames[2].pos.x, 16*1)
  luaunit.assertEquals(frames[3].pos.x, 16*2)
  luaunit.assertEquals(frames[4].pos.x, 16*3)

  -- Check that other values are consistent
  luaunit.assertEquals(frames.rate, 4)
  luaunit.assertEquals(#frames, 4)
  luaunit.assertEquals(frames[1].pos.y, 0)
  luaunit.assertEquals(frames[2].pos.y, 0)
  luaunit.assertEquals(frames[3].pos.y, 0)
  luaunit.assertEquals(frames[4].pos.y, 0)
  luaunit.assertEquals(frames[1].size.width, 16)
  luaunit.assertEquals(frames[2].size.width, 16)
  luaunit.assertEquals(frames[3].size.width, 16)
  luaunit.assertEquals(frames[4].size.width, 16)
  luaunit.assertEquals(frames[1].size.height, 16)
  luaunit.assertEquals(frames[2].size.height, 16)
  luaunit.assertEquals(frames[3].size.height, 16)
  luaunit.assertEquals(frames[4].size.height, 16)
  luaunit.assertEquals(frames[1].scale, 1)
  luaunit.assertEquals(frames[2].scale, 1)
  luaunit.assertEquals(frames[3].scale, 1)
  luaunit.assertEquals(frames[4].scale, 1)

  coords = common.instance(scspr.Sprite, 32, 3, 2, 2, 3, 2, 3, 3)
  frames = coords:getFrames()

  -- Check that offsets and larger widths don't break things
  luaunit.assertEquals(frames[1].pos.x, (32*0*2)+(32*2))
  luaunit.assertEquals(frames[2].pos.x, (32*1*2)+(32*2))
  luaunit.assertEquals(frames[3].pos.x, (32*2*2)+(32*2))

  -- Check that the previous tests weren't for
  -- some reason passing on default values
  luaunit.assertEquals(#frames, 3)
  luaunit.assertEquals(frames[1].pos.y, 32*3)
  luaunit.assertEquals(frames[3].pos.y, 32*3)
  luaunit.assertEquals(frames[1].size.width, 32*2)
  luaunit.assertEquals(frames[3].size.width, 32*2)
  luaunit.assertEquals(frames[1].size.height, 32*3)
  luaunit.assertEquals(frames[3].size.height, 32*3)
  luaunit.assertEquals(frames[1].scale, 2)
  luaunit.assertEquals(frames[3].scale, 2)
end


local luaUnitStatus = luaunit.LuaUnit.run()
os.exit(luaUnitStatus)
