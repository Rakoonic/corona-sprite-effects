# corona-sprite-effects

**CRAZY-CLOCK**

Copy the root lib-sprite-effects/ folder into sample's root folder to enable it to run.

* Clock hands are done with effects.
* Rollover the small corona icons to trigger a random effect on them.
* The top two rows have the effects applied directly to the image, while the bottom two rows have the effects applied to a group containing images.
* Effects aren't cleared (this is what the cancelOnComplete parameter is for), they merely finish and go idle, so rolling over an icon for the second time will trigger the same effect.
* Left mouse button forces all effects to restart, so any icon you rolled over earlier will begin again.
* Right mouse button finishes all effects (but does not cancel them, so they are not wiped).
* The icons have customisable ramping in and out.
* Icons have black squashed duplicates with identical parameters of effects for the shadows.