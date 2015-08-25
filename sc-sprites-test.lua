scspr = require 'sc-sprites'

luaunit = require 'luaunit'


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


os.exit(luaunit.LuaUnit.run())
