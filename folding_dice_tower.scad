include <hinge.scad>;

$fn = 32;
tolerance = 0.70;
pieces = 5;
noRotation = [0,0,0];

thick = 3;
hingeRadius = thick * 0.60;
hingeLength = 30;

boxWidth = 70;
boxHeight = 100;
boxDepth = 50;
boxOpening = 40;
boxRampLength = norm([boxDepth, boxOpening]) - thick;
flapHeight = norm([boxDepth, boxDepth]) / 2.5;
flapWindowThick = 2;

frontPanelSize = [boxHeight, boxWidth, thick];
sidePanelSize = [boxHeight + boxOpening, boxDepth / 2, thick];
backPanelSize = frontPanelSize;
backPanelRamp = [boxRampLength, boxWidth, thick];

module wedge(w, h) {
  rotate([-90, 0, 0])
  linear_extrude(height = h, twist = 0)
  polygon([[0,0], [w,0], [w/2, -w/2]]);
}

panels = [
  backPanelSize,
  sidePanelSize,
  sidePanelSize,
  frontPanelSize,
  sidePanelSize,
  sidePanelSize,
];
panelTolerances = [for(i = panels) [0, tolerance, 0]];

function sumVectorInternal(vector, index) =
  index - 1 == -1
  ? 0
  : vector[index - 1] + sumVectorInternal(vector, index - 1);

function sumVector(vector) =
  sumVectorInternal(vector, len(vector));

function sumSlice(vector, from, to) =
  from < to 
  ? sumVector([ for(i = [from : to - 1]) vector[i] ])
  : 0;
    
function sliceColumn(vector, index) =
  [ for (row = vector) row[index] ];

module hingeHole(position, rotation) {
 translate(position)
  rotate([0, 0, rotation])
  translate(-[tolerance, tolerance, 0])
  rotate([0, 90, 0])
  cylinder(r = hingeRadius + tolerance, h = hingeLength + 2 * tolerance);
}

module flap(position, isNegative) {
  flapWidth = boxWidth - hingeRadius - 2 * thick;
  translate(position - (isNegative ? [tolerance, tolerance, tolerance] : [0, 0, 0]))
  difference() {
    cube([
      flapHeight,
      flapWidth,
      thick
    ] + 
    (isNegative
    ? 2 * tolerance * [1, 1, 1]
    : [0, 0, 0]));
    if (!isNegative) {
      for (offset = [thick  * 2: thick * 2 : flapHeight - hingeRadius - thick]) {
        translate([offset - tolerance,  -0.01, -0.01])
        wedge(thick, flapWidth + 0.02);
      }
    } else {
      for (offset = [thick  * 2 + tolerance: thick * 2 : flapHeight - hingeRadius - thick + tolerance]) {
        translate([offset,  -tolerance - 0.01,  thick - 3 * tolerance - 0.01])
        wedge(thick - 2 * tolerance, flapWidth + 3 * tolerance + 0.02);
      }
    }
  }
}

doubleHinges = [1, 2, 4, 5];

// Hinges aligned to X.
positions1 = [
  for (i = [1 : len(panels) - 1]) [
    len(search(i, doubleHinges)) == 0 ? (backPanelSize[0] - hingeLength) / 2 : 0,
    sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i) - tolerance / 2,
    0
  ]
];
rotations1 = [for (i = positions1) 0];
// Hinges aligned to Y.
positions2 = [
  [backPanelSize[0] + tolerance / 2, (backPanelSize[1] - hingeLength) / 2, 0],
  [flapHeight + thick + tolerance / 2, (backPanelSize[1] - hingeLength) / 2, 0],
  [
    flapHeight + backPanelSize[0] / 2 + tolerance / 2 + thick, 
    (backPanelSize[1] - hingeLength) / 2 + sumSlice(sliceColumn(panels + panelTolerances, 1), 0, 3) - tolerance / 2,
    0
  ],
];
rotations2 = [for (i = positions2) 90];
// Extra hinges aligned to X.
positions3 = [
  for (i = doubleHinges) [
    backPanelSize[0] - hingeLength,
    sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i) - tolerance / 2,
    0
  ]
];
rotations3 = [for (i = doubleHinges) 0];

singleHoles = [1, 4];
doubleHoles = [0, 3, 6];
hingeHolePositions = [
  for (i = singleHoles) [
    (backPanelSize[0] - hingeLength) / 2,
    sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i) + tolerance / 2,
    thick
  ],
  for (i = doubleHoles) [
    0,
    sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i) + tolerance / 2,
    thick
  ],
  for (i = doubleHoles) [
    (backPanelSize[0] - hingeLength),
    sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i) + tolerance / 2,
    thick
  ],
];
flapHingeHoles = [
  [positions2[0][0], positions2[2][1], thick],
  [positions2[2][0], positions2[1][1], thick],
  [positions2[1][0], positions2[2][1], thick],
];

flapStops = [
  [
    positions2[1][0] + hingeRadius + tolerance / 2,
    positions2[1][1] + hingeRadius + hingeLength + thick, 
    thick
  ], [
    positions2[1][0] + hingeRadius + tolerance / 2, 
    positions2[1][1] - hingeRadius - thick, 
    thick
  ], [
    positions2[2][0] + hingeRadius + tolerance / 2, 
    positions2[2][1] + hingeRadius + hingeLength + thick, 
    thick
  ], [
    positions2[2][0] + hingeRadius + tolerance / 2, 
    positions2[2][1] - hingeRadius - thick, 
    thick
  ],
];
flapStopHoles = [
  [flapStops[0][0], flapStops[2][1], flapStops[0][2]],
  [flapStops[1][0], flapStops[3][1], flapStops[1][2]],
  [flapStops[2][0], flapStops[0][1], flapStops[2][2]],
  [flapStops[3][0], flapStops[1][1], flapStops[3][2]],
];

flapOffset = hingeRadius / 2 + thick;
flapPositions = [
  [thick, flapOffset, 0],
  [thick + backPanelSize[0] / 2, sumSlice(sliceColumn(panels + panelTolerances, 1), 0, 3) - tolerance / 2 + flapOffset, 0],
];

module layPanels() { 
  difference() {
    for (i = [0 : len(panels) - 1]) {
      translate([0, sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i), 0])
      cube(panels[i]);
    }
    for (position = hingeHolePositions) {
      hingeHole(position, 0);
    }
    for (position = flapHingeHoles) {
      hingeHole(position, 90);
    }

    for (i = [0 : len(flapPositions) - 1]) {
      flap(flapPositions[i], true);
    }
  }
  for (i = [0 : len(flapPositions) - 1]) {
    flap(flapPositions[i], false);
  }

  translate([backPanelSize[0] + tolerance, 0, 0])
  cube(backPanelRamp);
}

difference() {
  applyHinges(
        concat(positions1, positions2, positions3),
        concat(rotations1, rotations2, rotations3),
        hingeRadius,
        thick,
        hingeLength,
        pieces,
        tolerance)
  layPanels();

  translate([(backPanelSize[0] - hingeLength) / 2, -tolerance / 2, 0])
  hingeCorner(hingeRadius, thick, hingeLength, pieces, true, true, tolerance);

  translate([
    (backPanelSize[0] - hingeLength) / 2,
    sumSlice(sliceColumn(panels + panelTolerances, 1), 0, len(panels)) - tolerance/2,
    0])
  hingeCorner(hingeRadius, thick, hingeLength, pieces, false, true, tolerance);
  for(stop = flapStopHoles) {
    translate(stop - [0, 0, hingeRadius + tolerance / 2 - 0.01])
    cylinder(r1 = 0, r2 = hingeRadius + tolerance / 2, h = hingeRadius + tolerance / 2);
  }
}
translate([(backPanelSize[0] - hingeLength) / 2, -tolerance / 2, 0])
hingeCorner(hingeRadius, thick, hingeLength, pieces, true, false, tolerance);
translate([
  (backPanelSize[0] - hingeLength) / 2,
  sumSlice(sliceColumn(panels + panelTolerances, 1), 0, len(panels)) - tolerance/2,
  0])
hingeCorner(hingeRadius, thick, hingeLength, pieces, false, false, tolerance);
for(stop = flapStops) {
  translate(stop)
  cylinder(r1 = hingeRadius, r2 = 0, h = hingeRadius);
}
