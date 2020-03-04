-- Note this does not use transitions as it involves extra
-- concepts, most notably the concept of ramping in/out an
-- effect for seamless actions
-- It also has a simplifed interface compared to transitions

-- NEXT TO DO:

-- Have properties from effect update() return what type of
-- maths to perform on them to remove part of what is needed
-- in the private.validPropertyTypes table
-- Although this does mean if you mix and match, the order of
-- applying effects could then become important - my advice
-- would be that the default effects don't change what maths
-- are applied to a given property being changed
-- IE X pos is always addition/subtraction, scale is always
-- multiplication etc.

-- Put in proper error messages

-- Put in proper header with copyright ;)

-- .startTime property that can be set to a specific (system)
-- time or can be another effect and will extract the time
-- from there

-- onRepeat() callback whenever the effect repeats

-- How to make them affect paths? Needed for 3d effects

-- Custom callbacks for specific effects?
-- EG: an onBounce callback for the bounce effect, if possible

-- Maybe a copy effect thing to let you copy an effect and
-- have it immediately running identically on another object?
-- Could include over-writing properties

--------------------------------------------------------------
-- EFFECTS LIBRARY -------------------------------------------

-- Set up

-- Public functions of the library
local public = {}

-- Private functions and storage
local private = { effects = {}, displayObjectsData = {} }

-- Functions specific to effects
local effectFunctions = {}

-- Functions specific to display objects with effects on them
local displayObjectFunctions = {}

-- Built-in effect set up
local effectsDefinitions = {
    defaults = require( "effects-lib.effectsdefaults" ),
}

--------------------------------------------------------------

-- Maths shortcuts
local min, max = math.min, math.max

--------------------------------------------------------------

-- Search functions
private.searchFunctions = {
        all = function( effect, whatToFind ) return true end,
        object = function( effect, whatToFind ) return whatToFind == effect._target end,
        tag = function( effect, whatToFind ) return whatToFind == effect.tag end,
}

-- Valid properties you can alter
-- The true or false is whether the property requires addition / subtraction (true) or multiplication (false)
-- Probably need a way for this to be added to so custom effects can use other parameters correctly
private.validPropertyTypes = {
    x = true,
    y = true,
    width = true,
    height = true,
    xScale = false,
    yScale = false,
    rotation = true,
    alpha = false,
    anchorX = true, -- These I need to think about
    anchorY = true,
}

-- These are all properties that aren't copied from the params table
-- into the new object when it is created
private.uncopiedProperties = {
    ['type'] = true,
    _type = true,
    _effectName = true,
    _effect = true,
    _target = true,
    _isPaused = true,
    _isVisible = true,
    paused = true,
    cancelOnComplete = true,
}

--------------------------------------------------------------
-- PUBLIC FUNCTIONS ------------------------------------------

--------------------------------------------------------------
-- new( target, params )
function public.new( target, params )

    -- Find and create the effect object
    local effectObject
    local effectName = params.type or "zoom"
    if "string" == type( effectName ) then

        -- Get the effect object
        effectObject = private.getEffectObject( effectName, params.library )

        -- If no library was supplied and effect doesn't exist, see if it is in the custom lib
        if not effectObject and not params.library then
            effectObject = private.getEffectObject( effectName, "custom" )
        end

        -- If no effect object was found, stop
        if not effectObject then
            print( "EFFECT NOT FOUND, INVALID type or library", effectName, params.library )
            return false
        end

    -- A custom effect was supplied, does it have the necessary properties and functions?
    elseif "table" == type( effectName ) then

        -- Does it have a .propertiesUsed table?
        if "table" ~= type( effectName.propertiesUsed ) then
            print( "INVALID .propertiesUsed")
            return false
        end

        -- Does it have a .update() function?
        if "function" ~= type( effectName.update ) then
            print( "INVALID .update()" )
            return false
        end

        -- Use this effect object as-is
        effectObject = effectName
        effectName = "custom"

    -- An invalid parameter
    else
        print( "INVALID COMPLETELY", effectName )
        return false
    end

    -- Create a default object
    local self = {

        -- Private properties
        _type = "effect",
        _effectName = effectName,
        _effect = effectObject,
        _target = target,
        _isPaused = true, -- This gets set later
        _isVisible = true,
        _startTime = system.getTimer(),
        _cancelOnComplete = true,
    }

    --[[
    -- Meta table function
    local function catchAll( table, key )
        if effectObject[ key ] then print( "Is in effect" ) return effectObject[ key ] end
    end
    local test = { __index = catchAll }
    --local test = { __index = effectObject }

    -- Add meta table to allow for easy access to effect functions
    setmetatable( self, test )
    --]]

    -- Add in public properties as needed
    local uncopiedProperties = private.uncopiedProperties
    for k, v in pairs( params ) do
        if not uncopiedProperties[ k ] then self[ k ] = v end
    end

    -- Create a unique storage space for the original properties in the target
    local targetData = private.displayObjectsData[ target ]
    if not targetData then
        targetData = { effects = {}, propertiesBackup = {} }
        private.displayObjectsData[ target ] = targetData
    end

    -- Store this effect in the data
    targetData.effects[ #targetData.effects + 1 ] = self

    -- Initialise the effect if it needs it
    if "function" == type( self._effect.initialise ) then self._effect.initialise( self ) end

    -- Calculate manually certain properties
    if nil ~= params.cancelOnComplete and true ~= params.cancelOnComplete then self._cancelOnComplete = nil ; end
    if false ~= params.rampInDuration and nil == self.rampInDuration then
        self.rampInDuration = self.rampInDuration or 250
        if self.rampInDuration <= 0 then self.rampInDuration = false end
    end
    if false ~= params.rampOutDuration and nil == self.rampOutDuration then
        self.rampOutDuration = self.rampOutDuration or 250
        if self.rampOutDuration <= 0 then self.rampOutDuration = false end
    end
    if true ~= self.noRestore then self.noRestore = nil
    else self.rampOutDuration = false end

    -- Add in effectObject functions
    for k, v in pairs( effectObject ) do
        if "initialise" ~= k and "update" ~= k then self[ k ] = v ; end
    end

    -- Add in functions for effects
    for k, v in pairs( effectFunctions ) do
        self[ k ] = v
    end

    -- Store effect in total list
    private.effects[ #private.effects + 1 ] = self

    -- Add functions into the display object so it can access various things
    -- We don't care about over-writing as they are just functions
    for k, v in pairs( displayObjectFunctions ) do
        target[ k ] = v
    end

    -- Is there an enter frame handler set? If not, create it
    if not private.enterFrameHandler then
        Runtime:addEventListener( "enterFrame", private.enterFrame )
        private.enterFrameHandler = true
    end

    -- If this is asked to be played immediately, do so
    if not ( false == params.paused ) then self:restart() end

    -- Return the object
    return self

end

--------------------------------------------------------------

--------------------------------------------------------------
-- pause( whatToPause )
function public.pause( whatToPause )

    -- Find all the effects to be paused
    local effects = private.findEffects( whatToPause )

    print( "pause", whatToPause, effects )

    -- Pause them all
    for i = 1, #effects do
        effects[ i ]:pause()
    end

end

--------------------------------------------------------------
-- resume( whatToResume )
function public.resume( whatToResume )

    -- Find all the effects to be resumed
    local effects = private.findEffects( whatToResume )

    print( "resume", effects )

    -- Resume them all
    for i = 1, #effects do
        effects[ i ]:resume()
    end

end

--------------------------------------------------------------
-- cancel( whatToCancel )
function public.cancel( whatToCancel )

    -- Find all the effects to be cancelled
    local effects = private.findEffects( whatToCancel )

    -- Cancel them all
    for i = 1, #effects do
        effects[ i ]:cancel()
    end

end

--------------------------------------------------------------
-- restart( whatToRestart, startImmediately )
function public.restart( whatToRestart, startImmediately )

    -- Allow for missed parameter
    if "boolean" == type( whatToRestart ) then
        startImmediately = whatToRestart
        whatToRestart = nil
    end

    -- Find all the effects to be restarted
    local effects = private.findEffects( whatToRestart )

    -- Restart them all
    for i = 1, #effects do
        effects[ i ]:restart( startImmediately )
    end

end

--------------------------------------------------------------
-- finish( whatToFinish, finishImmediately )
function public.finish( whatToFinish, finishImmediately )

    -- Allow for missed parameter
    if "boolean" == type( whatToFinish ) then
        finishImmediately = whatToFinish
        whatToFinish = nil
    end

    -- Find all the effects to be finished
    local effects = private.findEffects( whatToFinish )

    -- Finish them all
    for i = 1, #effects do
        effects[ i ]:finish( finishImmediately )
    end

end

--------------------------------------------------------------
-- hide( whatToHide )
function public.hide( whatToHide )

    -- Find all the effects to be hidden
    local effects = private.findEffects( whatToHide )

    -- Hide them all
    for i = 1, #effects do
        effects[ i ]:hide()
    end

end

--------------------------------------------------------------
-- show( whatToShow )
function public.show( whatToShow )

    -- Find all the effects to be shown
    local effects = private.findEffects( whatToShow )

    -- Show them all
    for i = 1, #effects do
        effects[ i ]:show()
    end

end

--------------------------------------------------------------

--------------------------------------------------------------
-- getTargetEffects( target )
function public.getTargetEffects( target )

    -- Get data for this display object
    local targetData = private.displayObjectsData[ target ]

    -- No data so cancel
    if not targetData then return end

    -- Return the effects
    return targetData.effects

end

--------------------------------------------------------------

--------------------------------------------------------------
-- loadLibrary( newLibrary, libraryName, replace )
function public.loadLibrary( newLibrary, libraryName, replace )

    -- Missed parameters
    if "boolean" == type( libraryName ) then
        replace = libraryName
        libraryName = "custom"
    else
        replace = replace or false
        libraryName = libraryName or "custom"
    end

    -- Can't load into the default library (reverts to custom)
    if "defaults" == libraryName then
        libraryName = "custom"
        replace = false
    end

    -- Clear the library if replace was chosen
    if replace then effectsDefinitions[ libraryName ] = {} end

    -- Does this library already exist? If not, create it
    if not effectsDefinitions[ libraryName ] then effectsDefinitions[ libraryName ] = {} end

    -- Copy the effects into the library
    local currentLibrary = effectsDefinitions[ libraryName ]
    for k, v in pairs( newLibrary ) do
        currentLibrary[ k ] = v
    end

end

--------------------------------------------------------------
-- freeLibrary( libraryName )
function public.freeLibrary( libraryName )

    -- Is this a valid library name?
    if "string" ~= type( libraryName )
            or "defaults" == libraryName
            or not effectsDefinitions[ libraryName ] then return end

    -- Clear it
    effectsDefinitions[ libraryName ] = nil

    -- Return success
    return true

end

--------------------------------------------------------------
-- loadEffect( effectObject, effectName, libraryName )
function public.loadEffect( effectObject, effectName, libraryName )

    -- Allow for missed library name
    libraryName = libraryName or "custom"

    -- Can't load into the default library (reverts to custom)
    if "defaults" == libraryName then libraryName = "custom" end

    -- Does this library already exist? If not, create it
    if not effectsDefinitions[ libraryName ] then effectsDefinitions[ libraryName ] = {} end

    -- Store the effect in the library
    effectsDefinitions[ libraryName][ effectName ] = effectObject

end

--------------------------------------------------------------
-- freeEffect( effectName, libraryName )
function public.freeEffect( effectName, libraryName )

    -- Allow for missed parameters
    libraryName = libraryName or "custom"

    -- Is this a valid library name?
    if "string" ~= type( libraryName )
            or "defaults" == libraryName
            or not effectsDefinitions[ libraryName ] then return end

    -- Is this a valid effect name?
    if not effectsDefinitions[ libraryName ][ effectName ] then return end

    -- Clear it
    effectsDefinitions[ libraryName ][ effectName ] = nil

    -- Return success
    return true

end

--------------------------------------------------------------
-- getEffects()
function public.getEffects()

    -- Build list of all the names of inbuilt effects
    local effectsNames = {}
    for libraryName, libraryEffects in pairs( effectsDefinitions ) do
        local libraryNames = {}
        effectsNames[ libraryName ] = libraryNames
        for k, v in pairs( libraryEffects ) do
            libraryNames[ #libraryNames + 1 ] = k
        end
    end

    -- Return list of the effects
    return effectsNames

end

--------------------------------------------------------------
-- PRIVATE FUNCTIONS -----------------------------------------

--------------------------------------------------------------
function private.enterFrame( event )

    -- Get shortcut
    local effects = private.effects
    local time = event.time

    -- Get interally stored data for each display object with effects on it
    local displayObjectsData = private.displayObjectsData

    -- Shortcut for the validPropertyTypes and how they are handled
    local validPropertyTypes = private.validPropertyTypes

    -- Do any effects require that the target be reset?
    -- target reset means the target is reverted to its original pre-effects values
    -- Whenever the effect ends or is cancelled it needs this
    for i = 1, #effects do
        local effect = effects[ i ]

        -- Reset the sprite
        if effect._resetTarget and not effect._isCancelled then

            -- No longer needs to be reset
            effect._resetTarget = nil

            -- Reset the target values
            local target = effect._target

            -- Is there any reset data for this target?
            local targetData = displayObjectsData[ target ]
            if targetData and not effect.noRestore then

                -- Reset all values
                for k, v in pairs( targetData.propertiesBackup ) do
                    target[ k ] = v
                end
            end
        end
    end

    -- Create storage for all display objects and what properties are used this frame
    local displayObjectsProperties = {}

    -- Process all effects
    for i = 1, #effects do
        local effect = effects[ i ]

        -- Only process this effect if needed
        if not effect._isPaused and not effect._toCancel and not effect._isCancelled and not effect._isCompleted then

            -- Get the updated values back from processing this effect
            local effectValues = effect._effect.update( effect, effect._startTime, time )

            -- Is it shown?
            if effect._isVisible then

                -- Shortcut to what target this is on
                local target = effect._target

                -- Do we already have a copy of the values used for this target? If not, create them
                local targetProperties = displayObjectsProperties[ target ]
                if not targetProperties then

                    -- Create storage for all the changed properties
                    targetProperties = {}

                    -- Store so next group can find it
                    displayObjectsProperties[ target ] = targetProperties
                end

                -- The effect is ramping in
                if effect._rampIn or effect._rampOut then

                    -- The effect is ramping in
                    if effect._rampIn then

                        -- What is the ratio for the ramping (0->1)
                        rampRatio = min( ( time - effect._rampIn ) / effect.rampInDuration, 1 )

                        -- If there is an easing function specified, use it
                        if effect.rampInEasing then rampRatio = effect.rampInEasing( rampRatio, 1, 0, 1 ) end

                        -- Have we finished ramping in? If so clear flag
                        if 1 == rampRatio then effect._rampIn = nil end

                    -- The effect is ramping out
                    elseif effect._rampOut then

                        -- What is the ratio for the ramping (1->0)
                        rampRatio = max( 1 - ( time - effect._rampOut ) / effect.rampOutDuration, 0 )

                        -- If there is an easing function specified, use it
                        if true == effect.rampReverse and effect.rampInEasing then
                            rampRatio = effect.rampInEasing( rampRatio, 1, 0, 1 )
                        elseif effect.rampOutEasing then
                            rampRatio = effect.rampOutEasing( rampRatio, 1, 0, 1 )
                        end

                        -- Have we finished ramping out? If so mark as finished
                        if rampRatio == 0 then private.effectCompleted( effect ) end
                    end

                    -- Scale all effect values by this ratio
                    for k, v in pairs( effectValues ) do

                        -- Addition / subtration key (true) - simply scale by the ratio
                        if true == validPropertyTypes[ k ] then effectValues[ k ] = v * rampRatio

                        -- Scalar key (false) - make the value go to 1
                        else effectValues[ k ] = ( v - 1 ) * rampRatio + 1 end
                    end
                end

                -- Merge it in to the target's changed properties list
                for k, v in pairs( effectValues ) do
                    if validPropertyTypes[ k ] ~= nil then

                        -- Get our current working value for this property
                        local currentValue = targetProperties[ k ]

                        -- If there isn't one, get it from back up
                        if not currentValue then
                            currentValue = displayObjectsData[ target ].propertiesBackup[ k ]

                            -- If this value doesn't exist, get it from the target and store it as the backup
                            if not currentValue then
                                currentValue = target[ k ]
                                displayObjectsData[ target ].propertiesBackup[ k ] = currentValue
                            end
                        end

                        -- Merge the effect values with the current values
                        if true == validPropertyTypes[ k ] then targetProperties[ k ] = currentValue + v
                        else targetProperties[ k ] = currentValue * v end
                    end
                end
            end
        end
    end

    -- Special requirements for any effects?
    for i = #effects, 1, -1 do
        local effect = effects[ i ]

        -- Delete all effects marked as such
        if effect._toCancel and not effect._isCancelled then

            -- Mark as cancelled
            effect._isCancelled = true

            -- No longer needs to be cancelled
            effect._toCancel = nil

            -- Remove from the table
            table.remove( effects, i )

            -- Remove from the target's table list
            local target = effect._target
            local targetData = displayObjectsData[ target ]
            if targetData then
                local targetEffects = targetData.effects
                for j = 1, #targetEffects do
                    if effect == targetEffects[ j ] then
                        table.remove( targetEffects, j )
                        break
                    end
                end

                -- If this was the last effect on the target, then delete everything related to the target
                if 0 == #targetEffects then

                    -- Clear all related effects values
                    displayObjectsData[ target ] = nil

                    -- Remove functions from the display object
                    for k, v in pairs( displayObjectFunctions ) do
                        target[ k ] = nil
                    end
                end
            end

            -- Call the onCancel callback if there is one
            private.doCallback( effect, effect.onCancel )

            -- Clear target
            effect._target = nil
        end
    end

    -- Delete any effects on now-removed display objects
    for k, v in pairs( displayObjectsData ) do

        -- Does this still have the _class property? If not, delete it
        if not k._class or not k._proxy then

            -- Cancel immediately all effects on this display object
            public.cancel( k )
        end
    end

    -- Apply all properties to affected display objects
    for displayObject, propertiesToUpdate in pairs( displayObjectsProperties ) do
        for k, v in pairs( propertiesToUpdate ) do

            -- Check to prevent values being 0
            if false == validPropertyTypes[ k ] and 0 == v then displayObject[ k ] = 0.0001
            else displayObject[ k ] = v end
        end
    end

end

--------------------------------------------------------------
function private.findEffects( whatToFind, effectsToSearch )

    -- Use either the passed table or the entire list of effects
    effectsToSearch = effectsToSearch or private.effects

    -- Get the correct search function to be used
    local searchFunction
    if not whatToFind then searchFunction = private.searchFunctions.all
    elseif "string" == type( whatToFind ) then searchFunction = private.searchFunctions.tag
    elseif "table" == type( whatToFind ) then searchFunction = private.searchFunctions.object
    else
        print( "Invalid search type: " .. tostring( whatToFind ) )
        return {}
    end

    -- Search through all the effects to find matches
    local matchingEffects = {}
    for i = 1, #effectsToSearch do
        local effect = effectsToSearch[ i ]
        if searchFunction( effect, whatToFind ) then
            matchingEffects[ #matchingEffects + 1 ] = effect
        end
    end

    -- Return the matching effects
    return matchingEffects

end

--------------------------------------------------------------
function private.doCallback( effect, callback )

    -- Does the callback exist as a function?
    if "function" == type( callback ) then

        -- Is the target still a valid display object?
        local target = effect._target
        if target and not getmetatable( target ) then target = nil end

        -- Callback exists, so call it with correct parameters
        callback( target, effect )

        -- Return callback exists and was called
        return true
    else

        -- Return no callback existed
        return false
    end

end

--------------------------------------------------------------
function private.effectCompleted( effect )

    -- Mark as completed
    effect._isCompleted = true

    -- Mark as needing to be reset
    effect._resetTarget = true

    -- Mark as no longer ramping
    effect._rampIn = nil
    effect._rampOut = nil

    -- Call the onComplete callback if there is one
    private.doCallback( effect, effect.onComplete )

    -- If we want to cancel finished effect, do so here
    if effect._cancelOnComplete then effect._toCancel = true end

end

--------------------------------------------------------------
function private.getEffectObject( effectName, libraryName )

    -- Was a library also supplied?
    local libraryName = libraryName or "defaults"

    -- Does the library exist?
    if not effectsDefinitions[ libraryName ] then return false end

    -- Get effect from library
    effectObject = effectsDefinitions[ libraryName ][ effectName ]

    -- Does this built-in effect exist?
    if not effectObject then return false end

    -- It exists so return
    return effectObject

end

--------------------------------------------------------------
-- DISPLAY OBJECT FUNCTIONS ----------------------------------

function displayObjectFunctions:setBaseValue( key, value )

    -- Get data for this display object
    local targetData = private.displayObjectsData[ self ]

    -- No data so cancel
    if not targetData then return end

    -- Set the data. Note if you create a new key, it will be used when effects are removed
    targetData.propertiesBackup[ key ] = value

    -- Return as successful
    return true

end

function displayObjectFunctions:getBaseValue( key )

    -- Get data for this display object
    local targetData = private.displayObjectsData[ self ]

    -- No data so cancel
    if not targetData then return end

    -- Return the value
    return targetData.propertiesBackup[ key ]

end

function displayObjectFunctions:getEffects()

    -- Get data for this display object
    local targetData = private.displayObjectsData[ self ]

    -- No data so cancel
    if not targetData then return end

    -- Return the effects
    return targetData.effects

end

--------------------------------------------------------------
-- INDIVIDUAL EFFECT FUNCTIONS -------------------------------

--------------------------------------------------------------
-- pause()
function effectFunctions:pause()

    self._isPaused = true

    -- Needs offset time for when unpaused
    self._lastPausedTime = system.getTimer()

end

--------------------------------------------------------------
-- resume()
function effectFunctions:resume()

    self._isPaused = nil

    -- Offset by paused time if it exists
    if self._lastPausedTime then

        -- Clear the time
        self._lastPausedTime = nil
    end

end

--------------------------------------------------------------
-- cancel()
function effectFunctions:cancel()

    -- Mark as needing to reset the target
    self._resetTarget = true

    -- Remove immediately
    self._toCancel = true

end

--------------------------------------------------------------
-- restart( startImmediately )
function effectFunctions:restart( startImmediately )

    -- Can't restart at all if cancelled
    if self._toCancel or self._isCancelled then return end

    -- Is this currently in progress?
    local inProgress = ( not self._isPaused and not self._isCompleted )

    -- Mark as started
    self._isPaused = nil

    -- Mark as not completed
    self._isCompleted = nil

    -- Move this to the front if specified
    if true == self.moveToFront then self._target:toFront() end

    -- Force a restart (skips ramp in)
    if true == startImmediately then

        -- Clear any ramping in
        self._rampIn = nil

    -- Do a normal start if not already starting
    else

        -- Can't restart if already starting
        if self._rampIn then return end

        -- Set up for ramp in if specified and needed
        if false ~= self.rampInDuration then

            -- Effect was ramping out, so match it for ramping in
            if self._rampOut then

                -- Calculate the proper ramp in start time based on how far into the ramping out you got
                local time = system.getTimer()
                local diff = ( 1 - ( time - self._rampOut ) / self.rampOutDuration ) * self.rampInDuration
                self._rampIn = time - diff

            -- Effect was not started, so start from scratch
            elseif false == inProgress then

                -- Set the start time
                self._startTime = system.getTimer()

                -- Set the ramp in time
                self._rampIn = self._startTime
            end
        end
    end

    -- Stop any ramping out
    self._rampOut = nil

    -- Call the onStart callback if there is one
    private.doCallback( self, self.onStart )

end

--------------------------------------------------------------
-- finish( finishImmediately )
function effectFunctions:finish( finishImmediately )

    -- Can't finish at all if cancelled
    if self._toCancel or self._isCompleted then return end

    -- Force finish (skips ramp out)
    if true == finishImmediately then

        -- Complete the effect immediately
        private.effectCompleted( self )

    -- Do a normal finish if not already finishing
    else

        -- Abort if already finishing
        if self._rampOut then return end

        -- Should this ramp out?
        if false ~= self.rampOutDuration then

            -- If this was ramping in, stop it and set the ramp out to the same position
            if self._rampIn then

                -- Calculate the proper ramp out start time based on how far into the ramping in you got
                local time = system.getTimer()
                local diff = ( 1 - ( time - self._rampIn ) / self.rampInDuration ) * self.rampOutDuration
                self._rampOut = time - diff

                -- No longer ramping in so clear flag
                self._rampIn = nil
            else

                -- Set up the marker time for ramping out
                self._rampOut = system.getTimer()
            end

        -- Or is completed immediately
        else
            private.effectCompleted( self )
        end
    end

end

--------------------------------------------------------------
-- hide()
function effectFunctions:hide()

    self._isVisible = nil

end

--------------------------------------------------------------
-- show()
function effectFunctions:show()

    self._isVisible = true

end

--------------------------------------------------------------
-- RETURN PUBLIC FUNCTIONS -----------------------------------

-- Return value
return public