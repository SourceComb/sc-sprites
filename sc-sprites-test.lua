scspr = require 'sc-sprites'

luaunit = require 'luaunit'


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


parser = scspr.Parser:new(adapter)


TestParseHeader = {}

function TestParseHeader:testInvalidHeaderFormat()
  -- TODO: Write test
end

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

function TestParseCoords:testInvalidKVFormat()
  -- TODO: Write test (might be redundant)
end

function TestParseCoords:testInvalidSectionTerminator()
  -- TODO: Write test (TODO: slightly more intelligent pattern error finding)
end

function TestParseCoords:testInvalidKeyFormat()
  -- TODO: Write test (TODO: slightly more intelligent pattern error finding)
end

function TestParseCoords:testInvalidValueFormat()
  -- TODO: Write test (TODO: slightly more intelligent pattern error finding)
end

function TestParseCoords:testValidCoordsFormat()
  -- TODO: Write test (TODO: slightly more intelligent pattern error finding)
end

function TestParseCoords:testValidStoresKeys()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-keys.scspr')

  luaunit.assertNotNil(sheet.coords.standing)
  luaunit.assertNotNil(sheet.coords.running)
end

function TestParseCoords:testValidStoresNestedKeys()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-nested-keys.scspr')

  luaunit.assertEquals(sheet.coords.player.idle.left.pos.x, 0)
  luaunit.assertEquals(sheet.coords.player.idle.right.pos.x, 16)
end

function TestParseCoords:testValidStoresArrayKeys()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-array-keys.scspr')

  luaunit.assertEquals(#sheet.coords.player.idle, 2)
  luaunit.assertEquals(sheet.coords.player.idle[1].pos.y, 0)
  luaunit.assertEquals(sheet.coords.player.idle[2].pos.y, 16)
end

function TestParseCoords:testValidStoresValues()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-values.scspr')

  luaunit.assertEquals(sheet.coords.standing.pos, { y = 0, x = 0 })
  luaunit.assertEquals(sheet.coords.standing.size, { width = 16, height = 16 })
  luaunit.assertEquals(sheet.coords.standing.scale, 1)
  luaunit.assertEquals(sheet.coords.standing.ani, { frames = 8, rate = 4 })

  luaunit.assertEquals(sheet.coords.running.pos, { y = 16, x = 0 })
  luaunit.assertEquals(sheet.coords.running.size, { width = 16, height = 16 })
  luaunit.assertEquals(sheet.coords.running.scale, 1)
  luaunit.assertEquals(sheet.coords.running.ani, { frames = 8, rate = 8 })
end

function TestParseCoords:testValidStoresDefaultValues()
  local sheet = parser:newSheet('test-files/test-parse-coords/test-valid-stores-default-values.scspr')

  luaunit.assertEquals(sheet.coords.player.ani, { frames = 1, rate = 0 })
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
  local coords = scspr.Coords:new(16, 0, 0, 1, 1, 1, 4, 4)
  local frames = coords:frames()

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

  coords = scspr.Coords:new(32, 3, 2, 2, 3, 2, 3, 3)
  frames = coords:frames()

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


os.exit(luaunit.LuaUnit.run())
