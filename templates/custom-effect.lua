-- A single custom effect for testing

--------------------------------------------------------------
-- SINGLE EFFECT DEFINITION ----------------------------------

-- Effect to be returned
local myEffect = {}

-- The actual update routine called each frame
function myEffect:update( startTime, time )

    -- Return new values
    return {
        xScale = math.random( 100, 110 ) / 100,
        yScale = math.random( 100, 110 ) / 100,
    }

end

--------------------------------------------------------------

-- Return the effect
return effect
