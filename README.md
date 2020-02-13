# Flat Dice Tower

OpenScad file for a dice tower that can be folded flat and printed in place.

## Summary

A dice-tower that folds flat. It prints in place, probably in a large 3d printer.

I used a TAZ 3 to print the whole part at once, but it may be too large for other printers.

### folding_dice_tower.scad

|printPart1| printPart2 | Description | Size |
|--|--|--|--|
| true | true  | Whole part | 161.53 mm x 247.20 mm x 5.10 mm |
| true | false | Back side  | 161.53 mm x 125.70 mm x 5.10 mm |
| false | true | Front side | 140.00 mm x 125.70 mm x 5.10 mm |

### folding_dice_fence.scad

| Description | Size |
|--|--|
| Half a print in place fence, print two and assemble | 199 mm x 15 mm x 6 mm |

This uses a library I developed to generate hinges in place: [hinge.scad](https://github.com/regelatwork/in-place-hinge).
Feel free to use it for anything else.

In OpenScad it generates a lot of elements very quickly so you may have to go to Edit > Preferences > Advanced > Turn off rendering at: something like 3000000. It makes your GPU sweat, but it worked for me.

## Post-Printing

First fold the printed piece in half and force-snap the hinges together. I had to gently file the tips and then stand on it to force them together. If you have a vise that may be easier.

When opening the flaps be careful with the little bars. Those are flimsy. These bars prevent the dice from exiting the box before reaching the bottom. In my tests only the bottom bar is needed, so it the others break you may still be OK.

For the fence, print two of folding_dice_fence.stl and assemble.
