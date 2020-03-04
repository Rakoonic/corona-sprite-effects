-- A custom effects library for testing

--------------------------------------------------------------
-- EFFECTS LIBRARY DEFINITIONS -------------------------------

-- Effects to be returned
local myEffects = {
    myEffect1: {},
    myEffect2: {}
}

-- Maths shortcuts
local abs, min, max = math.abs, math.min, math.max

--------------------------------------------------------------
-- ZOOM EFFECT -----------------------------------------------

-- The actual update routine called each frame
function myEffects.myEffect1:update( startTime, time )

    -- Return new values
    return {
        xScale = math.random( 100, 200 ) / 100,
        yScale = math.random( 100, 200 ) / 100,
    }

end

-- The actual update routine called each frame
function myEffects.myEffect2:update( startTime, time )

    -- Return new values
    return {
        xScale = math.random( 100, 200 ) / 100,
        yScale = math.random( 100, 200 ) / 100,
    }

end

--------------------------------------------------------------

-- Return the table of effects
return myEffects