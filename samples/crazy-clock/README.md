# corona-sprite-effects

**CRAZY-CLOCK**

* Rollover the small corona icons to trigger a random effect on them
* The top two rows have the effects applied directly to the image, while the bottom two rows have the effects applied to a group containing images
* Effects aren't cleared (this is what the cancelOnComplete parameter is for), they merely finish and go idle, so rolling over an icon for the second time will trigger the same effect
* Left mouse button forces all effects to restart, so any icon you rolled over earlier will begin again
* Right mouse button finishes all effects (but does not
* cancel them, so they are not wiped)
* The icons have ramping in and out
* The clock does not (this is why when you finish all effects
* the clock resets immediately, but the icons don´t)
* The wobbling effects on the clock are the only effects that
* clear themselves after finishing
* This is why if you stop all effects with the right mouse
* button and then restart with the left, the clock goes back
* to showing the right time but no longer wobbles
