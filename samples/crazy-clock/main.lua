
--------------------------------------------------------------
-- SIMPLEST INITIALISATION -----------------------------------

-- Set up system
system.activate( "multitouch" )
display.setStatusBar(display.HiddenStatusBar)

-- Load utils
require( "libs.utils" )
local G = require( "libs.globals" )
local composer = require( "composer" )

--------------------------------------------------------------

-- Set up composer
G.composerOptions = {
	effect = "fade",
	time = 500,
}

--------------------------------------------------------------
-- GO TO MENU AND BEGIN THIS EXPERIENCE! ---------------------

composer.gotoScene( "scenes.test", G.composerOptions )
