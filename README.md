# corona-sprite-effects

* Note this does not use transitions as it involves extra concepts, most notably the concept of ramping in/out an effect for seamless actions.
* It also has a simplifed interface compared to transitions

**NEXT TO DO:**
- [] Have properties from effect update() return what type of maths to perform on them to remove part of what is needed in the private.validPropertyTypes table. Although this does mean if you mix and match, the order of applying effects could then become important - my advice would be that the default effects don't change what maths are applied to a given property being changed IE X pos is always addition/subtraction, scale is always multiplication etc.

- [] Put in proper error messages

- [] Put in proper header with copyright ;)
- [] .startTime property that can be set to a specific (system) time or can be another effect and will extract the time from there
- [] onRepeat() callback whenever the effect repeats

- [] How to make them affect paths? Needed for 3d effects

- [] Custom callbacks for specific effects?
- [] EG: an onBounce callback for the bounce effect, if possible

- [] Maybe a copy effect thing to let you copy an effect and have it immediately running identically on another object? Could include over-writing properties.

- [] Allow for variable time scales per group.