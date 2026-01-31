
// inner cavity length (slider moves along this dimention
INNER_L= 229; // [55:350]
INNER_W= 80; // [20:250]
INNER_H= 30; // [350]

// Tollerance
TOL= 0.2; // [0.1, 0.2, 0.3, 0.4]
// minimal wall thickness
WALL1= 1.2; //[1, 1.2, 1.5, 1.6, 2]
// Size of the latch
LATCH= 1.2; //[0.5, 0.8, 1, 1.2, 1.5, 1.6, 2]
// Latch cut from the center of the latch
PIN_D= 2;
// Length of the latch cut
PIN_L= 10;
// Diameter of cut for "nail" on sliding lid
NAIL_D= 20;

/* [Hidden] */
WALL_SIDE1= WALL1*3 + LATCH*2 + TOL*2;
WALL_SIDE2= WALL1*2 + TOL;
WALL_BOTTOM= WALL1;
WALL_TOP= WALL1*3;


OUTER_R= WALL1;
OUTER_F= 6;

OUTER_L= WALL_SIDE2*2 + INNER_L + 2*TOL;
OUTER_W= WALL_SIDE1*2 + INNER_W + 2*TOL;
OUTER_H= WALL_BOTTOM + WALL_TOP + INNER_H;

PIN= OUTER_L - 15;


module round_cube(l, w, h, r, f)
{
    $fn= f;
    minkowski()
    {
        cube([l - r*2, w - r*2*cos(180/f), h - r*2*cos(180/f)], center= true);
        sphere(r= r);
    }
}


module slide(l, w, h)
{
    linear_extrude(l)
    polygon(points=
            [[w/2-WALL1,    -h/2],
             [w/2,          0],
             [w/2-WALL1,    h/2],
             [-(w/2-WALL1), h/2],
             [-w/2,         0],
             [-(w/2-WALL1), -h/2]]);
}


module lid_basic(l, w, h)
{
    ll= l - WALL1;

    translate([WALL1, 0, h/2])
    rotate([0, 90, 0])
    rotate(90)
    slide(l= ll, w= w, h= h);

    intersection()
    {
        rotate([90, 0, 0])
        translate([(WALL1*2 + 1)/2, h/2, -w])
        slide(w= WALL1*2 + 1, l= w*2, h= h);

        translate([0, 0, h/2])
        rotate([0, 90, 0])
        rotate(90)
        slide(l= ll, w= w, h= h);
    }

    translate([PIN, 0, h/2])
    intersection()
    {
        vv= (w + 2*LATCH)/sqrt(2);
        rotate(45)
        rotate([0, 90, 0])
        rotate(90)
        translate([0, 0, -vv/2])
        slide(l= vv, w= vv, h= h);

        rotate(-45)
        rotate([0, 90, 0])
        rotate(90)
        translate([0, 0, -vv/2])
        slide(l= vv, w= vv, h= h);

        cube([PIN_D*2, vv*3, h*3], center= true);
    }
}


module lid()
{
    difference()
    {
        intersection()
        {
            lid_basic(l= OUTER_L - TOL*2 - WALL1, w= OUTER_W-(WALL1+LATCH)*2 - TOL*2, h= WALL1*3);
            translate([0, 0, WALL1*3/2])
            round_cube(l= (OUTER_L - TOL*2 - WALL1)*2 , w= (OUTER_W-(WALL1+LATCH)*2 - TOL*2)*2, h= WALL1*3, r= OUTER_R, f= OUTER_F);
        }

        translate([PIN + PIN_D, -(WALL1*2+LATCH)/2 + (OUTER_W-(WALL1+LATCH)*2)/2, 0])
        cube([LATCH, WALL1*2+LATCH, WALL1*3*3], center=true);

        translate([-PIN_L/2 + PIN + PIN_D, -LATCH/2 + ((OUTER_W-(WALL1+LATCH)*2)/2 - WALL1*2), 0])
        cube([PIN_L, LATCH, WALL1*3*3], center=true);

        translate([PIN + PIN_D, (WALL1*2+LATCH)/2 - (OUTER_W-(WALL1+LATCH)*2)/2, 0])
        cube([LATCH, WALL1*2+LATCH, WALL1*3*3], center=true);
        translate([-PIN_L/2 + PIN + PIN_D, LATCH/2 - ((OUTER_W-(WALL1+LATCH)*2)/2 - WALL1*2), 0])
        cube([PIN_L, LATCH, WALL1*3*3], center=true);

        translate([OUTER_L - TOL*2 - WALL1 -WALL1*2, 0, WALL1*2])
        half_cylinder(h= WALL1, d= NAIL_D);
        translate([OUTER_L - TOL*2 - WALL1 -WALL1*2, 0, 0])
        half_cylinder(h= WALL1, d= NAIL_D);

        translate([NAIL_D, 0, WALL1*2])
        half_cylinder(h= WALL1, d= NAIL_D);
        translate([NAIL_D, 0, 0])
        half_cylinder(h= WALL1, d= NAIL_D);
    }
}


module half_cylinder(h, d)
{
    difference()
    {
        cylinder(h= h, d= d);

        translate([d/2, 0, 0])
        cube([d, d, h*3], center= true);
    }
}


module box()
{
    difference()
    {
        translate([OUTER_L/2 - (WALL_SIDE2- WALL1), 0, OUTER_H/2 - WALL_BOTTOM])
        round_cube(l= OUTER_L, w= OUTER_W, h= OUTER_H, r= OUTER_R, f= OUTER_F);

        translate([(INNER_L)/2 + WALL1*2, 0, INNER_H])
        cube([INNER_L, INNER_W, INNER_H*2], center=true);

        translate([0, 0, INNER_H])
        lid_basic(l= OUTER_L, w= OUTER_W-(WALL1+LATCH)*2 , h= WALL1*3);
    }
}


translate([/*OUTER_L*/ 0, OUTER_W /*0*/, 0 /*INNER_H*/])
lid();
box();
