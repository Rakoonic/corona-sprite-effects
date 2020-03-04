--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local G = require( "libs.globals" )
local effectsLibrary = require( "lib-sprite-effects.effects-library" )

local composer = require( "composer" )
local scene = composer.newScene()

-- Storage for the bits
local images = {}

-- Mouse button state tracker
local oldButtonDown = false

-- Sizes / spacing etc
local imageSize, imageGap = 128, 8
local rows = 9

-- Prototypes
local mouse
local onStart, onComplete, onCancel
local setUp, setUpCogs, addEffect, removeEffect

-- Define effects to test
local testRandomEffect = true
local testRandomQuantityOfEffects = false -- If true, sets between 1 and #effectsToTest effects on each display object
local effectsQuantity = 1 -- If false == testRandomQuantityOfEffects, how many to apply to each display object
local effectsToTest = {

    ---[[
    -- Move anchor around
    {
        type = "moveAnchor",
        duration = 1550,
        limit = 0.75,
        isAnchorClamped = false, -- Without this, anchor values are limited to 0-1
        anchorChildren = true, -- Without this groups won't respond
        --easing = easing.continuousLoop,
        --useXAxis = false,
        --useYAxis = true,
        xDuration = 500,
        yDuration = 539,
        --offset = 0.5,
        --yPhase = 1000,
        cancelOnComplete = false,
    },
    --]]

    ---[[
    -- Move around
    {
        type = "move",
        duration = 1550,
        limit = 100,
        --easing = easing.continuousLoop,
        --useXAxis = false,
        --useYAxis = true,
        xDuration = 500,
        yDuration = 539,
        --yPhase = 1000,
        cancelOnComplete = false,
    },
    --]]

    ---[[
    -- Rotate back and forth
    {
        type = "rotate",
        duration = 1550,
        --minAngle = -20,
        --maxAngle = 20,
        angles = 180,
        reverse = true,
        cancelOnComplete = false,
    },
    --]]

    ---[[
    -- Rotate
    {
        type = "rotate",
        duration = 1550,
        --angles = 90,
        cancelOnComplete = false,
    },
    --]]

    ---[[
    -- Pulse
    {
        type = "pulse",
        duration = 410,
        minZoom = 0.7,
        maxZoom = 1,
        cancelOnComplete = false,
    },
    --]]

    ---[[
    -- Pulse horizontally
    {
        type = "pulse",
        duration = 120,
        minZoom = 1,
        maxZoom = 1.4,
        yAxis = false,
        cancelOnComplete = false,
    },
    --]]

    ---[[
    -- Pulse vertically
    {
        type = "pulse",
        duration = 100,
        minZoom = 1,
        maxZoom = 1.4,
        xAxis = false,
        cancelOnComplete = false,
    },
    --]]

    --[[
    -- Clock - millisecond hand
    {
        type = "clockHand",
        cancelOnComplete = false,
        hand = "milliseconds",
        --intervals = false,
        time = os.date( "*t" ),
    },
    --]]

    --[[
    -- Clock - second hand
    {
        type = "clockHand",
        cancelOnComplete = false,
        hand = "seconds",
        time = os.date( "*t" ),
        --intervals = false,
    },
    --]]

    --[[
    -- Clock - minute hand
    {
        type = "clockHand",
        cancelOnComplete = false,
        hand = "minutes",
        time = os.date( "*t" ),
    },
    --]]

    --[[
    -- Clock - hour hand
    {
        type = "clockHand",
        cancelOnComplete = false,
        hand = "hours",
        time = os.date( "*t" ),
    },
    --]]
}

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

function setUp( sceneGroup )

    local width, height = display.contentWidth, display.contentHeight

    --[[
    -- Load a test library
    effectsLibrary.loadLibrary( require( "libs.effects.effectsblah" ), "blah" )

    -- Load a test effect
    effectsLibrary.loadEffect( require( "libs.effects.singleEffect" ), "single" )

    -- Create a custom test effect
    local customEffect = {}
    function customEffect:update( startTime, time )

        -- Return new values
        return {
            xScale = math.random( 100, 110 ) / 100,
            yScale = math.random( 100, 110 ) / 100,
        }

    end
    effectsLibrary.loadEffect( customEffect, "customByCode" )

    -- Show the available effects
    local effects = effectsLibrary.getEffects()
    print( "All available effects:" )
    print( string.format( "%-20s %s", "Library name:", "Effect name:" ) )
    for k, v in pairs( effects ) do
        for i = 1, #v do
            print( string.format( "%-20s %s", k, v[ i ] ) )
        end
    end
    --]]

    local spacing = imageSize + imageGap

    -- Create several single images
    for i = 0, 17 do

        -- Create and set up image
        local image = display.newImageRect( sceneGroup, "assets/corona-icon.png", imageSize, imageSize )
        image.x = ( i % rows ) * spacing + spacing * 0.7
        image.y = math.floor( i / rows ) * spacing + spacing * 0.8

        --image.anchorY = 1

        -- Store image
        images[ #images + 1 ] = image

        -- Create id
        image.id = "image: " .. tostring( #images )

        -- Store start pos
        image.startX, image.startY = image.x, image.y

        -- Create shadow if it is the second row
        if i >= 9 then
            local shadowGroup = display.newGroup()
            sceneGroup:insert( shadowGroup )
            shadowGroup.x, shadowGroup.y = image.x, image.y + 75
            shadowGroup.xScale, shadowGroup.yScale = 0.9, 0.3

            local shadow = display.newImageRect( shadowGroup, "assets/corona-icon.png", imageSize, imageSize )
            shadow:setFillColor( 0 )

            image:toFront()
            image.shadow = shadow
        end
    end

    -- Create grouped images
    for i = 0, 17 do

        -- Create group for this
        local group = display.newGroup()
        sceneGroup:insert( group )
        group.x = ( i % rows ) * spacing + spacing * 0.7
        group.y = ( math.floor( i / rows ) + 2.5 ) * spacing + spacing

        -- Create and set up images
        for j = 0, 4 do
            local image = display.newImageRect( group, "assets/corona-icon.png", imageSize, imageSize )
            local scale = 1 - j / 6
            image.xScale, image.yScale = scale, scale

            -- Position within the area
            local limit = ( imageSize * 0.6 ) - scale * ( imageSize * 0.6 )
            image.x = math.random( -limit, limit )
            image.y = math.random( -limit, limit ) -- - 50
        end

        -- Store group
        images[ #images + 1 ] = group

        -- Store start pos
        group.startX, group.startY = group.x, group.y

        -- Create id
        group.id = "image group: " .. tostring( #images )

        -- Create shadow if it is the second row
        if i >= 9 then
            local shadowGroup = display.newGroup()
            sceneGroup:insert( shadowGroup )
            shadowGroup.x, shadowGroup.y = group.x, group.y + 75
            shadowGroup.xScale, shadowGroup.yScale = 0.9, 0.3

            local imageGroup = display.newGroup()
            shadowGroup:insert( imageGroup )

            for j = 1, group.numChildren do
                local child = group[ j ]
                local shadow = display.newImageRect( imageGroup, "assets/corona-icon.png", imageSize, imageSize )
                shadow.x, shadow.y = child.x, child.y
                shadow.xScale, shadow.yScale = child.xScale, child.yScale
                shadow:setFillColor( 0 )
            end

            group:toFront()
            group.shadow = imageGroup
        end
    end

    -- Create an actual clock

    -- Create group and position it
    local clockGroup = display.newGroup()
    sceneGroup:insert( clockGroup )
    clockGroup.x, clockGroup.y = display.contentWidth / 2, display.contentHeight / 2

    -- Create bg circle
    local bg = display.newCircle( clockGroup, 0, 0, 220 )
    bg:setFillColor( 0, 0.2, 0.2 )
    bg.alpha = 0.75

    -- Create markers for main face
    for i = 0, 60 do
        local length, width = 10, 1
        if 0 == i % 15 then length, width = 25, 5
        elseif 0 == i % 5 then length, width = 15, 5 end

        local radius = 220
        local angle = -( i * 6 ) / 180 * math.pi

        local marker = display.newRect( clockGroup, math.sin( angle ) * radius, math.cos( angle ) * radius, width, length )
        marker.anchorY = 1
        marker.rotation = i * 6
    end

    -- Create markers for mini face
    for i = 0, 100 do
        local length, width = 3, 1
        if 0 == i % 25 then length, width = 9, 2
        elseif 0 == i % 5 then length = 6 end

        local radius = 50
        local angle = -( i * 3.6 ) / 180 * math.pi

        local marker = display.newRect( clockGroup, math.sin( angle ) * radius + 100, math.cos( angle ) * radius, width, length )
        marker.anchorY = 1
        marker.rotation = i * 3.6
        marker.alpha = 0.5
    end

    -- Hour hand
    local hourHand = display.newRect( clockGroup, 0, 0, 5, 100 )
    hourHand.anchorY = 1

    -- Minute hand
    local minuteHand = display.newRect( clockGroup, 0, 0, 3, 200 )
    minuteHand.anchorY = 1

    -- Second hand
    local secondHand = display.newRect( clockGroup, 0, 0, 1, 200 )
    secondHand.anchorY = 1

    -- Millisecond hand
    local millisecondHand = display.newRect( clockGroup, 100, 0, 1, 50 )
    millisecondHand.anchorY = 1

    -- Create center circles
    display.newCircle( clockGroup, 0, 0, 10 )
    display.newCircle( clockGroup, 100, 0, 5 )

    -- Add an effect to the whole clock
    effectsLibrary.new( clockGroup, { type = "pulse", xAxis = false, duration = 531, zooms = 0.05 } )
    effectsLibrary.new( clockGroup, { type = "pulse", yAxis = false, duration = 231, zooms = 0.05 } )
    effectsLibrary.new( clockGroup, { type = "rotate", reverse = true, angles = 5, duration = 2000 } )

    -- Use custom effects
    --effectsLibrary.new( clockGroup, { type = "blah", library = "blah" } )
    --effectsLibrary.new( clockGroup, { type = "single" } )
    --effectsLibrary.new( clockGroup, { type = "customByCode" } )

    -- Set up the clock effects - everything above this is irrelevant!
    local time = os.date( "*t" )
    --local time = {
    --  hour = 6,
    --  minute = 30,
    --}
    effectsLibrary.new( hourHand, { type = "clockHand", hand = "hours", time = time, cancelOnComplete = false })
    effectsLibrary.new( minuteHand, { type = "clockHand", time = time, hand = "minutes", time = time, cancelOnComplete = false })
    effectsLibrary.new( secondHand, { type = "clockHand", hand = "seconds", time = time, cancelOnComplete = false })
    effectsLibrary.new( millisecondHand, { type = "clockHand", hand = "milliseconds", time = time, cancelOnComplete = false })

end

function setUpCogs( sceneGroup )

    local cogFile = "assets/cog.png"
    local width, height = 722, 722
    local duration = 2000

    -- Big cogs
    for i = 1, 5 do
        local cog = display.newImageRect( sceneGroup, cogFile, width / 2, height / 2 )
        cog.x = ( i - 1 ) * 330 - 20
        cog.y = display.contentHeight / 2 - 200
        cog:setFillColor( 0 )

        -- Set up effects and rotation
        if i % 2 == 0 then
            effectsLibrary.new( cog, { type = "rotate", tag = "cogs", duration = duration, cancelOnComplete = false } )
            cog.rotation = 90
        else
            effectsLibrary.new( cog, { type = "rotate", tag = "cogs", duration = duration, invert = true, cancelOnComplete = false } )
        end
    end

    -- Little cogs
    for i = 1, 5 do
        local cog = display.newImageRect( sceneGroup, cogFile, width / 3, height / 3 )
        cog.x = ( i - 1 ) * 330 - 20
        cog.y = display.contentHeight / 2 + 85
        cog:setFillColor( 0 )

        -- Set up effects and rotation
        if i % 2 == 1 then
            effectsLibrary.new( cog, { type = "rotate", tag = "cogs", duration = duration, cancelOnComplete = false } )
            cog.rotation = 90
        else
            effectsLibrary.new( cog, { type = "rotate", tag = "cogs", duration = duration, invert = true, cancelOnComplete = false } )
        end
    end

    -- Tiny cogs
    for i = 1, 5 do
        local cog = display.newImageRect( sceneGroup, cogFile, width / 5, height / 5 )
        cog.x = ( i - 1 ) * 330 - 20
        cog.y = display.contentHeight / 2 + 270
        cog:setFillColor( 0 )

        -- Set up effects and rotation
        if i % 2 == 0 then
            effectsLibrary.new( cog, { type = "rotate", tag = "cogs", duration = duration, cancelOnComplete = false } )
            cog.rotation = 90
        else
            effectsLibrary.new( cog, { type = "rotate", tag = "cogs", duration = duration, invert = true, cancelOnComplete = false } )
        end
    end
end

function addEffect( displayObject )

    -- Mark as in use
    displayObject._isWithin = true

    -- Does it have a shadow object?
    local shadowObject = displayObject.shadow

    -- Get any effects already on this object
    local displayObjectEffects = effectsLibrary.getTargetEffects( displayObject )
    --local displayObjectEffects = displayObject:getEffects()

    -- If there are already effects on this object, restart them all
    if displayObjectEffects then

        -- Restart all effects on this display object
        effectsLibrary.restart( displayObject )

        -- Restart all effects on this shadow object if it exists
        if displayObject.shadow then effectsLibrary.restart( displayObject.shadow ) end

    -- Create an effect on it
    else

        -- Set up list of effects to apply
        local effectsToApply = {}

        -- Are we after a random quantity or all of them?
        local quantity = #effectsToTest
        if true == testRandomQuantityOfEffects then quantity = math.random( #effectsToTest )
        elseif "number" == type( effectsQuantity ) then quantity = effectsQuantity end

        -- Build up list
        for i = 1, quantity do
            local effectIndex = i
            if true == testRandomEffect then effectIndex = math.random( #effectsToTest ) end
            effectsToApply[ i ] = effectsToTest[ effectIndex ]
        end

        -- Place effects on the display object and shadow if it exists
        for i = 1, #effectsToApply do
            effectsToApply[ i ].tag = "icons"
            effectsLibrary.new( displayObject, effectsToApply[ i ] )
            if shadowObject then effectsLibrary.new( shadowObject, effectsToApply[ i ] ) end
        end

        --[[
        -- Add a rotation to see how it changes things
        effectsLibrary.new(
            displayObject,
            {
                type = "rotate",
                duration = 5000,
                --angles = 90,
                cancelOnComplete = false,
            }
        )
        --]]
    end

end

function removeEffect( displayObject )

    -- Mark as not in use
    displayObject._isWithin = nil

    -- Clear effects from this object
    effectsLibrary.finish( displayObject )

    -- Clear effects from the shadow object if it exists
    if displayObject.shadow then effectsLibrary.finish( displayObject.shadow ) end

end

--------------------------------------------------------------
-- EFFECT CALLBACKS ------------------------------------------

function onStart( target, effect )

    print( "START", effect.id )

end

function onComplete( target, effect )

    print( "COMPLETE", effect.id )

end

function onCancel( target, effect )

    print( "CANCEL", effect.id )

end

--------------------------------------------------------------
-- MOUSE LISTENER --------------------------------------------

function mouse( event )

    local buttonDown = event.isPrimaryButtonDown
    local rightButtonDown = event.isSecondaryButtonDown
    local x, y = event.x, event.y

    -- Check if you are within any of the images
    for i = 1, #images do
        local image = images[ i ]
        local wasWithin = image._isWithin or false
        local within = ( x > image.startX - imageSize / 2 and
                x < image.startX + imageSize / 2 and
                y > image.startY - imageSize / 2 and
                y < image.startY + imageSize / 2 )

        if false == wasWithin and true == within then addEffect( image )
        elseif true == wasWithin and false == within then removeEffect( image ) end
    end

    -- Button press triggers a restart on everything
    if false == oldButtonDown and true == buttonDown then
        effectsLibrary.restart( "icons" )
        effectsLibrary.resume( "cogs" )
    end

    -- Store button state
    oldButtonDown = buttonDown

    -- Right mouse finishes all effects
    if true == rightButtonDown then
        effectsLibrary.finish( "icons" )
        effectsLibrary.pause( "cogs" )
    end

end

--------------------------------------------------------------
-- COMPOSER --------------------------------------------------

function scene:create( event )

    -- Create a bg
    local width, height = display.contentWidth, display.contentHeight
    local bg = display.newRect( self.view, width / 2, height / 2, width, height )
    bg:setFillColor( 0.15, 0.2, 0.2 )

    setUpCogs( self.view )
    setUp( self.view )

end

function scene:show( event )

    if event.phase == "will" then
    elseif event.phase == "did" then
        Runtime:addEventListener( "mouse", mouse )
    end

end

function scene:hide( event )

    if event.phase == "will" then
    elseif event.phase == "did" then
    end

end

function scene:destroy( event )

end

--------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
