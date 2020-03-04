-- A single custom effect for testing

--------------------------------------------------------------
-- SINGLE EFFECT DEFINITION ----------------------------------

-- Set up

-- Effects to be returned
local effect = {}

--------------------------------------------------------------
-- ZOOM EFFECT -----------------------------------------------

-- Create the required storage for the effect
effect = {}

-- The actual update routine called each frame
function effect:update( startTime, time )

	-- Return new values
	return {
		xScale = math.random( 100, 110 ) / 100,
		yScale = math.random( 100, 110 ) / 100,
	}

end

--------------------------------------------------------------

-- Return the table of effects
return effect
