// A foldable dice fence that can be printed as a single piece in
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

$fn = 32;
e = 0.5;
hingeR = 3;
thick = 3;
sideW = 75;
sideL = 120;
height = 15;
pieces = 4;

difference() {
  applyHingeCorner([sideL + e, 0, 0], [0, 0, 90], hingeR, thick, height, pieces, e) {
      translate([e/2, 0, 0])
      cube([sideL, height, thick]);
      translate([3/2*e + sideL, 0, 0])
      cube([sideW, height, thick]);
  }
  rotate([0,0,90])
  hingeCorner(thick/2, thick/2, height, pieces, false, true, e);
  negativeExtraAngle([0,0,0], [0,0,90], thick, thick/2, height, pieces, e, false, 90);
  translate([sideL + sideW + 2 * e, 0, 0])
  rotate([0,0,90])
  hingeCorner(thick/2, thick/2, height, pieces, true, true, e);
  negativeExtraAngle([sideL + sideW + 2 * e, 0, 0], [0,0,90], thick, thick/2, height, pieces, e, true, 90);
}
rotate([0,0,90])
hingeCorner(thick/2, thick/2, height, pieces, false, false, e);
translate([sideL + sideW + 2 * e, 0, 0])
rotate([0,0,90])
hingeCorner(thick/2, thick/2, height, pieces, true, false, e);
