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
  -- TODO: Write test
end

function TestParseHeader:testInvalidFormatVersion()
  -- TODO: Write test
end

function TestParseHeader:testInvalidExtension()
  -- TODO: Write test
end

function TestParseHeader:testInvalidCellWidth()
  -- TODO: Write test
end

function TestParseHeader:testValidHeaderFormat()
  -- TODO: Write test
end

function TestParseHeader:testValidStoresFormatVersion()
  -- TODO: Write test
end

function TestParseHeader:testValidStoresExtension()
  -- TODO: Write test
end

function TestParseHeader:testValidStoresCellWidth()
  -- TODO: Write test
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
