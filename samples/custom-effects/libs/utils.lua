--------------------------------------------------------------
-- UTILITIES LIBRARY -----------------------------------------

-- Set up 
local class = {}

--------------------------------------------------------------
-- PRINT - OVERRIDE ------------------------------------------

-- Override print() function to improve performance when running on device
local _print = print
if ( system.getInfo("environment") == "device" ) then
	print = function() end
else
	print = function( ... )

		-- Parse through the items
		local printStr = ""
		local args     = arg.n
		if args == 0 then args = 1 ; end
		for i = 1, args do
			local value = arg[ i ]
			if value == nil then value = "nil" ; end

			if type( value ) == "table" then
				local tableStr = false
				for k, v in pairs( value ) do
					if tableStr == false then tableStr = "\t" .. tostring( k ) .. " = " .. tostring( v )
					else                      tableStr = tableStr .. "\n\t" .. tostring( k ) .. " = " .. tostring( v ) ; end
				end
				if tableStr == false then tableStr = tostring( value ) .. "\n\t<empty>"
				else                      tableStr = tostring( value ) .. "\n" .. tostring( tableStr ) ; end
				if i == 1 then printStr = tableStr
				else           printStr = printStr .. "\n" .. tableStr ; end
				if i < args then printStr = printStr .. "\n" ; end
			else
				printStr = printStr .. tostring( value )
				if i < args then printStr = printStr .. "\t" ; end
			end
		end

		_print( "\r                                                   \r" .. printStr )
	end
end

--------------------------------------------------------------
-- STRING - EXTEND FUNCTIONS ---------------------------------

-- Extend string library to include catalisation
function string.capitalise( str )

	return (str:gsub("^%l", string.upper))

end

-- Extend string library to include other bits I use a lot
function string.keyValues( str, pat )

	pat         = pat or '[;:]'
	local pos   = str:find( pat, 1 )
	if not pos then return false, str ; end

	local key   = str:sub( 1, pos - 1 )
	local value = str:sub( pos + 1 )

	return key, value		

end
function string.split( str,sep )
	
	local ret = {}
	local n   = 1
	for w in str:gmatch( "([^"..sep.."]*)" ) do
	    ret[ n ] = ret[ n ] or w -- only set once (so the blank after a string is ignored)
	    if w == "" then n = n + 1 end -- step forwards on a blank but not a string
	end

	return ret

end
function string.trim( str )

   return ( str:gsub("^%s*(.-)%s*$", "%1") )
   
end
function string.replaceChar( pos, str, r )

    return str:sub(1, pos-1) .. r .. str:sub(pos+1)

end
function string.replaceStr( pos, str, r )

    return str:sub(1, pos-1) .. r .. str:sub(pos+r:len())

end

--------------------------------------------------------------
-- MATHS - EXTEND FUNCTIONS ----------------------------------

-- Extend math library to include power of 2 lookups
class._powersOf2 = {
	1,
	2,
	4,
	8,
	16,
	32,
	64,
	128,
	256,
	512,
	1024,
	2048,
}
function math.powerOf2( val, highest )

	-- Find the nearest power of 2
	local powersOf2 = class._powersOf2
	if highest == true then
		for i = 1, #powersOf2 do
			if val <= powersOf2[ i ] then return powersOf2[ i ] ; end
		end
	else
		for i = 2, #powersOf2 do
			if val < powersOf2[ i ] then return powersOf2[ i - 1 ] ; end
		end
	end

	-- Return last (largest) number if this place is reached
	return powersOf2[ #powersOf2 ]
	
end

--------------------------------------------------------------
-- NEW FUNCTIONS ---------------------------------------------

function class.freeMemory()

	local function garbage ( event )
		collectgarbage( "collect" )
	end
	garbage()
	timer.performWithDelay( 1, garbage )

end

function class.isWithin( obj, x, y )

	-- Is an event within the button
	local bounds = obj.contentBounds
	if "table" == type( bounds ) then
		if "number" == type( x ) and "number" == type( y ) then
			return bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
		end
	end
	return false

end

--------------------------------------------------------------
-- PLATFORM FUNCTIONS ----------------------------------------

function class.deviceInfo( platform )

	-- Get actual screen size
	local device        = {}
	local width, height = display.pixelWidth, display.pixelHeight

	-- Content scaling sizes
	device.pixels  = {
		width  = math.ceil( display.actualContentWidth ),
		height = math.ceil( display.actualContentHeight ),
	}

	-- Store values
	class._device = device

	-- Return device values
	return device

end

--------------------------------------------------------------
-- RETURN CLASS DEFINITION -----------------------------------

return class
