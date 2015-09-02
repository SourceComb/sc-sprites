scspr = require 'sc-sprites'

luaunit = require 'luaunit'


function adapter (pngdat)
  local _, _, w, h = pngdat:find('(%d+)x(%d+)')
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


function testBasicRead ()
  local sheet = parser:newSheet('test-files/test1.scspr')
  luaunit.assertEquals(sheet.cellWidth, 16)
  luaunit.assertEquals(sheet.coords['player.idle.left'].pos.y, 0)
  luaunit.assertEquals(sheet.coords['player.idle.right'].pos.y, 16)
end


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
  -- TODO: Write test
end

function TestParseCoords:testInvalidSectionTerminator()
  -- TODO: Write test
end

function TestParseCoords:testInvalidKeyFormat()
  -- TODO: Write test
end

function TestParseCoords:testInvalidValueFormat()
  -- TODO: Write test
end

function TestParseCoords:testValidCoordsFormat()
  -- TODO: Write test
end

function TestParseCoords:testValidStoresKeys()
  -- TODO: Write test
end

function TestParseCoords:testValidStoresNestedKeys()
  -- TODO: Write test
end

function TestParseCoords:testValidStoresArrayKeys()
  -- TODO: Write test
end

function TestParseCoords:testValidStoresValues()
  -- TODO: Write test
end

function TestParseCoords:testValidStoresDefaultValues()
  -- TODO: Write test
end


TestParseCanvas = {}

function TestParseCanvas:testInvalidCanvas()
  -- TODO: Write test
end

function TestParseCanvas:testInvalidCanvasSize()
  -- TODO: Write test
end

function TestParseCanvas:testValidCanvas()
  -- TODO: Write test
end


os.exit(luaunit.LuaUnit.run())
