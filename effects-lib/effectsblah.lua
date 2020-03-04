-- A custom effects library for testing

--------------------------------------------------------------
-- EFFECTS LIBRARY DEFINITIONS -------------------------------

-- Set up

-- Effects to be returned
local effects = {}

-- Maths shortcuts
local abs, min, max = math.abs, math.min, math.max

--------------------------------------------------------------
-- ZOOM EFFECT -----------------------------------------------

-- Create the required storage for the effect
effects.blah = {}

-- The actual update routine called each frame
function effects.blah:update( startTime, time )

	-- Return new values
	return {
		xScale = math.random( 100, 200 ) / 100,
		yScale = math.random( 100, 200 ) / 100,
	}

end

--------------------------------------------------------------

-- Return the table of effects
return effects
