// ============================================================
// Fantasy Dwarf Miniature — SLS/Resin Print
// Base: 40mm diameter | Total height: 50mm
// Suitable for 12K resin printer (e.g. Elegoo Saturn Ultra)
// Designed for novice painter: bold surfaces, clear separation
// ============================================================

$fn = 64; // smooth curves for high-res print

// ── CONFIGURATION ──────────────────────────────────────────
BASE_H       = 3;
BASE_R       = 20;   // 40mm diameter
BOOT_H       = 5;
BOOT_R       = 4.5;
LEG_H        = 10;
LEG_R        = 3.8;
LEG_SEP      = 5;
TORSO_H      = 16;
TORSO_R_BOT  = 9;
TORSO_R_TOP  = 8;
HEAD_R       = 6.5;
BEARD_H      = 7;

// Z anchor points
Z_BOOTS      = BASE_H;
Z_LEGS       = Z_BOOTS + BOOT_H - 1;
Z_TORSO      = Z_LEGS + LEG_H - 1;
Z_BELT       = Z_TORSO + TORSO_H - 3;
Z_SHOULDERS  = Z_TORSO + TORSO_H - 2;
Z_NECK       = Z_TORSO + TORSO_H;
Z_HEAD       = Z_NECK + 3;

// ── BASE (bevelled round) ───────────────────────────────────
module base() {
    minkowski() {
        cylinder(h = BASE_H - 1, r = BASE_R - 1);
        sphere(r = 0.8);
    }
}

// ── BOOTS ───────────────────────────────────────────────────
module boot(side) {
    translate([side * LEG_SEP, 1, Z_BOOTS])
        scale([1, 1.3, 1])
            cylinder(h = BOOT_H, r = BOOT_R);
}

// ── LEGS ────────────────────────────────────────────────────
module leg(side) {
    translate([side * LEG_SEP, 0, Z_LEGS])
        cylinder(h = LEG_H + 1, r = LEG_R);
}

// ── TORSO (barrel chest, tapers to shoulders) ───────────────
module torso() {
    translate([0, 0, Z_TORSO])
        cylinder(h = TORSO_H, r1 = TORSO_R_BOT, r2 = TORSO_R_TOP);
    // chest plate ridge
    translate([0, -TORSO_R_TOP + 1, Z_TORSO + 4])
        scale([0.8, 0.4, 1])
            cylinder(h = TORSO_H - 6, r = TORSO_R_TOP);
}

// ── BELT ────────────────────────────────────────────────────
module belt() {
    translate([0, 0, Z_BELT])
        difference() {
            cylinder(h = 3, r = TORSO_R_BOT + 0.5);
            cylinder(h = 3, r = TORSO_R_BOT - 1);
        }
    // buckle
    translate([0, -(TORSO_R_BOT + 0.5), Z_BELT])
        cube([4, 2, 3], center = true);
}

// ── PAULDRONS (shoulder armour) ─────────────────────────────
module pauldron(side) {
    translate([side * 11, 0, Z_SHOULDERS])
        scale([1, 0.8, 0.7])
            sphere(r = 6);
    // rim
    translate([side * 11, 0, Z_SHOULDERS - 2])
        rotate([90, 0, 0])
            cylinder(h = 1, r = 6, center = true);
}

// ── HEAD (bald, strong brow) ─────────────────────────────────
module head() {
    translate([0, 0, Z_HEAD])
        scale([1, 0.9, 1.05])
            sphere(r = HEAD_R);
    // brow ridge
    translate([0, -HEAD_R + 1, Z_HEAD + 1])
        scale([1.1, 0.4, 0.5])
            sphere(r = HEAD_R * 0.8);
    // nose
    translate([0, -(HEAD_R - 0.5), Z_HEAD - 1.5])
        sphere(r = 1.8);
    // ears
    translate([ HEAD_R - 0.8, 0, Z_HEAD - 0.5]) sphere(r = 1.5);
    translate([-HEAD_R + 0.8, 0, Z_HEAD - 0.5]) sphere(r = 1.5);
}

// ── BEARD (flowing, wide) ───────────────────────────────────
module beard() {
    // main beard mass
    translate([0, -2, Z_NECK - 2])
        scale([1.4, 0.7, 1.8])
            sphere(r = 5.5);
    // lower taper
    translate([0, -1.5, Z_NECK - 9])
        scale([1, 0.6, 1])
            sphere(r = 3.5);
    // moustache
    translate([ 3, -(HEAD_R - 1.2), Z_HEAD - 3]) scale([0.9, 0.5, 0.6]) sphere(r = 2.5);
    translate([-3, -(HEAD_R - 1.2), Z_HEAD - 3]) scale([0.9, 0.5, 0.6]) sphere(r = 2.5);
}

// ── RIGHT ARM (axe arm, raised) ─────────────────────────────
module right_arm() {
    translate([10, 0, Z_SHOULDERS - 2])
        rotate([0, -20, 25])
            cylinder(h = 14, r = 3);
    // fist
    translate([18, 3.5, Z_SHOULDERS + 6])
        sphere(r = 3.2);
}

// ── LEFT ARM (shield/brace arm, lower) ──────────────────────
module left_arm() {
    translate([-10, 0, Z_SHOULDERS - 2])
        rotate([0, 20, -15])
            cylinder(h = 12, r = 3);
    // fist
    translate([-17, 2, Z_SHOULDERS + 1])
        sphere(r = 3);
}

// ── AXE ─────────────────────────────────────────────────────
module axe() {
    // handle — two-handed war axe grip
    translate([18, 3.5, Z_SHOULDERS - 10])
        cylinder(h = 28, r = 1.2);

    // axe head (top)
    translate([18, 3, Z_SHOULDERS + 15])
        rotate([90, 0, 0]) {
            // main blade
            linear_extrude(height = 2)
                polygon(points = [
                    [0,  0],
                    [10, 4],
                    [12, 0],
                    [10,-4],
                    [0,  0]
                ]);
            // back spike
            linear_extrude(height = 2)
                polygon(points = [
                    [0,  0],
                    [-6, 2],
                    [-5, 0],
                    [-6,-2],
                    [0,  0]
                ]);
        }

    // crossguard
    translate([18, 2.5, Z_SHOULDERS + 7])
        rotate([90, 0, 0])
            cylinder(h = 8, r = 1.5, center = true);

    // pommel
    translate([18, 3.5, Z_SHOULDERS - 10])
        sphere(r = 2);
}

// ── ASSEMBLE ────────────────────────────────────────────────
union() {
    base();
    boot( 1);  boot(-1);
    leg(  1);  leg( -1);
    torso();
    belt();
    pauldron( 1);  pauldron(-1);
    head();
    beard();
    right_arm();
    left_arm();
    axe();
}
