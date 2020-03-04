-- The in-built effects library

-- Ideas for default effects to go here:

-- Jelly effect
-- Change anchor point
-- Move in circle (can make linear by ignoring one axis)
-- Bouncing
-- Flicker (add random element to blink)
-- Fill color changes
-- Border colour / thickness changes
-- Rotation of fill
-- Offset of fill
-- Mask values - rotation, scale, offset

-- Ideas that need more effort due to them not being top-level
-- accessible properties

-- Frame (animation purposes, what would be the point of this?)

-- Paths (ie individual corners)
-- 3d rotation (IE rotate in 3d axes)
-- 3d movement

-- Filters

--------------------------------------------------------------
-- EFFECTS LIBRARY DEFINITIONS -------------------------------

-- Set up

-- Effects to be returned
local effects = {}

-- Maths shortcuts
local abs, min, max = math.abs, math.min, math.max

--------------------------------------------------------------
-- MOVE EFFECT -----------------------------------------------

-- Create the required storage for the effect
effects.move = {}

-- Optional initialisation routine
function effects.move:initialise()

	-- Set up
	local useXAxis, useYAxis
	local xMin, xMax, yMin, yMax

	-- Both axes limits
	if self.limit then
		xMin, xMax = -self.limit, self.limit
		yMin, yMax = -self.limit, self.limit
	end

	if self.limitMin then xMin, yMin = self.limitMin, self.limitMin end
	if self.limitMax then xMax, yMax = self.limitMax, self.limitMax end

	-- X axis limits
	if self.xLimit then xMin, xMax = -self.xLimit, self.xLimit end
	if self.xLimitMin then xMin = self.xLimitMin end
	if self.xLimitMax then xMax = self.xLimitMax end

	-- Y axis limits
	if self.yLimit then yMin, yMax = -self.yLimit, self.yLimit end
	if self.yLimitMin then yMin = self.yLimitMin end
	if self.yLimitMax then yMax = self.yLimitMax end

	-- Which axes are we using?
	if xMin and xMax then useXAxis = true
	else useXAxis = nil end
	if yMin and yMax then useYAxis = true
	else useYAxis = nil end

	-- Do we have any overrides?
	if true == self.useXAxis then useXAxis = true end
	if true == self.useYAxis then useYAxis = true end
	if true == useXAxis and false == self.useXAxis then useXAxis = nil end
	if true == useYAxis and false == self.useYAxis then useYAxis = nil end

	-- Use some defaults where needed
	if useXAxis then
		if not xMin then xMin = -25 end
		if not xMax then xMax = 25 end
	end
	if useYAxis then
		if not yMin then yMin = -25 end
		if not yMax then yMax = 25 end
	end
	if not useXAxis and not useYAxis then
		useYAxis = true
		yMin = -25
		yMax = 25
	end

	-- Store axes use - ensures these values are correct
	self.useXAxis = useXAxis
	self.useYAxis = useYAxis

	-- Set changes
	if useXAxis then
		self.xMin, self.xMax = xMin, xMax
		self.xChange = xMax - xMin
		self.xEasing = self.xEasing or self.easing or easing.inOutSine
		self.xScale = self.xScale or 1
		self.xOffset = self.xOffset or self.offset or 0
		self.xDuration = self.xDuration or self.duration or 500

		if useYAxis and false ~= self.reverse then self.xPhase = self.xPhase or self.phase or self.xDuration / 2
		else self.xPhase = self.xPhase or self.phase or 0 end
	end
	if useYAxis then
		self.yMin, self.yMax = yMin, yMax
		self.yChange = yMax - yMin
		self.yEasing = self.yEasing or self.easing or easing.inOutSine
		self.yScale = self.yScale or 1
		self.yOffset = self.yOffset or self.offset or 0
		self.yDuration = self.yDuration or self.duration or 500
		self.yPhase = self.yPhase or self.phase or 0
	end

	-- Certain options that must be set
	if nil == self.reverse then self.reverse = true end
	self.rampInDuration = self.rampInDuration or 1000
	self.rampOutDuration = self.rampOutDuration or 1000
	self.rampInEasing = self.rampInEasing or easing.inOutQuad
	self.rampOutEasing = self.rampOutEasing or easing.inOutQuad

end

-- The actual update routine called each frame
function effects.move:update( startTime, time )

	local xRatio, yRatio
	local xTranslate, yTranslate
	
	-- Are we using the x axis?
	if self.useXAxis then
		local duration = self.xDuration

		-- Get ratio
		if true == self.reverse then xRatio = 1 - abs( ( time - startTime + self.xPhase ) % ( duration * 2 ) / duration - 1 )
		else xRatio = ( time - startTime + self.xPhase ) % duration / duration end

		-- Calculate x movement
		xTranslate = self.xEasing( xRatio, 1, self.xMin, self.xChange ) * self.xScale + self.xOffset 
	end

	-- Are we using the y axis?
	if self.useYAxis then
		local duration = self.yDuration

		-- Get y ratio
		if true == self.reverse then yRatio = 1 - abs( ( time - startTime + self.yPhase ) % ( duration * 2 ) / duration - 1 )
		else yRatio = ( time - startTime + self.yPhase ) % duration / duration end

		-- Calculate y movement
		yTranslate = self.yEasing( yRatio, 1, self.yMin, self.yChange ) + self.yScale + self.yOffset
	end

	-- Return new values
	return {
		x = xTranslate,
		y = yTranslate,
	}

end

--------------------------------------------------------------
-- MOVE ANCHOR EFFECT ----------------------------------------

-- Create the required storage for the effect
effects.moveAnchor = {}

-- Optional initialisation routine
function effects.moveAnchor:initialise()

	-- Set up
	local useXAxis, useYAxis
	local xMin, xMax, yMin, yMax

	-- Both axes limits
	if self.limit then
		xMin, xMax = -self.limit, self.limit
		yMin, yMax = -self.limit, self.limit
	end

	if self.limitMin then xMin, yMin = self.limitMin, self.limitMin end
	if self.limitMax then xMax, yMax = self.limitMax, self.limitMax end

	-- X axis limits
	if self.xLimit then xMin, xMax = -self.xLimit, self.xLimit end
	if self.xLimitMin then xMin = self.xLimitMin end
	if self.xLimitMax then xMax = self.xLimitMax end

	-- Y axis limits
	if self.yLimit then yMin, yMax = -self.yLimit, self.yLimit end
	if self.yLimitMin then yMin = self.yLimitMin end
	if self.yLimitMax then yMax = self.yLimitMax end

	-- Which axes are we using?
	if xMin and xMax then useXAxis = true
	else useXAxis = nil end
	if yMin and yMax then useYAxis = true
	else useYAxis = nil end

	-- Do we have any overrides?
	if true == self.useXAxis then useXAxis = true end
	if true == self.useYAxis then useYAxis = true end
	if true == useXAxis and false == self.useXAxis then useXAxis = nil end
	if true == useYAxis and false == self.useYAxis then useYAxis = nil end

	-- Use some defaults where needed
	if useXAxis then
		if not xMin then xMin = -0.5 end
		if not xMax then xMax = 0.5 end
	end
	if useYAxis then
		if not yMin then yMin = -0.5 end
		if not yMax then yMax = 0.5 end
	end
	if not useXAxis and not useYAxis then
		useYAxis = true
		yMin = -0.5
		yMax = 0.5
	end

	-- Store axes use - ensures these values are correct
	self.useXAxis = useXAxis
	self.useYAxis = useYAxis

	-- Set changes
	if useXAxis then
		self.xMin, self.xMax = xMin, xMax
		self.xChange = xMax - xMin
		self.xEasing = self.xEasing or self.easing or easing.inOutSine
		self.xScale = self.xScale or 1
		self.xOffset = self.xOffset or self.offset or 0
		self.xDuration = self.xDuration or self.duration or 500

		if useYAxis and false ~= self.reverse then self.xPhase = self.xPhase or self.phase or self.xDuration / 2
		else self.xPhase = self.xPhase or self.phase or 0 end
	end
	if useYAxis then
		self.yMin, self.yMax = yMin, yMax
		self.yChange = yMax - yMin
		self.yEasing = self.yEasing or self.easing or easing.inOutSine
		self.yScale = self.yScale or 1
		self.yOffset = self.yOffset or self.offset or 0
		self.yDuration = self.yDuration or self.duration or 500
		self.yPhase = self.yPhase or self.phase or 0
	end

	-- Certain options that must be set
	if nil == self.reverse then self.reverse = true end
	self.rampInDuration = self.rampInDuration or 1000
	self.rampOutDuration = self.rampOutDuration or 1000
	self.rampInEasing = self.rampInEasing or easing.inOutQuad
	self.rampOutEasing = self.rampOutEasing or easing.inOutQuad

	-- Allow anchor points to extend as far as they want
	if "boolean" == type( self.isAnchorClamped ) then display.setDefault( "isAnchorClamped", self.isAnchorClamped ) end
	if "boolean" == type( self.anchorChildren ) then self._target.anchorChildren = self.anchorChildren end

end

-- The actual update routine called each frame
function effects.moveAnchor:update( startTime, time )

	local xRatio, yRatio
	local anchorX, anchorY

	-- Are we using the x axis?
	if self.useXAxis then
		local duration = self.xDuration

		-- Get ratio
		if true == self.reverse then xRatio = 1 - abs( ( time - startTime + self.xPhase ) % ( duration * 2 ) / duration - 1 )
		else xRatio = ( time - startTime + self.xPhase ) % duration / duration end

		-- Calculate x movement
		anchorX = self.xEasing( xRatio, 1, self.xMin, self.xChange ) * self.xScale + self.xOffset 
	end

	-- Are we using the y axis?
	if self.useYAxis then
		local duration = self.yDuration

		-- Get y ratio
		if true == self.reverse then yRatio = 1 - abs( ( time - startTime + self.yPhase ) % ( duration * 2 ) / duration - 1 )
		else yRatio = ( time - startTime + self.yPhase ) % duration / duration end

		-- Calculate y movement
		anchorY = self.yEasing( yRatio, 1, self.yMin, self.yChange ) * self.yScale + self.yOffset
	end

	-- Return new values
	return {
		anchorX = anchorX,
		anchorY = anchorY,
	}

end

--------------------------------------------------------------
-- ZOOM EFFECT -----------------------------------------------

-- Create the required storage for the effect
effects.zoom = {}

-- Optional initialisation routine
function effects.zoom:initialise()

	-- Set up
	self.duration = self.duration or 250
	self.phase = self.phase or 0
	self.minZoom = self.minZoom or self.zoom or 1
	self.maxZoom = self.maxZoom or self.zoom or 1.2
	self.zoomChange = self.maxZoom - self.minZoom
	self.xScale = self.xScale or 1
	self.yScale = self.yScale or 1
	self.easing = self.easing or easing.linear

	-- Certain options that must be set
	if nil == self.xAxis then self.xAxis = true end
	if nil == self.yAxis then self.yAxis = true end
	if nil == self.reverse then self.reverse = false end

end

-- The actual update routine called each frame
function effects.zoom:update( startTime, time )

	-- Get ratio
	local ratio
	local duration = self.duration
	if true == self.reverse then ratio = 1 - abs( ( time - startTime + self.phase ) % ( duration * 2 ) / duration - 1 )
	else ratio = ( time - startTime + self.phase ) % duration / duration end

	-- Calculate zoom based on that
	local zoom = self.easing( ratio, 1, self.minZoom, self.zoomChange )

	local zoomX, zoomY = 1, 1
	if true == self.xAxis then zoomX = zoom * self.xScale end
	if true == self.yAxis then zoomY = zoom * self.yScale end

	-- Return new values
	return {
		xScale = zoomX,
		yScale = zoomY
	}

end

--------------------------------------------------------------
-- PULSE EFFECT ----------------------------------------------

-- Create the required storage for the effect
effects.pulse = {}

-- Optional initialisation routine
function effects.pulse:initialise()

	-- Set up
	self.duration = self.duration or 500
	self.phase = self.phase or 0
	if self.zooms then
		self.minZoom = 1 - self.zooms
		self.maxZoom = 1 + self.zooms
	else
		self.minZoom = self.minZoom or self.zoom or 1
		self.maxZoom = self.maxZoom or self.zoom or 1.2
	end
	self.zoomChange = self.maxZoom - self.minZoom
	self.xScale = self.xScale or 1
	self.yScale = self.yScale or 1
	self.easing = self.easing or easing.inOutQuad

	-- Certain options that must be set
	if nil == self.xAxis then self.xAxis = true end
	if nil == self.yAxis then self.yAxis = true end
	if nil == self.reverse then self.reverse = true end

end

function effects.pulse:update( startTime, time )

	-- Same code as zoom, just with different defaults
	-- Note how you have to manually pass 'self' as using :update() would send 'zoom' not 'self'
	return effects.zoom.update( self, startTime, time )

end

--------------------------------------------------------------
-- ROTATE EFFECT ---------------------------------------------

-- Create the required storage for the effect
effects.rotate = {}

-- Optional initialisation routine
function effects.rotate:initialise()

	-- Set up
	self.duration = self.duration or 500
	self.phase = self.phase or self.duration / 2
	if self.angles then
		self.minAngle = -self.angles
		self.maxAngle = self.angles
	else
		self.maxAngle = self.maxAngle or self.angle or 180
		self.minAngle = self.minAngle or self.angle or -self.maxAngle
	end
	self.minAngle = self.minAngle + ( self.anglesOffset or 0 )
	self.maxAngle = self.maxAngle + ( self.anglesOffset or 0 )	
	self.angleChange = self.maxAngle - self.minAngle

	-- Certain options that must be set
	if true ~= self.reverse then self.reverse = nil end

	-- Set up easing if it is reversed or not
	if not self.reverse then self.easing = self.easing or easing.linear
	else self.easing = self.easing or easing.inOutQuad end

end

function effects.rotate:update( startTime, time )

	-- Get ratio
	local ratio
	local duration = self.duration
	if true == self.reverse then ratio = 1 - abs( ( time - startTime + self.phase ) % ( duration * 2 ) / duration - 1 )
	else ratio = ( time - startTime + self.phase ) % duration / duration end

	-- Calculate angle change based on that
	local angleChange = self.easing( ratio, 1, self.minAngle, self.angleChange )

	-- Invert if needed?
	if true == self.invert then angleChange = -angleChange end

	-- Return new value
	return {
		rotation = angleChange,
		-- rotation = { value = angleChange, type = "add" }, -- or type = "multiply"
	}

end

--------------------------------------------------------------
-- CLOCK HAND EFFECT -----------------------------------------

-- Create the required storage for the effect
effects.clockHand = {}

-- Optional initialisation routine
function effects.clockHand:initialise()

	-- Remove ramping
	self.rampInDuration = false -- This fails because it uses _startTime in a funny way
	self.rampOutDuration = false

	-- Which hand is this? Seconds by default
	self.hand = self.hand or "seconds"

	-- Must pass a time variable
	-- Could be an actual time object
	-- Either way for accuracy it needs to include
	-- hour, minutes, seconds, milliseconds

	-- Calculate time
	local hour, minute, second, millisecond
	if self.time then
		local time = self.time
		hour = time.hour or 0
		minute = time.minute or time.min or 0
		second = time.second or time.sec or 0
		millisecond = time.millisecond or 0
	else
		hour = self.hour or 0
		minute = self.minute or 0
		second = self.second or 0
		millisecond = self.millisecond or 0
	end

	-- Set the start 
	self._startTime = self._startTime - ( millisecond + second * 1000 + minute * 1000 * 60 + hour * 1000 * 60 * 60 )

	-- Milliseconds by default move smoothly
	if "milliseconds" == self.hand then
		self.duration = 1000
		if true == self.intervals then self.intervals = 100
		elseif "number" ~= type( self.intervals ) then self.intervals = nil end

	-- Seconds by default 'leap'
	elseif "seconds" == self.hand then
		self.duration = 1000 * 60
		if nil == self.intervals or true == self.intervals then self.intervals = 60
		elseif "number" ~= type( self.intervals ) then self.intervals = nil end

	-- Minutes by default 'leap' 
	elseif "minutes" == self.hand then
		self.duration = 1000 * 60 * 60
		if nil == self.intervals or true == self.intervals then self.intervals = 60
		elseif "number" ~= type( self.intervals ) then self.intervals = nil end

	-- Hours by default move smoothly 
	elseif "hours" == self.hand then
		self.duration = 1000 * 60 * 60 * 12
		if true == self.intervals then self.intervals = 12
		elseif "number" ~= type( self.intervals ) then self.intervals = nil end
	end

	-- Set up offset angle
	self.angleOffset = self.angleOffset or 0

	-- Must be linear easing
	self.easing = easing.linear

	-- Doesn't restore by default
	if nil == self.noRestore then self.noRestore = true end

end

function effects.clockHand:update( startTime, time )

	-- Get ratio
	local ratio
	local duration = self.duration
	ratio = ( time - startTime + self.angleOffset ) % duration / duration

	-- Are intervals used?
	if self.intervals then ratio = math.floor( ratio * self.intervals ) / self.intervals end

	-- Calculate angle based on ratio
	local angle = ratio * 360

	-- Reverse direction if set
	if true == self.reverse then angle = -angle end

	-- Return new value
	return {
		rotation = angle,
	}

end

-- Additional routine to set the time
function effects.clockHand:setTime( params )

	params = params or {}

	-- Calculate time
	local hour = params.hour or 0
	local minute = params.minute or 0
	local second = params.second or 0
	local millisecond = params.millisecond or 0

	-- When to start?
	local startTime = params.startTime or system.getTimer()

	-- Set the start 
	self._startTime = startTime - ( millisecond + second * 60 + minute * 60 * 60 + hour * 60 * 60 * 24 )

end

--------------------------------------------------------------
-- FADE EFFECT -----------------------------------------------

-- Create the required storage for the effect
effects.fade = {}

-- Optional initialisation routine
function effects.fade:initialise()

	-- Set up
	self.duration = self.duration or 500
	self.phase = self.phase or 0
	self.maxAlpha = self.maxAlpha or self.alpha or 1
	self.minAlpha = self.minAlpha or self.alpha or 0.2
	self.alphaChange = self.maxAlpha - self.minAlpha
	self.easing = self.easing or easing.inOutCubic

	-- Certain options that must be set
	if nil == self.reverse then self.reverse = true end

end

-- The actual update routine called each frame
function effects.fade:update( startTime, time )

	-- Get ratio
	local ratio
	local duration = self.duration
	if true == self.reverse then ratio = 1 - abs( ( time - startTime + self.phase ) % ( duration * 2 ) / duration - 1 )
	else ratio = ( time - startTime + self.phase ) % duration / duration end

	-- Calculate angle change based on that
	local alpha = self.easing( ratio, 1, self.minAlpha, self.alphaChange )

	-- Return new value
	return {
		alpha = alpha,
	}

end

--------------------------------------------------------------
-- BLINK EFFECT ----------------------------------------------

-- Create the required storage for the effect
effects.blink = {}

-- Optional initialisation routine
function effects.blink:initialise()

	-- Set up
	self.duration = self.duration or 500
	self.phase = self.phase or 0
	self.maxAlpha = self.maxAlpha or self.alpha or 1
	self.minAlpha = self.minAlpha or self.alpha or 0.1
	self.blinkOnRatio = self.blinkOnRatio or 0.5

	-- Certain options that must be set
	self.rampInDuration = self.rampInDuration or false
	self.rampOutDuration = self.rampOutDuration or false

end

-- The actual update routine called each frame
function effects.blink:update( startTime, time )

	-- Get ratio
	local duration = self.duration
	local ratio = ( time - startTime + self.phase ) % duration / duration

	-- Calculate angle change based on that
	local alpha
	if ratio < self.blinkOnRatio then alpha = self.maxAlpha
	else alpha = self.minAlpha end

	-- Return new value
	return {
		alpha = alpha,
	}

end

--------------------------------------------------------------

-- Return the table of effects
return effects
