// A foldable dice tower that can be printed as a single piece in
// place. Some folding required.
//
// Copyright (c) 2020 Rodrigo Chandia (rodrigo.chandia@gmail.com)
// All rights reserved.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// The contents of this file are DUAL-LICENSED.  You may modify and/or
// redistribute this software according to the terms of one of the
// following two licenses (at your option):
//
// License 1: Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
//            https://creativecommons.org/licenses/by-sa/4.0/
//
// License 2: GNU General Public License (GPLv3)
//            https://www.gnu.org/licenses/gpl-3.0.en.html
//
// You should have received a copy of the GNU General Public License
// along with this program. https://www.gnu.org/licenses/
//

include <hinge.scad>;

printPart1 = false;
printPart2 = true;

$fn = 32;
tolerance = 0.50;
pieces = 10;
sidePieces = 8;
flapPieces = 7;
noRotation = [0,0,0];

thick = 3;
hingeRadius = thick * 0.70;
hingeLength = 60;

boxWidth = 70;
boxHeight = 100;
boxDepth = 50;
boxOpening = 40;
boxRampLength = norm([boxDepth, boxOpening]) - thick;

flapAngle = 30;
flapHeight = boxDepth / 2 / cos(flapAngle);
flapWindowThick = 2;
flapWidth = boxWidth - hingeRadius - 2 * thick;

frontPanelSize = [boxHeight, boxWidth, thick];
sidePanelSize = [boxHeight + boxOpening, boxDepth / 2, thick];
backPanelSize = frontPanelSize;
backPanelRamp = [boxRampLength, flapWidth, thick];

module wedge(w, h) {
  rotate([-90, 0, 0])
  linear_extrude(height = h, twist = 0)
  polygon([[0,0], [w,0], [w/2, -w/2]]);
}

panels = [
  sidePanelSize,
  backPanelSize,
  sidePanelSize,
  sidePanelSize,
  frontPanelSize,
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
      for (offset = [thick  * 2: thick * 2 : flapHeight - hingeRadius - 2*thick]) {
        translate([offset - tolerance,  -0.01, -0.01])
        wedge(thick, flapWidth + 0.02);
      }
    } else {
      for (offset = [thick  * 2 + tolerance: thick * 2 : flapHeight - hingeRadius - 2*thick + tolerance]) {
        translate([offset,  -tolerance - 0.01,  +tolerance - 0.01])
        wedge(thick - 2 * tolerance, flapWidth + 3 * tolerance + 0.02);
      }
    }
  }
}

doubleHinges = concat(
(
  printPart1
  ? [1, 2]
  : []
), (
  printPart2
  ? [4, 5]
  : []
)
);

function sumY(i) = sumSlice(sliceColumn(panels + panelTolerances, 1), 0, i);

// Hinges aligned to X.
positions1 = [
  for (i = doubleHinges) [
    len(search(i, doubleHinges)) == 0 ? (backPanelSize[0] - hingeLength) / 2 : 0,
    sumY(i) - tolerance / 2,
    0
  ]
];
rotations1 = [for (i = positions1) 0];

flapOffset = hingeRadius / 2 + thick;
flapPositions = [
  [thick, flapOffset + sumY(1), 0],
  [thick + flapHeight, sumY(4) - tolerance / 2 + flapOffset, 0],
];

// Hinges aligned to Y.
insetHingesY = [
  // Bottom flap
  [backPanelSize[0] + tolerance / 2, (backPanelSize[1] - flapWidth) / 2  + sumY(1), 0],
  // Top flap
  [
    //flapHeight + thick + tolerance / 2,
    flapPositions[0][0] + flapHeight + tolerance / 2,
    (backPanelSize[1] - flapWidth) / 2  + sumY(1),
    0
  ],
  // Middle flap
  [
    //flapHeight + backPanelSize[0] / 2 + tolerance / 2 + thick, 
    flapPositions[1][0] + flapHeight + tolerance / 2,
    (backPanelSize[1] - flapWidth) / 2 + sumY(4) - tolerance / 2,
    0
  ],
];
positions2 = concat(
  (printPart1 ? [insetHingesY[0], insetHingesY[1]] : []),
  (printPart2 ? [insetHingesY[2]] : [])
); 
rotations2 = [for (i = positions2) 90];

smallHinge = 3;
flapHingeHoles = [
  [positions2[0][0], positions2[2][1], thick],
  [positions2[2][0], positions2[1][1], thick],
  [positions2[1][0], positions2[2][1], thick],
];

module layPanels() { 
  firstFlap = printPart1 ? 0 : len(flapPositions) - 1;
  lastFlap = printPart2 ? len(flapPositions) - 1 : 0;
  firstPanel = printPart1 ? 0 : 3;
  lastPanel = printPart2 ? len(panels) - 1 : 2;
  difference() {
    for (i = [firstPanel : lastPanel]) {
      translate([0, sumY(i), 0])
      cube(panels[i]);
    }
    for (i = [firstFlap : lastFlap]) {
      flap(flapPositions[i], true);
    }
  }
  for (i = [firstFlap : lastFlap]) {
    flap(flapPositions[i], false);
  }

  // Ramp
  if (printPart1) {
    translate([backPanelSize[0] + tolerance, sumY(1) + (boxWidth - flapWidth) / 2, 0])
    cube(backPanelRamp);
  }
}

difference() {
  applyHinges(
        positions1,
        rotations1,
        thick / 2,
        thick / 2,
        boxHeight,
        pieces,
        tolerance)
  applyExtraAngle(
        positions1,
        rotations1,
        thick,
        thick / 2,
        boxHeight,
        pieces,
        tolerance,
        90) // Just let it do a straight corner
  applyHinges(
        positions2,
        rotations2,
        thick / 2,
        thick / 2,
        flapWidth,
        flapPieces,
        tolerance)
  applyExtraAngle(
        positions2,
        rotations2,
        thick,
        thick / 2,
        flapWidth,
        flapPieces,
        tolerance,
        flapAngle + 90)
  layPanels();

  if (printPart1) {
    translate([(backPanelSize[0] - hingeLength) / 2, -tolerance / 2, 0])
    hingeCorner(hingeRadius, thick, hingeLength, sidePieces, true, true, tolerance);
  }
  if (printPart2) {
    translate([(backPanelSize[0] - hingeLength) / 2, -tolerance / 2 + sumY(smallHinge), 0])
    hingeCorner(hingeRadius, thick, hingeLength, sidePieces, true, true, tolerance);
  }

  if (printPart2) {
    translate([
      (backPanelSize[0] - hingeLength) / 2,
      sumY(len(panels)) - tolerance/2,
      0])
    hingeCorner(hingeRadius, thick, hingeLength, sidePieces, false, true, tolerance);
  }
  if (printPart1) {
    translate([
      (backPanelSize[0] - hingeLength) / 2,
      sumY(smallHinge) - tolerance/2,
      0])
    hingeCorner(hingeRadius, thick, hingeLength, sidePieces, false, true, tolerance);
  }
}
if (printPart1) {
  translate([(backPanelSize[0] - hingeLength) / 2, -tolerance / 2, 0])
  hingeCorner(hingeRadius, thick, hingeLength, sidePieces, true, false, tolerance);
  translate([
    (backPanelSize[0] - hingeLength) / 2,
    sumY(smallHinge) - tolerance/2,
    0])
  hingeCorner(hingeRadius, thick, hingeLength, sidePieces, false, false, tolerance);
}
if (printPart2) {
  translate([
    (backPanelSize[0] - hingeLength) / 2,
    sumY(len(panels)) - tolerance/2,
    0])
  hingeCorner(hingeRadius, thick, hingeLength, sidePieces, false, false, tolerance);
  translate([(backPanelSize[0] - hingeLength) / 2, -tolerance / 2 + sumY(smallHinge), 0])
  hingeCorner(hingeRadius, thick, hingeLength, sidePieces, true, false, tolerance);
}
